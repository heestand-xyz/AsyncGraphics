//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-11-13.
//

import Foundation

protocol GraphicRenderView {
    var interpolation: GraphicView.Interpolation { get }
    var extendedDynamicRange: Bool { get set }
    var didRender: (UUID) -> () { get }
    func render(graphic: Graphic)
}
