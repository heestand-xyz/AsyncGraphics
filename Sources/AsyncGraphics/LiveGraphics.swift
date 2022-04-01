//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import CoreGraphics
//import Logger

public class LiveGraphics {
    
    public static let shared = LiveGraphics()
    
    static let fallbackResolution = CGSize(width: 100, height: 100)
    
    init() {
//        Logger.frequency = .verbose
    }
    
}
