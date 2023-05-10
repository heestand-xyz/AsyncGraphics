//
//  Created by Anton Heestand on 2022-04-26.
//

import Metal

extension Renderer {
    
    static func sampler(addressMode: MTLSamplerAddressMode, filter: MTLSamplerMinMagFilter) throws -> MTLSamplerState {
        let samplerInfo = MTLSamplerDescriptor()
        samplerInfo.minFilter = filter
        samplerInfo.magFilter = filter
        samplerInfo.sAddressMode = addressMode
        samplerInfo.tAddressMode = addressMode
        samplerInfo.rAddressMode = addressMode
        samplerInfo.compareFunction = .never
        guard let sampler = metalDevice.makeSamplerState(descriptor: samplerInfo) else {
            throw RendererError.failedToMakeSampler
        }
        return sampler
    }
}
