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
    /// If the resolution is nil, the graphic will re-render whenever the view size changes.
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
                } else {
                    Color.clear
                }
            }
            .task {
                do {
                    let resolution: CGSize = resolution ?? (geometry.size * CGFloat.pixelsPerPoint)
                    graphic = try await graphicBlock(resolution)
                } catch {
                    print("AsyncGraphics - AsyncGraphicView - Failed to Render:", error)
                }
            }
            .onChange(of: geometry.size) { _, newSize in
                guard resolution == nil else { return }
                Task {
                    do {
                        let resolution: CGSize = newSize * CGFloat.pixelsPerPoint
                        graphic = try await graphicBlock(resolution)
                    } catch {
                        print("AsyncGraphics - AsyncGraphicView - Failed to Re-render:", error)
                    }
                }
            }
        }
        .aspectRatio(resolution: resolution)
    }
}

extension View {
    @ViewBuilder
    fileprivate func aspectRatio(resolution: CGSize?) -> some View {
        if let resolution: CGSize {
            self.aspectRatio(resolution, contentMode: .fit)
        } else {
            self
        }
    }
}
