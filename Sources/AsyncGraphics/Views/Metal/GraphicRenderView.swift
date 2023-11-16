//
//  File.swift
//  
//
//  Created by Anton Heestand on 2023-11-13.
//

import Foundation

protocol GraphicRenderView {
    var interpolation: GraphicView.Interpolation { get }
    var extendedDynamicRange: Bool { get set }
    var didRender: (UUID) -> () { get }
    func render(graphic: Graphic)
}
