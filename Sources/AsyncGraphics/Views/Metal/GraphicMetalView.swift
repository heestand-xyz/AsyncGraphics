//
//  Created by Anton Heestand on 2022-04-24.
//

#if !os(visionOS)

@preconcurrency import MetalKit
import MetalPerformanceShaders
@preconcurrency import QuartzCore.CoreAnimation
import CoreGraphics
import TextureMap

final class GraphicMetalView: MTKView, GraphicMetalViewable {
    
    private var graphic: Graphic?
    
    let interpolation: Graphic.ViewInterpolation
    
    @MainActor
    var extendedDynamicRange: Bool
    
    @MainActor
    let didRender: (UUID) -> ()
    
    private var metalQueue: DispatchQueue?
    private let metalQueueKey = DispatchSpecificKey<String>()
    
    private var commandQueue: MTLCommandQueue?
    
    init(interpolation: Graphic.ViewInterpolation,
         extendedDynamicRange: Bool,
         didRender: @escaping (UUID) -> ()) {
        
        self.interpolation = interpolation
        self.extendedDynamicRange = extendedDynamicRange
        self.didRender = didRender
        
        super.init(frame: .zero, device: Renderer.metalDevice)
        
        metalQueue = DispatchQueue(label: "GraphicMetalView")
        metalQueue?.setSpecific(key: metalQueueKey, value: "GraphicMetalView")
        
        commandQueue = Renderer.metalDevice.makeCommandQueue()
        
        clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
        colorPixelFormat = pixelFormat()
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

// MARK: - Pixel Format

extension GraphicMetalView {
    private func pixelFormat() -> MTLPixelFormat {
        extendedDynamicRange ? .rgba16Float : .rgba8Unorm
        // .bgra10_xr (Display P3)
    }
}

// MARK: - XDR

extension GraphicMetalView {
    
    func set(extendedDynamicRange: Bool) {
        self.extendedDynamicRange = extendedDynamicRange
        colorPixelFormat = pixelFormat()
        let colorSpace = CGColorSpace(name: extendedDynamicRange ? CGColorSpace.extendedLinearDisplayP3 : CGColorSpace.sRGB)
        (layer as! CAMetalLayer).colorspace = colorSpace
#if !os(tvOS)
        if #available(macOS 10.11, iOS 16.0, *) {
            (layer as! CAMetalLayer).wantsExtendedDynamicRangeContent = extendedDynamicRange
        }
#endif
    }
}

// MARK: - Render

extension GraphicMetalView {
    
    @MainActor
    func render(graphic: Graphic) {
                
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

// MARK: - Draw

extension GraphicMetalView: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let metalQueue else { return }

        guard let graphic: Graphic = graphic else { return }
        let sourceTexture: MTLTexture = graphic.texture
        
        guard let drawable: CAMetalDrawable = currentDrawable else { return }
        let destinationTexture: MTLTexture = drawable.texture
        
        guard let commandQueue else { return }
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        if !extendedDynamicRange,
           graphic.bits == ._8,
           destinationTexture.pixelFormat == .rgba8Unorm,
           destinationTexture.width == sourceTexture.width,
           destinationTexture.height == sourceTexture.height,
           let blitEncoder = commandBuffer.makeBlitCommandEncoder() {
            
            blitEncoder.copy(from: sourceTexture,
                             sourceSlice: 0,
                             sourceLevel: 0,
                             sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                             sourceSize: MTLSizeMake(sourceTexture.width, sourceTexture.height, 1),
                             to: destinationTexture,
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
            scaleKernel.encode(commandBuffer: commandBuffer, sourceTexture: sourceTexture, destinationTexture: destinationTexture)
        }
        
        metalQueue.async {
            
            commandBuffer.addCompletedHandler { [weak self] _ in
                let id: UUID = graphic.id
                guard let self else { return }
                Task { @MainActor in
                    self.didRender(id)
                }
            }
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

// MARK: - Draw with Shader

extension GraphicMetalView {
    
    @available(*, deprecated)
    private func drawWithShader() {
        Task {
            guard let graphic = graphic else { return }
            guard let drawable = currentDrawable else { return }
            guard let commandQueue else { return }
            guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }

            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = drawable.texture
            passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
            passDescriptor.colorAttachments[0].loadAction = .clear
            passDescriptor.colorAttachments[0].storeAction = .store
            
            guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else { return }
        
            do {
                encoder.setFragmentTexture(graphic.texture, index: 0)

                let pipeline = try await pipeline()
                encoder.setRenderPipelineState(pipeline)

                let sampler: MTLSamplerState = try Renderer.sampler(addressMode: .clampToZero, filter: .linear)
                encoder.setFragmentSamplerState(sampler, index: 0)

                let vertexBuffer: MTLBuffer
                if await Renderer.optimization.contains(.cacheQuadVertexBuffer),
                   let buffer = Renderer.storedVertexQuadBuffer {
                    vertexBuffer = buffer
                } else {
                    vertexBuffer = try Renderer.makeVertexQuadBuffer()
                }
                encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                
                encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
                
                encoder.endEncoding()
                commandBuffer.addCompletedHandler { [weak self] _ in
                    Task { @MainActor in
                        self?.didRender(graphic.id)
                    }
                }
                commandBuffer.present(drawable)
                commandBuffer.commit()
            } catch {
                encoder.endEncoding()
                print("AsyncGraphic GraphicMetalView Error: \(error)")
            }
        }
    }
    
    @available(*, deprecated)
    @RenderActor
    private func pipeline() async throws -> MTLRenderPipelineState {
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.label = "GraphicMetalView"
        pipeline.fragmentFunction = try Renderer.shader(name: "fragmentPassthrough")
        pipeline.vertexFunction = try Renderer.shader(name: "vertexPassthrough")
        pipeline.colorAttachments[0].pixelFormat = await pixelFormat()
        pipeline.colorAttachments[0].isBlendingEnabled = true
        pipeline.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        return try await Renderer.metalDevice.makeRenderPipelineState(descriptor: pipeline)
    }
}

#endif
