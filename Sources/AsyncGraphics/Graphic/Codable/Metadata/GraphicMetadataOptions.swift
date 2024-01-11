//
//  GraphicMetadataOptions.swift
//
//
//  Created by Anton on 2024-01-11.
//

import Foundation

public struct GraphicMetadataOptions: OptionSet, Codable {
    
    public let rawValue: Int
    
    public static let spatial = GraphicMetadataOptions(rawValue: 1 << 0)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
