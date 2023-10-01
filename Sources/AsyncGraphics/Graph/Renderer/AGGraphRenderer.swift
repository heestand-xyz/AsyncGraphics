import Foundation
import Combine

public final class AGGraphRenderer: ObservableObject {
    
    #if !os(visionOS)
    
    var activeCameraPositions: Set<Graphic.CameraPosition> = []
    var activeCameraTasks: [Graphic.CameraPosition: Task<Void, Error>] = [:]
    var activeCameraMaximumResolutions: [Graphic.CameraPosition: CGSize] = [:]
    @Published var activeCameraGraphics: [Graphic.CameraPosition: Graphic] = [:]
    @Published var activeCameraResolutions: [Graphic.CameraPosition: CGSize] = [:]
    
    #endif
    
    var activeVideoPlayers: Set<GraphicVideoPlayer> = []
    var activeVideoTasks: [GraphicVideoPlayer: Task<Void, Error>] = [:]
    var activeVideoMaximumResolutions: [GraphicVideoPlayer: CGSize] = [:]
    @Published var activeVideoGraphics: [GraphicVideoPlayer: Graphic] = [:]
    
    var activeImageSources: Set<AGImage.Source> = []
    var activeImageMaximumResolutions: [AGImage.Source: CGSize] = [:]
    @Published var activeImageGraphics: [AGImage.Source: Graphic] = [:]
    @Published var activeImageResolutions: [AGImage.Source: CGSize] = [:]
    
    public init() { }
}

extension AGGraphRenderer {
    
    func details(for graph: any AGGraph, at resolution: CGSize) -> AGDetails {
        AGDetails(resources: resources(for: graph, at: resolution),
                        specification: specification(for: graph, at: resolution))
    }
    
    func specification(for graph: any AGGraph, at resolution: CGSize) -> AGSpecification {
        AGSpecification(resourceResolutions: resourceResolutions(for: graph, at: resolution))
    }
}

extension AGGraphRenderer {
    
    private func resourceResolutions(for graph: any AGGraph, at resolution: CGSize) -> AGResourceResolutions {
        
        checkResources(for: graph, at: resolution)
        
        #if !os(visionOS)
        var cameraResolutions: [Graphic.CameraPosition: CGSize] = [:]
        for cameraPosition in activeCameraPositions {
            guard let resolution: CGSize = activeCameraResolutions[cameraPosition] else { continue }
            cameraResolutions[cameraPosition] = resolution
        }
        #endif
        
        var imageResolutions: [AGImage.Source: CGSize] = [:]
        for imageSource in activeImageSources {
            guard let resolution: CGSize = activeImageResolutions[imageSource] else { continue }
            imageResolutions[imageSource] = resolution
        }
        
        #if os(visionOS)
        return AGResourceResolutions(image: imageResolutions)
        #else
        return AGResourceResolutions(camera: cameraResolutions, image: imageResolutions)
        #endif
    }
    
    private func resources(for graph: any AGGraph, at resolution: CGSize) -> AGResources {
        
        checkResources(for: graph, at: resolution)
        
        #if !os(visionOS)
        
        var cameraGraphics: [Graphic.CameraPosition: Graphic] = [:]
        for cameraPosition in activeCameraPositions {
            guard let graphic: Graphic = activeCameraGraphics[cameraPosition] else { continue }
            cameraGraphics[cameraPosition] = graphic
        }
        
        #endif
        
        var videoGraphics: [GraphicVideoPlayer: Graphic] = [:]
        for videoPlayer in activeVideoPlayers {
            guard let graphic: Graphic = activeVideoGraphics[videoPlayer] else { continue }
            videoGraphics[videoPlayer] = graphic
        }
        
        var imageGraphics: [AGImage.Source: Graphic] = [:]
        for imageSource in activeImageSources {
            guard let graphic: Graphic = activeImageGraphics[imageSource] else { continue }
            imageGraphics[imageSource] = graphic
        }
        
        #if os(visionOS)
        return AGResources(videoGraphics: videoGraphics, imageGraphics: imageGraphics)
        #else
        return AGResources(cameraGraphics: cameraGraphics, videoGraphics: videoGraphics, imageGraphics: imageGraphics)
        #endif
    }
}

extension AGGraphRenderer {
    
    private func checkResources(for graph: any AGGraph, at resolution: CGSize) {
        #if !os(visionOS)
        checkCameras(for: graph, at: resolution)
        #endif
        checkVideos(for: graph, at: resolution)
        checkImages(for: graph, at: resolution)
    }
    
    #if !os(visionOS)
    
    private func checkCameras(for graph: any AGGraph, at resolution: CGSize) {
        
        let cameraPositions = cameraPositions(for: graph)
        
        let emptyResourceResolutions = AGResourceResolutions(camera: [:], image: [:])
        let specification = AGSpecification(resourceResolutions: emptyResourceResolutions)
        activeCameraMaximumResolutions = cameraMaximumResolutions(for: graph, at: resolution, for: specification)
        
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
    
    #endif
    
    private func checkVideos(for graph: any AGGraph, at resolution: CGSize) {
        
        let videoPlayers = videoPlayers(for: graph)
        
        #if os(visionOS)
        let emptyResourceResolutions = AGResourceResolutions(image: [:])
        #else
        let emptyResourceResolutions = AGResourceResolutions(camera: [:], image: [:])
        #endif
        let specification = AGSpecification(resourceResolutions: emptyResourceResolutions)
        activeVideoMaximumResolutions = videoMaximumResolutions(for: graph, at: resolution, for: specification)
        
        for videoPlayer in videoPlayers {
            if !activeVideoPlayers.contains(where: { $0 == videoPlayer }) {
                activeVideoPlayers.insert(videoPlayer)
                startVideo(with: videoPlayer)
            }
        }
        
        for videoPlayer in activeVideoPlayers {
            if !videoPlayers.contains(videoPlayer) {
                activeVideoPlayers.remove(videoPlayer)
                stopVideo(with: videoPlayer)
            }
        }
    }
    
    private func checkImages(for graph: any AGGraph, at resolution: CGSize) {
        
        let imageSources = imageSources(for: graph)
                
        #if os(visionOS)
        let emptyResourceResolutions = AGResourceResolutions(image: [:])
        #else
        let emptyResourceResolutions = AGResourceResolutions(camera: [:], image: [:])
        #endif
        let specification = AGSpecification(resourceResolutions: emptyResourceResolutions)
        activeImageMaximumResolutions = imageMaximumResolutions(for: graph, at: resolution, for: specification)
        
        for imageSource in imageSources {
            if !activeImageSources.contains(where: { $0 == imageSource }) {
                activeImageSources.insert(imageSource)
                startImage(with: imageSource)
            }
        }
        
        for imageSource in activeImageSources {
            if !imageSources.contains(imageSource) {
                activeImageSources.remove(imageSource)
                stopImage(with: imageSource)
            }
        }
    }
}

#if !os(visionOS)

extension AGGraphRenderer {
    
    private func startCamera(position: Graphic.CameraPosition) {
        print("AsyncGraphics - Graph - Camera - Start")
        let task = Task {
            for await graphic in try Graphic.camera(at: position) {
                let resizedGraphic: Graphic
                if let maximumResolution: CGSize = activeCameraMaximumResolutions[position],
                   graphic.width > maximumResolution.width,
                   graphic.height > maximumResolution.height {
                    let targetResolution: CGSize = graphic.resolution.place(in: maximumResolution, placement: .fill)
                    resizedGraphic = try await graphic.resized(to: targetResolution, method: .lanczos)
                } else {
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
        print("AsyncGraphics - Graph - Camera - Stop")
        guard let task = activeCameraTasks[position] else { return }
        task.cancel()
        activeCameraTasks.removeValue(forKey: position)
        activeCameraGraphics.removeValue(forKey: position)
        activeCameraResolutions.removeValue(forKey: position)
    }
}

#endif

extension AGGraphRenderer {
    
    private func startVideo(with videoPlayer: GraphicVideoPlayer) {
        print("AsyncGraphics - Graph - Video - Start")
        let task = Task {
            for await graphic in Graphic.playVideo(with: videoPlayer) {
                let resizedGraphic: Graphic
                if let maximumResolution: CGSize = activeVideoMaximumResolutions[videoPlayer],
                   graphic.width > maximumResolution.width,
                   graphic.height > maximumResolution.height {
                    let targetResolution: CGSize = graphic.resolution.place(in: maximumResolution, placement: .fill)
                    resizedGraphic = try await graphic.resized(to: targetResolution, method: .lanczos)
                } else {
                    resizedGraphic = graphic
                }
                await MainActor.run {
                    activeVideoGraphics[videoPlayer] = resizedGraphic
                }
            }
        }
        activeVideoTasks[videoPlayer] = task
    }
    
    private func stopVideo(with videoPlayer: GraphicVideoPlayer) {
        print("AsyncGraphics - Graph - Video - Stop")
        guard let task = activeVideoTasks[videoPlayer] else { return }
        task.cancel()
        activeVideoTasks.removeValue(forKey: videoPlayer)
        activeVideoGraphics.removeValue(forKey: videoPlayer)
    }
}

extension AGGraphRenderer {
    
    private func startImage(with imageSource: AGImage.Source) {
        print("AsyncGraphics - Graph - Video - Start")
        Task {
            let graphic: Graphic
            switch imageSource {
            case .name(let name):
                graphic = try await .image(named: name)
            case .raw(let image):
                graphic = try await .image(image)
            }
            let resizedGraphic: Graphic
            if let maximumResolution: CGSize = activeImageMaximumResolutions[imageSource],
               graphic.width > maximumResolution.width,
               graphic.height > maximumResolution.height {
                let targetResolution: CGSize = graphic.resolution.place(in: maximumResolution, placement: .fill)
                resizedGraphic = try await graphic.resized(to: targetResolution, method: .lanczos)
            } else {
                resizedGraphic = graphic
            }
            await MainActor.run {
                activeImageGraphics[imageSource] = resizedGraphic
                activeImageResolutions[imageSource] = graphic.resolution
            }
        }
    }
    
    private func stopImage(with imageSource: AGImage.Source) {
        print("AsyncGraphics - Graph - Video - Stop")
        activeImageGraphics.removeValue(forKey: imageSource)
        activeImageResolutions.removeValue(forKey: imageSource)
    }
}

extension AGGraphRenderer {
    
    #if !os(visionOS)
    
    private func cameraPositions(for graph: any AGGraph) -> Set<Graphic.CameraPosition> {
        var cameraPositions: Set<Graphic.CameraPosition> = []
        if let camera = graph as? AGCamera {
            cameraPositions.insert(camera.position)
        }
        if let parentGraph = graph as? any AGParentGraph {
            for child in parentGraph.children.all {
                cameraPositions.formUnion(self.cameraPositions(for: child))
            }
        }
        return cameraPositions
    }
    
    #endif
    
    private func videoPlayers(for graph: any AGGraph) -> Set<GraphicVideoPlayer> {
        var videoPlayers: Set<GraphicVideoPlayer> = []
        if let video = graph as? AGVideo {
            videoPlayers.insert(video.videoPlayer)
        }
        if let parentGraph = graph as? any AGParentGraph {
            for child in parentGraph.children.all {
                videoPlayers.formUnion(self.videoPlayers(for: child))
            }
        }
        return videoPlayers
    }
    
    private func imageSources(for graph: any AGGraph) -> Set<AGImage.Source> {
        var imageSources: Set<AGImage.Source> = []
        if let image = graph as? AGImage {
            imageSources.insert(image.source)
        }
        if let parentGraph = graph as? any AGParentGraph {
            for child in parentGraph.children.all {
                imageSources.formUnion(self.imageSources(for: child))
            }
        }
        return imageSources
    }
}

extension AGGraphRenderer {
    
    #if !os(visionOS)
    
    private func cameraMaximumResolutions(for graph: any AGGraph, at proposedResolution: CGSize, for specification: AGSpecification) -> [Graphic.CameraPosition: CGSize] {
        var maximumResolutions: [Graphic.CameraPosition: CGSize] = [:]
        if let camera = graph as? AGCamera {
            maximumResolutions[camera.position] = camera.resolution(at: proposedResolution, for: specification)
        }
        if let parentGraph = graph as? any AGParentGraph {
            let parentProposedResolution: CGSize = parentGraph.resolution(at: proposedResolution, for: specification)
            for child in parentGraph.children.all {
                for (cameraPosition, maximumResolution) in cameraMaximumResolutions(for: child, at: parentProposedResolution, for: specification) {
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
    
    #endif
    
    private func videoMaximumResolutions(for graph: any AGGraph, at proposedResolution: CGSize, for specification: AGSpecification) -> [GraphicVideoPlayer: CGSize] {
        var maximumResolutions: [GraphicVideoPlayer: CGSize] = [:]
        if let video = graph as? AGVideo {
            maximumResolutions[video.videoPlayer] = video.resolution(at: proposedResolution, for: specification)
        }
        if let parentGraph = graph as? any AGParentGraph {
            let parentProposedResolution: CGSize = parentGraph.resolution(at: proposedResolution, for: specification)
            for child in parentGraph.children.all {
                for (videoPlayer, maximumResolution) in videoMaximumResolutions(for: child, at: parentProposedResolution, for: specification) {
                    if let currentMaximumResolution: CGSize = maximumResolutions[videoPlayer] {
                        maximumResolutions[videoPlayer] = CGSize(
                            width: max(currentMaximumResolution.width, maximumResolution.width),
                            height: max(currentMaximumResolution.height, maximumResolution.height))
                    } else {
                        maximumResolutions[videoPlayer] = maximumResolution
                    }
                }
            }
        }
        return maximumResolutions
    }
    
    private func imageMaximumResolutions(for graph: any AGGraph, at proposedResolution: CGSize, for specification: AGSpecification) -> [AGImage.Source: CGSize] {
        var maximumResolutions: [AGImage.Source: CGSize] = [:]
        if let image = graph as? AGImage {
            maximumResolutions[image.source] = image.resolution(at: proposedResolution, for: specification)
        }
        if let parentGraph = graph as? any AGParentGraph {
            let parentProposedResolution: CGSize = parentGraph.resolution(at: proposedResolution, for: specification)
            for child in parentGraph.children.all {
                for (videoPlayer, maximumResolution) in imageMaximumResolutions(for: child, at: parentProposedResolution, for: specification) {
                    if let currentMaximumResolution: CGSize = maximumResolutions[videoPlayer] {
                        maximumResolutions[videoPlayer] = CGSize(
                            width: max(currentMaximumResolution.width, maximumResolution.width),
                            height: max(currentMaximumResolution.height, maximumResolution.height))
                    } else {
                        maximumResolutions[videoPlayer] = maximumResolution
                    }
                }
            }
        }
        return maximumResolutions
    }
}
