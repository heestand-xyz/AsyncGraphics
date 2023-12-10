//
//  File.swift
//  
//
//  Created by Anton Heestand on 2023-11-13.
//

import Foundation

protocol GraphicMetalViewable {
    var interpolation: ViewInterpolation { get }
    var extendedDynamicRange: Bool { get set }
    var didRender: (UUID) -> () { get }
}
