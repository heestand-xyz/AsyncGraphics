//
//  Created by Anton Heestand on 2022-04-24.
//

import MetalKit
import MetalPerformanceShaders
import QuartzCore.CoreAnimation
import TextureMap

final class GraphicMetalView: MTKView {
    
    private var graphic: Graphic?
 
    init() {
        
        super.init(frame: .zero, device: Renderer.metalDevice)
        
        clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
        
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
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GraphicMetalView {
    
    func render(graphic: Graphic) {
                
        self.graphic = graphic
        
        DispatchQueue.main.async { [weak self] in
            self?.draw()
        }
    }
}

extension GraphicMetalView: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        
        guard let graphic: Graphic = graphic else { return }
        let texture: MTLTexture = graphic.texture
        
//        texture = texture.convertColorSpace(from: CGColorSpace(name: CGColorSpace.linearSRGB)!, to: graphic.colorSpace.cgColorSpace)
        
        guard let drawable: CAMetalDrawable = currentDrawable else { return }
        let targetTexture: MTLTexture = drawable.texture

        guard let commandQueue = Renderer.metalDevice.makeCommandQueue() else { return }
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        let scaleKernel: MPSImageScale = MPSImageLanczosScale(device: Renderer.metalDevice)
        scaleKernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: targetTexture)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
