import Foundation

extension Graphic {
    
    private struct ABStackUniforms {
        let axis: Int32
        let alignment: Int32
        let spacing: Float
    }
    
    func vStacked(with graphic: Graphic,
                  alignment: VStackAlignment = .center,
                  spacing: CGFloat = 0.0) async throws -> Graphic {
        
        try await vStacked(alignment: alignment, spacing: spacing, graphic: { graphic })
    }
    
    @available(*, deprecated, renamed: "vStacked(with:alignment:spacing:)")
    func vStacked(alignment: VStackAlignment = .center,
                  spacing: CGFloat = 0.0,
                  graphic: () async throws -> Graphic) async throws -> Graphic {
        
        let graphic: Graphic = try await graphic()
        
        let resolution = CGSize(width: max(resolution.width, graphic.resolution.width),
                                height: resolution.height + spacing + graphic.resolution.height)
        
        return  try await Renderer.render(
            name: "ABStack",
            shader: .name("abStack"),
            graphics: [
                self,
                graphic
            ],
            uniforms: ABStackUniforms(
                axis: Int32(StackAxis.vertical.rawValue),
                alignment: Int32(alignment.rawValue),
                spacing: Float(spacing)
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
    
    func hStacked(with graphic: Graphic,
                  alignment: HStackAlignment = .center,
                  spacing: CGFloat = 0.0) async throws -> Graphic {
        
        try await hStacked(alignment: alignment, spacing: spacing, graphic: { graphic })
    }
    
    @available(*, deprecated, renamed: "hStacked(with:alignment:spacing:)")
    func hStacked(alignment: HStackAlignment = .center,
                  spacing: CGFloat = 0.0,
                  graphic: () async throws -> Graphic) async throws -> Graphic {
        
        let graphic: Graphic = try await graphic()
        
        let resolution = CGSize(width: resolution.width + spacing + graphic.resolution.width,
                                height: max(resolution.height, graphic.resolution.height))
        return try await Renderer.render(
            name: "ABStack",
            shader: .name("abStack"),
            graphics: [
                self,
                graphic
            ],
            uniforms: ABStackUniforms(
                axis: Int32(StackAxis.horizontal.rawValue),
                alignment: Int32(-alignment.rawValue),
                spacing: Float(spacing)
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
}
