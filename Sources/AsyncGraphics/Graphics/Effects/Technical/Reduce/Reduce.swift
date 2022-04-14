//
//  Created by Anton Heestand on 2022-04-02.
//

import MetalPerformanceShaders
import TextureMap
import PixelColor

public extension Graphic {
    
    enum ReduceAxis {
        case x
        case y
    }
    
    enum ReduceMethod {
        case average
        case minimum
        case maximum
        case sum
    }
    
    /// Reduce
    ///
    /// Reduction to a singe pixel
//    @available(iOS 14.0, tvOS 14, macOS 11, *)
    func reduce(by sampleMethod: ReduceMethod) async throws -> PixelColor {
        
        let highBitGraphic = try await bits(._16)
        
        let rowGraphic = try await highBitGraphic.reduce(by: sampleMethod, in: .y)
                
        let pixelGraphic = try await rowGraphic.reduce(by: sampleMethod, in: .x)
        
        return try await pixelGraphic.firstPixelColor
    }
    
    /// Reduce
    ///
    /// Reduction in sample axis x, gives you a column
    ///
    /// Reduction in sample axis y, gives you a row
    func reduce(by sampleMethod: ReduceMethod, in sampleAxis: ReduceAxis) async throws -> Graphic {
                
        let texture: MTLTexture = try await withCheckedThrowingContinuation { continuation in
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                    
                    guard let commandQueue = Renderer.metalDevice.makeCommandQueue() else {
                        throw Renderer.RendererError.failedToMakeCommandQueue
                    }
                    
                    guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
                        throw Renderer.RendererError.failedToMakeCommandBuffer
                    }
         
                    let texture: MTLTexture = try TextureMap.emptyTexture(resolution: resolution(in: sampleAxis), bits: bits, usage: .write)
                    
                    let kernel: MPSImageReduceUnary = kernel(by: sampleMethod, in: sampleAxis)

                    kernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: texture)
                    
                    DispatchQueue.main.async {
                        continuation.resume(returning: texture)
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
        
        return Graphic(name: "Reduce", texture: texture, bits: bits, colorSpace: colorSpace)
    }
    
    private func resolution(in sampleAxis: ReduceAxis) -> CGSize {
        switch sampleAxis {
        case .x:
            return CGSize(width: 1, height: resolution.height)
        case .y:
            return CGSize(width: resolution.width, height: 1)
        }
    }
    
    private func kernel(by sampleMethod: ReduceMethod, in sampleAxis: ReduceAxis) -> MPSImageReduceUnary {
        
        let device: MTLDevice = Renderer.metalDevice
        
        switch sampleAxis {
        case .x:
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
        case .y:
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
