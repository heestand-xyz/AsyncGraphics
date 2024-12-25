//
//  SendableImage.swift
//  AsyncGraphics
//
//  Created by Anton on 2024-12-24.
//

import TextureMap

public struct SendableImage: @unchecked Sendable {
    
    private let image: TMImage
    
    fileprivate init(image: TMImage) {
        self.image = image
    }
}

extension SendableImage {
    public func receive() -> TMImage {
        image
    }
}

extension TMImage {
    public func send() -> SendableImage {
        SendableImage(image: self)
    }
}
