//
//  Created by Anton Heestand on 2022-04-24.
//

#if !os(visionOS)

import MetalKit
import MetalPerformanceShaders
import QuartzCore.CoreAnimation
import TextureMap

final class GraphicMetalView: MTKView, GraphicMetalViewable {
    
    private var graphic: Graphic?
    
    let interpolation: Graphic.ViewInterpolation
    
    var extendedDynamicRange: Bool
    
    let didRender: (UUID) -> ()
 
    init(interpolation: Graphic.ViewInterpolation,
         extendedDynamicRange: Bool,
         didRender: @escaping (UUID) -> ()) {
        
        self.interpolation = interpolation
        self.extendedDynamicRange = extendedDynamicRange
        self.didRender = didRender
        
        super.init(frame: .zero, device: Renderer.metalDevice)
        
        clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
        colorPixelFormat = extendedDynamicRange ? .rgba16Float : .rgba8Unorm // .bgra10_xr (Display P3)
        framebufferOnly = false
        autoResizeDrawable = true
        enableSetNeedsDisplay = true
        isPaused = true
        
        #if os(macOS)
        wantsLayer = true
        layer?.isOpaque = false
        #else
        isOpaque = false
        #endif
        
        delegate = self
        
        set(extendedDynamicRange: extendedDynamicRange)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GraphicMetalView {
    
    func set(extendedDynamicRange: Bool) {
        if #available(macOS 10.11, iOS 16.0, *) {
            (layer as! CAMetalLayer).wantsExtendedDynamicRangeContent = extendedDynamicRange
        }
        self.extendedDynamicRange = extendedDynamicRange
    }
}

extension GraphicMetalView {
    
    func render(graphic: Graphic) async {
                
        self.graphic = graphic
        
        draw()
    }
   
    #if !os(macOS)
    override func layoutSubviews() {
        super.layoutSubviews()
        
        draw()
    }
    #endif
}

extension GraphicMetalView: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        
        guard let graphic: Graphic = graphic else { return }
        let texture: MTLTexture = graphic.texture
        
        guard let drawable: CAMetalDrawable = currentDrawable else { return }
        let targetTexture: MTLTexture = drawable.texture
        
        guard let commandQueue = Renderer.metalDevice.makeCommandQueue() else { return } // EXC_BREAKPOINT
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else { return }

        if !extendedDynamicRange,
           graphic.bits == ._8,
           targetTexture.width == texture.width,
           targetTexture.height == texture.height,
           let blitEncoder = commandBuffer.makeBlitCommandEncoder() {
           
            blitEncoder.copy(from: texture,
                             sourceSlice: 0,
                             sourceLevel: 0,
                             sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                             sourceSize: MTLSizeMake(texture.width, texture.height, 1),
                             to: targetTexture,
                             destinationSlice: 0,
                             destinationLevel: 0,
                             destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
            blitEncoder.endEncoding()
            
        } else {
            
            let scaleKernel: MPSImageScale
            if interpolation == .bilinear {
                scaleKernel = MPSImageBilinearScale(device: Renderer.metalDevice)
            } else {
                scaleKernel = MPSImageLanczosScale(device: Renderer.metalDevice)
            }
            scaleKernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: targetTexture)
        }
        
        commandBuffer.addCompletedHandler { [weak self] _ in
            self?.didRender(graphic.id)
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

#endif
