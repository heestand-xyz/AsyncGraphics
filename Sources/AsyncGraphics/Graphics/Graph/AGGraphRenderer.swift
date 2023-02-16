import Foundation

final class AGGraphRenderer: ObservableObject {
    
    var activeCameraPositions: Set<Graphic.CameraPosition> = []
    var activeCameraTasks: [Graphic.CameraPosition: Task<Void, Error>] = [:]
    var activeCameraMaximumResolutions: [Graphic.CameraPosition: CGSize] = [:]
    @Published var activeCameraGraphics: [Graphic.CameraPosition: Graphic] = [:]
    @Published var activeCameraResolutions: [Graphic.CameraPosition: CGSize] = [:]
}

extension AGGraphRenderer {
    
    func details(for graph: any AGGraph, at resolution: CGSize) -> AGRenderDetails {
        print("------------------------------------>", resolution)
        return AGRenderDetails(resources: resources(for: graph, at: resolution),
                        resolutionDetails: resolutionDetails(for: graph, at: resolution))
    }
    
    func resolutionDetails(for graph: any AGGraph, at resolution: CGSize) -> AGResolutionDetails {
        AGResolutionDetails(resolution: resolution,
                            resources: resolutionResources(for: graph, at: resolution))
    }
}

extension AGGraphRenderer {
    
    private func resolutionResources(for graph: any AGGraph, at resolution: CGSize) -> AGResolutionResources {
        
        checkResources(for: graph, at: resolution)
        
        var cameraResolutions: [Graphic.CameraPosition: CGSize] = [:]
        for cameraPosition in activeCameraPositions {
            guard let resolution: CGSize = activeCameraResolutions[cameraPosition] else { continue }
            cameraResolutions[cameraPosition] = resolution
        }
        
        return AGResolutionResources(cameraResolutions: cameraResolutions)
    }
    
    private func resources(for graph: any AGGraph, at resolution: CGSize) -> AGResources {
        
        checkResources(for: graph, at: resolution)
        
        var cameraGraphics: [Graphic.CameraPosition: Graphic] = [:]
        for cameraPosition in activeCameraPositions {
            guard let graphic: Graphic = activeCameraGraphics[cameraPosition] else { continue }
            cameraGraphics[cameraPosition] = graphic
        }
        
        return AGResources(cameraGraphics: cameraGraphics)
    }
}

extension AGGraphRenderer {
    
    private func checkResources(for graph: any AGGraph, at resolution: CGSize) {
        checkCamera(for: graph, at: resolution)
    }
    
    private func checkCamera(for graph: any AGGraph, at resolution: CGSize) {
        
        let cameraPositions = cameraPositions(for: graph)
        
        let emptyResources = AGResolutionResources(cameraResolutions: [:])
        activeCameraMaximumResolutions = cameraMaximumResolutions(for: graph, with: AGResolutionDetails(resolution: resolution, resources: emptyResources))
        
        for cameraPosition in cameraPositions {
            if !activeCameraPositions.contains(where: { $0 == cameraPosition }) {
                activeCameraPositions.insert(cameraPosition)
                startCamera(position: cameraPosition)
            }
        }
        
        for cameraPosition in activeCameraPositions {
            if !cameraPositions.contains(cameraPosition) {
                activeCameraPositions.remove(cameraPosition)
                stopCamera(position: cameraPosition)
            }
        }
    }
}

extension AGGraphRenderer {
    
    private func startCamera(position: Graphic.CameraPosition) {
        print("Async Graphics - Graph - Camera - Start")
        let task = Task {
            for await graphic in try Graphic.camera(position) {
                print("Async Graphics - Graph - Camera", "position:", position, graphic.resolution)
                let resizedGraphic: Graphic
                if let maximumResolution: CGSize = activeCameraMaximumResolutions[position],
                   graphic.width > maximumResolution.width,
                   graphic.height > maximumResolution.height {
                    let targetResolution: CGSize = graphic.resolution.place(in: maximumResolution, placement: .fill)
                    resizedGraphic = try await graphic.resized(to: targetResolution, method: .lanczos)
                    print("-------->", "YYEEEAH")
                } else {
                    print("-------->", activeCameraMaximumResolutions[position] as Any)
                    resizedGraphic = graphic
                }
                await MainActor.run {
                    activeCameraGraphics[position] = resizedGraphic
                    activeCameraResolutions[position] = graphic.resolution
                }
            }
        }
        activeCameraTasks[position] = task
    }
    
    private func stopCamera(position: Graphic.CameraPosition) {
        print("Async Graphics - Graph - Camera - Stop")
        guard let task = activeCameraTasks[position] else { return }
        task.cancel()
        activeCameraTasks.removeValue(forKey: position)
        activeCameraGraphics.removeValue(forKey: position)
        activeCameraResolutions.removeValue(forKey: position)
    }
}

extension AGGraphRenderer {
    
    private func cameraPositions(for graph: any AGGraph) -> Set<Graphic.CameraPosition> {
        var cameraPositions: Set<Graphic.CameraPosition> = []
        if let camera = graph as? AGCamera {
            cameraPositions.insert(camera.position)
        }
        if let parentGraph = graph as? any AGParentGraph {
            for child in parentGraph.children {
                cameraPositions.formUnion(self.cameraPositions(for: child))
            }
        }
        return cameraPositions
    }
    
    private func cameraMaximumResolutions(for graph: any AGGraph, with resolutionDetails: AGResolutionDetails) -> [Graphic.CameraPosition: CGSize] {
        print("---> cameraMaximumResolutions:", type(of: graph), resolutionDetails.resolution)
        var maximumResolutions: [Graphic.CameraPosition: CGSize] = [:]
        if let camera = graph as? AGCamera {
            maximumResolutions[camera.position] = camera.contentResolution(with: resolutionDetails)
                .fallback(to: resolutionDetails.resolution)
        }
        let resolutionDetails: AGResolutionDetails = resolutionDetails
            .with(resolution: graph
                .contentResolution(with: resolutionDetails)
                .fallback(to: resolutionDetails.resolution))
        if let parentGraph = graph as? any AGParentGraph {
            for child in parentGraph.children {
                for (cameraPosition, maximumResolution) in cameraMaximumResolutions(for: child, with: resolutionDetails) {
                    if let currentMaximumResolution: CGSize = maximumResolutions[cameraPosition] {
                        maximumResolutions[cameraPosition] = CGSize(
                            width: max(currentMaximumResolution.width, maximumResolution.width),
                            height: max(currentMaximumResolution.height, maximumResolution.height))
                    } else {
                        maximumResolutions[cameraPosition] = maximumResolution
                    }
                }
            }
        }
        return maximumResolutions
    }
}
