//
//  Created by Anton Heestand on 2022-04-21.
//

import Metal
import PixelColor

extension Renderer {
    
    static func commandEncoder(texture: MTLTexture, clearColor: PixelColor = .clear, commandBuffer: MTLCommandBuffer) throws -> MTLRenderCommandEncoder {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: clearColor.red, green: clearColor.green, blue: clearColor.blue, alpha: clearColor.alpha)
        guard let commandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            throw RendererError.failedToMakeCommandEncoder
        }
        return commandEncoder
    }
}
