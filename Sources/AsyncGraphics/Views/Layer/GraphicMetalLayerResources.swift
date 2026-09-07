//
//  GraphicMetalLayerResources.swift
//  AsyncGraphics
//

import Metal

/// Immutable GPU resources shared by all graphic layers on the UI actor.
@MainActor
final class GraphicMetalLayerResources {
    static let shared = GraphicMetalLayerResources()

    let commandQueue: MTLCommandQueue
    let standardPipeline: MTLRenderPipelineState
    let extendedPipeline: MTLRenderPipelineState
    let linearSampler: MTLSamplerState
    let nearestSampler: MTLSamplerState

    private init() {
        let device = Renderer.metalDevice
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("GraphicMetalLayerResources: Could not create a command queue.")
        }
        self.commandQueue = commandQueue
        do {
            let library = try device.makeDefaultLibrary(bundle: .module)
            guard let vertex = library.makeFunction(name: "graphicLayerVertex"),
                  let fragment = library.makeFunction(name: "graphicLayerFragment") else {
                fatalError("GraphicMetalLayerResources: Could not load presentation shaders.")
            }
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertex
            descriptor.fragmentFunction = fragment
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            standardPipeline = try device.makeRenderPipelineState(descriptor: descriptor)
            descriptor.colorAttachments[0].pixelFormat = .rgba16Float
            extendedPipeline = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError("GraphicMetalLayerResources: Could not create presentation pipelines: \(error)")
        }
        let descriptor = MTLSamplerDescriptor()
        descriptor.sAddressMode = .clampToEdge
        descriptor.tAddressMode = .clampToEdge
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        guard let linearSampler = device.makeSamplerState(descriptor: descriptor) else {
            fatalError("GraphicMetalLayerResources: Could not create a linear sampler.")
        }
        self.linearSampler = linearSampler
        descriptor.minFilter = .nearest
        descriptor.magFilter = .nearest
        guard let nearestSampler = device.makeSamplerState(descriptor: descriptor) else {
            fatalError("GraphicMetalLayerResources: Could not create a nearest sampler.")
        }
        self.nearestSampler = nearestSampler
    }
}
