//
//  SwiftUIView.swift
//  
//
//  Created by Anton on 2023/07/20.
//

import SwiftUI
import CoreGraphicsExtensions

public struct AsyncGraphicView: View {
    
    private let resolution: CGSize?
    private let graphicBlock: (CGSize) async throws -> Graphic
    @State private var graphic: Graphic?
    
    @available(*, deprecated, renamed: "init(resolution:_:)",
                message: "The new init's graphic closure has a new resolution argument.")
    public init(
        resolution: CGSize? = nil,
        graphic: @escaping () async throws -> Graphic
    ) {
        self.resolution = resolution
        self.graphicBlock = { _ in try await graphic() }
    }
    
    /// The default resolution is derived from the view's geometry size multiplied by pixels per point.
    public init(
        resolution: CGSize? = nil,
        _ graphic: @escaping (CGSize) async throws -> Graphic
    ) {
        self.resolution = resolution
        self.graphicBlock = graphic
    }
    
    public var body: some View {
        GeometryReader { geometry in
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
                    let resolution: CGSize = resolution ?? geometry.size * CGFloat.pixelsPerPoint
                    graphic = try await graphicBlock(resolution)
                } catch {
                    print("AsyncGraphics - AsyncGraphicView - Failed to Render:", error)
                }
            }
        }
        .aspectRatio(graphic?.resolution.aspectRatio, contentMode: .fit)
    }
}
