//
//  Created by Anton Heestand on 2022-12-10.
//

#if os(visionOS)

import SwiftUI
import Spatial
import CoreGraphicsExtensions

/// SwiftUI view for rendering and displaying ``Graphic3D``s.
public struct Graphic3DImageRenderView: View {
    
    @Bindable private var renderer: Graphic3DImageRenderer
    
    public init(renderer: Graphic3DImageRenderer) {
        _renderer = Bindable(renderer)
    }
    
    public var body: some View {
        GeometryReader { containerGeometry in
            ZStack {
                Color.clear
                if let resolution: Size3D = renderer.resolution {
                    ForEach(Array(0..<Int(resolution.depth)), id: \.self) { index in
                        GeometryReader { contentGeometry in
                            if isLayerVisible(at: index) {
                                Group {
                                    if let cropFrame: Rect3D = renderer.cropFrame {
                                        renderer.images[index]
                                            .resizable()
                                            .mask {
                                                mask(
                                                    size: contentGeometry.size,
                                                    resolution: resolution,
                                                    cropFrame: cropFrame
                                                )
                                            }
                                    } else {
                                        renderer.images[index]
                                            .resizable()
                                    }
                                }
                                .offset(z: {
                                    let count: Int = max(2, Int(resolution.depth))
                                    let fraction: CGFloat = CGFloat(index) / CGFloat(count - 1)
                                    let depthAspectRatio: CGFloat = resolution.depth / resolution.height
                                    return fraction * contentGeometry.size.height * depthAspectRatio
                                }())
                            }
                        }
                        .aspectRatio(CGSize(width: resolution.width,
                                            height: resolution.height),
                                     contentMode: .fit)
                    }
                }
            }
            .onAppear {
                renderer.viewSize = containerGeometry.size
            }
            .onChange(of: containerGeometry.size) { _, newSize in
                renderer.viewSize = newSize
            }
        }
        .allowsHitTesting(false)
    }
    
    private func mask(size: CGSize, resolution: Size3D, cropFrame: Rect3D) -> some View {
        Rectangle()
            .frame(width: size.width * (cropFrame.size.width / resolution.size.width),
                   height: size.height * (cropFrame.size.height / resolution.size.height))
            .position(x: size.width * (cropFrame.center.x / resolution.size.width),
                      y: size.height * (cropFrame.center.y / resolution.size.height))
    }
    
    private func isLayerVisible(at index: Int) -> Bool {
        guard renderer.images.indices.contains(index) else { return false }
        if let cropFrame: Rect3D = renderer.cropFrame {
            guard index >= Int(cropFrame.min.z), index < Int(cropFrame.max.z) else { return false }
        }
        return true
    }
}

#endif
