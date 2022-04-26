//
//  Created by Anton Heestand on 2022-04-26.
//

import Metal

extension Renderer {
    
    static func sampler(addressMode: MTLSamplerAddressMode) throws -> MTLSamplerState {
        let samplerInfo = MTLSamplerDescriptor()
        samplerInfo.minFilter = .linear
        samplerInfo.magFilter = .linear
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
