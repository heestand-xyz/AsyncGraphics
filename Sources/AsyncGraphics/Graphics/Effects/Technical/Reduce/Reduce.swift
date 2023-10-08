//
//  Created by Anton Heestand on 2022-04-02.
//

import MetalPerformanceShaders
import TextureMap
import PixelColor

extension Graphic {
    
    public enum ReduceAxis {
        case horizontal
        case vertical
    }
    
    public enum ReduceMethod {
        case average
        case minimum
        case maximum
        case sum
    }
    
    /// Reduce
    ///
    /// Reduction to a singe pixel
//    @available(iOS 14.0, tvOS 14, macOS 11, *)
    public func reduce(by sampleMethod: ReduceMethod) async throws -> PixelColor {
        
        let highBitGraphic = try await bits(._16)
        
        let rowGraphic = try await highBitGraphic.reduce(by: sampleMethod, axis: .vertical)
                
        let pixelGraphic = try await rowGraphic.reduce(by: sampleMethod, axis: .horizontal)
        
        return try await pixelGraphic.firstPixelColor
    }
    
    /// Reduce
    ///
    /// Reduction in sample axis x, gives you a column
    ///
    /// Reduction in sample axis y, gives you a row
    public func reduce(by sampleMethod: ReduceMethod, axis sampleAxis: ReduceAxis) async throws -> Graphic {
                
        let texture: MTLTexture = try await withCheckedThrowingContinuation { continuation in
            
            do {
                
                guard let commandQueue = Renderer.metalDevice.makeCommandQueue() else {
                    throw Renderer.RendererError.failedToMakeCommandQueue
                }
                
                guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
                    throw Renderer.RendererError.failedToMakeCommandBuffer
                }
                
                let texture: MTLTexture = try .empty(resolution: resolution(in: sampleAxis), bits: bits, usage: .write)
                
                let kernel: MPSImageReduceUnary = kernel(by: sampleMethod, in: sampleAxis)
                
                kernel.encode(commandBuffer: commandBuffer, sourceTexture: self.texture, destinationTexture: texture)
                
                commandBuffer.addCompletedHandler { _ in
                    
                    continuation.resume(returning: texture)
                }
                
                commandBuffer.commit()
                
            } catch {
                    
                continuation.resume(throwing: error)
            }
        }
        
        return Graphic(name: "Reduce", texture: texture, bits: bits, colorSpace: colorSpace)
    }
    
    private func resolution(in sampleAxis: ReduceAxis) -> CGSize {
        switch sampleAxis {
        case .horizontal:
            return CGSize(width: 1, height: resolution.height)
        case .vertical:
            return CGSize(width: resolution.width, height: 1)
        }
    }
    
    private func kernel(by sampleMethod: ReduceMethod, in sampleAxis: ReduceAxis) -> MPSImageReduceUnary {
        
        let device: MTLDevice = Renderer.metalDevice
        
        switch sampleAxis {
        case .horizontal:
            switch sampleMethod {
            case .average:
                return MPSImageReduceRowMean(device: device)
            case .minimum:
                return MPSImageReduceRowMin(device: device)
            case .maximum:
                return MPSImageReduceRowMax(device: device)
            case .sum:
                return MPSImageReduceRowSum(device: device)
            }
        case .vertical:
            switch sampleMethod {
            case .average:
                return MPSImageReduceColumnMean(device: device)
            case .minimum:
                return MPSImageReduceColumnMin(device: device)
            case .maximum:
                return MPSImageReduceColumnMax(device: device)
            case .sum:
                return MPSImageReduceColumnSum(device: device)
            }
        }
    }
}
