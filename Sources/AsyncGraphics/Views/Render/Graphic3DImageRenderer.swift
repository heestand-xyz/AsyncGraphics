import Foundation
import Spatial
import SwiftUI
import Spatial
import Observation
import CoreGraphicsExtensions
import TextureMap

#if os(visionOS)

@Observable
public final class Graphic3DImageRenderer {
    
#if os(visionOS)
    public static let defaultScale: CGFloat = 1.0
#else
    public static let defaultScale: CGFloat = .pixelsPerPoint
#endif
    public var scale: CGFloat = Graphic3DImageRenderer.defaultScale
    
    public var interpolation: Graphic.ViewInterpolation = .linear

    public var extendedDynamicRange: Bool = false

    public internal(set) var resolution: Size3D?
    public var cropFrame: Rect3D?
    
    var viewSize: CGSize?
    
    var viewResolution: CGSize? {
        guard let viewSize: CGSize else { return nil }
        guard let resolution: Size3D else { return nil }
        return CGSize(width: resolution.width, height: resolution.height)
            .place(in: viewSize * scale,
                   placement: .fit)
    }
    
    struct Display {
        var id: UUID
        let resolution: CGSize
    }
    private var display: Display?
    
    var images: [Image] = []
    
    public init() {}
    
    public func display(graphic3D: Graphic3D,
                        progress: ((Progress) -> ())? = nil) async throws {
        
        if resolution != graphic3D.resolution {
            await MainActor.run {
                resolution = graphic3D.resolution
            }
        }
        
        try await render(graphic3D: graphic3D, progress: progress)
    }
    
    public enum RenderError: String, Error {
        case renderFailed
        case viewNotReady
    }
    
    public struct Progress {
        public let index: Int
        public let count: Int
        public enum State: String {
            case sampling
            case interpolating
            case converting
        }
        public let state: State
        public var fraction: CGFloat {
            CGFloat(index) / CGFloat(count - 1)
        }
        public init(index: Int, count: Int, state: State) {
            self.index = index
            self.count = count
            self.state = state
        }
        class Manager {
            private let count: Int
            private var index: Int = 0
            private let progress: (Progress) -> ()
            init(count: Int, progress: @escaping (Progress) -> ()) {
                self.count = count
                self.progress = progress
            }
            func increment(state: State) {
                progress(Progress(index: index, count: count, state: state))
                index += 1
            }
            func set(index: Int, state: State) {
                progress(Progress(index: index, count: count, state: state))
                self.index = index
            }
            func reset(state: State) {
                progress(Progress(index: 0, count: count, state: state))
                index = 0
            }
        }
    }
    
    private func render(graphic3D: Graphic3D,
                        progress: ((Progress) -> ())? = nil) async throws {

        guard let viewResolution: CGSize else {
            throw RenderError.viewNotReady
        }
        
        let progressManager: Progress.Manager? = if let progress {
            Progress.Manager(count: Int(graphic3D.depth), progress: progress)
        } else { nil }
        
        var viewGraphics: [Graphic] = try await graphic3D.samples { progress in
            progressManager?.set(index: progress.index, state: .sampling)
        }
        
        progressManager?.reset(state: .interpolating)
        
        if interpolation != .linear {
    
            viewGraphics = try await withThrowingTaskGroup(of: (Int, Graphic).self) { [weak self] group in
                
                guard let self else { return [] }
                
                for (index, graphic) in viewGraphics.enumerated() {
                    
                    group.addTask {
                        
                        var graphic: Graphic = graphic
                        
                        switch self.interpolation {
                        case .nearestNeighbor:
                            graphic = try await graphic
                                .resized(to: viewResolution,
                                         placement: .stretch,
                                         options: .interpolateNearest)
                        case .lanczos, .bilinear:
                            let method: Graphic.ResizeMethod = self.interpolation == .lanczos ? .lanczos : .bilinear
                            graphic = try await graphic
                                .resized(to: viewResolution,
                                         placement: .stretch,
                                         method: method)
                        case .linear:
                            break
                        }
                        
                        progressManager?.increment(state: .interpolating)
                        
                        return (index, graphic)
                    }
                }
            
                var graphics: [Graphic?] = Array(repeating: nil, count: viewGraphics.count)
                for try await (index, graphic) in group {
                    graphics[index] = graphic
                }
                return graphics.compactMap { $0 }
            }
        }
        
        progressManager?.reset(state: .converting)
        
        let images: [Image] = try await withThrowingTaskGroup(of: (Int, Image).self) { group in
            
            for (index, graphic) in viewGraphics.enumerated() {
                
                group.addTask {
                    // Faster but crashes sometimes
//                    let tmImage: TMImage = if graphic.bits == ._8 {
//                        try await graphic.rawImage
//                    } else {
//                        try await graphic.image
//                    }
                    let tmImage: TMImage = try await graphic.image
                    let image = Image(tmImage: tmImage)
                    progressManager?.increment(state: .converting)
                    return (index, image)
                }
            }
            
            var images: [Image?] = Array(repeating: nil, count: viewGraphics.count)
            for try await (index, image) in group {
                images[index] = image
            }
            return images.compactMap { $0 }
        }
        
        await MainActor.run {
            self.images = images
        }
        
        display = Display(id: graphic3D.id,
                          resolution: viewGraphics.first!.resolution)
    }
    
    public func hide() {
        resolution = nil
        display = nil
        images = []
    }
}

#endif
