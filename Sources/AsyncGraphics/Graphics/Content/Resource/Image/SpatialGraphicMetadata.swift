//
//  SpatialGraphicMetadata.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-05-01.
//

public struct SpatialGraphicMetadata: Sendable {
    
    public static let `default` = SpatialGraphicMetadata()
    
    /// The baseline (distance between the centers of the two cameras), in millimeters.
    public let baselineInMillimeters: Double
    /// The horizontal field of view of each camera, in degrees.
    public let horizontalFOV: Double
    /// A horizontal presentation adjustment to apply as a fraction of the image width (-1...1).
    public let disparityAdjustment: Double
    
    /// Spatial Graphic Metadata
    /// - Parameters:
    ///   - baselineInMillimeters: The baseline (distance between the centers of the two cameras), in millimeters.
    ///   - horizontalFOV: The horizontal field of view of each camera, in degrees.
    ///   - disparityAdjustment: A horizontal presentation adjustment to apply as a fraction of the image width (-1...1).
    public init(
        baselineInMillimeters: Double = 64,
        horizontalFOV: Double = 60,
        disparityAdjustment: Double = 0.0
    ) {
        self.baselineInMillimeters = baselineInMillimeters
        self.horizontalFOV = horizontalFOV
        self.disparityAdjustment = disparityAdjustment
    }
}
