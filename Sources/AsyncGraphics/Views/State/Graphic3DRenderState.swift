//
//  File.swift
//  
//
//  Created by Anton Heestand on 2023-11-15.
//

import Foundation

public enum Graphic3DRenderState {
    case inProgress(id: UUID, fractionComplete: CGFloat)
    case done(id: UUID)
}
