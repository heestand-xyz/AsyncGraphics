//
//  SwiftUIView.swift
//  
//
//  Created by Anton on 2023/07/20.
//

import SwiftUI

public struct AsyncGraphicView: View {
    
    let resolution: CGSize?
    let graphicBlock: () async throws -> Graphic
    @State var graphic: Graphic?
    
    public init(resolution: CGSize? = nil,
                graphic: @escaping () async throws -> Graphic) {
        self.resolution = resolution
        self.graphicBlock = graphic
    }
    
    public var body: some View {
        ZStack {
            if let graphic {
                GraphicView(graphic: graphic)
            } else if let resolution {
                Color.clear
                    .aspectRatio(resolution, contentMode: .fit)
            }
        }
        .task {
            do {
                graphic = try await graphicBlock()
            } catch {
                print("AsyncGraphics - AsyncGraphicView - Failed to Render:", error)
            }
        }
    }
}
