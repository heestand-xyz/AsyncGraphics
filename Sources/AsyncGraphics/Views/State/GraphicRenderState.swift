//
//  File.swift
//  
//
//  Created by Anton Heestand on 2023-11-15.
//

import Foundation

public enum GraphicRenderState {
    case inProgress(id: UUID)
    case done(id: UUID)
}
