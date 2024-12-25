//
//  File.swift
//  
//
//  Created by Anton Heestand on 2023-11-13.
//

import Foundation

protocol GraphicMetalViewable {
    var interpolation: Graphic.ViewInterpolation { get }
    @MainActor
    var extendedDynamicRange: Bool { get set }
    @MainActor
    var didRender: (UUID) -> () { get }
}
