//
//  Created by Anton Heestand on 2022-12-10.
//

import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for rendering and displaying a ``Graphic``.
public struct GraphicImageRenderView: View {
    
    @ObservedObject private var renderer: GraphicImageRenderer
    
    public init(renderer: GraphicImageRenderer) {
        _renderer = ObservedObject(wrappedValue: renderer)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                if let resolution: CGSize = renderer.resolution,
                   let image: Image = renderer.image {
                    image
                        .resizable()
                        .aspectRatio(CGSize(width: resolution.width,
                                            height: resolution.height),
                                     contentMode: .fit)
                }
            }
            .onAppear {
                renderer.viewSize = geometry.size
            }
            .onChange(of: geometry.size) { newSize in
                renderer.viewSize = newSize
            }
        }
        .allowsHitTesting(false)
    }
}
