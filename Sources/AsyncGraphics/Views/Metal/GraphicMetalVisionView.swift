//
//  Created by Anton Heestand on 2022-04-24.
//

#if os(visionOS)

import MetalKit
import MetalPerformanceShaders
import QuartzCore.CoreAnimation
import TextureMap

final class GraphicMetalVisionView: UIView, GraphicMetalViewable {
    
    private var graphic: Graphic?
    
    let interpolation: Graphic.ViewInterpolation
    
    var extendedDynamicRange: Bool
    
    let autoDraw: Bool
    
    let metalLayer: CAMetalLayer
    
    let didRender: (UUID) -> ()
 
    init(interpolation: Graphic.ViewInterpolation, 
         extendedDynamicRange: Bool,
         autoDraw: Bool,
         didRender: @escaping (UUID) -> ()) {
        
        self.interpolation = interpolation
        self.extendedDynamicRange = extendedDynamicRange
        self.autoDraw = autoDraw
        self.didRender = didRender
        
        metalLayer = CAMetalLayer()
        
        super.init(frame: .zero)
        
        metalLayer.isOpaque = false
        metalLayer.device = Renderer.metalDevice
        metalLayer.pixelFormat = extendedDynamicRange ? .rgba16Float : .rgba8Unorm // .bgra10_xr (Display P3)
        metalLayer.delegate = self
        metalLayer.framebufferOnly = false
        
        set(extendedDynamicRange: extendedDynamicRange)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GraphicMetalVisionView {
    
    func set(extendedDynamicRange: Bool) {
        if #available(macOS 10.11, iOS 16.0, *) {
            metalLayer.wantsExtendedDynamicRangeContent = extendedDynamicRange
        }
        self.extendedDynamicRange = extendedDynamicRange
    }
}

extension GraphicMetalVisionView {

//    func renderNeedsDisplay(graphic: Graphic) async {
//        self.graphic = graphic
//        setNeedsDisplay()
//    }
    
    @discardableResult
    func render(graphic: Graphic) async -> Bool {
        await withCheckedContinuation { continuation in
            render(graphic: graphic) { success in
                continuation.resume(returning: success)
            }
        }
    }
    
    func render(graphic: Graphic, completion: @escaping (Bool) -> ()) {
                
        metalLayer.drawableSize = graphic.resolution
        self.graphic = graphic
        
        draw(completion: completion)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        metalLayer.frame = bounds
        
        if self.layer.sublayers?.isEmpty != false {
            layer.addSublayer(metalLayer)
        }
        
        draw { _ in }
    }
}

extension GraphicMetalVisionView {
        
    func draw(completion: @escaping (Bool) -> ()) {
        guard let graphic: Graphic = graphic else {
            completion(false)
            return
        }
        let texture: MTLTexture = graphic.texture
        
        guard let drawable: CAMetalDrawable = metalLayer.nextDrawable() else {
            completion(false)
            return
        }
        let targetTexture: MTLTexture = drawable.texture
        
        guard let commandQueue = Renderer.metalDevice.makeCommandQueue() else {
            completion(false)
            return
        } // EXC_BREAKPOINT
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            completion(false)
            return
        }
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
            print("----<<< draw done!")
            self?.didRender(graphic.id)
            completion(true)
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

#endif
