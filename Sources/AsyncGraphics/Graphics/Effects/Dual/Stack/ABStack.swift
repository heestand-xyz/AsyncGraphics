import Foundation

extension Graphic {
    
    private struct ABStackUniforms {
        let axis: Int32
        let alignment: Int32
    }
    
    func vStacked(with graphic: Graphic, alignment: VStackAlignment) async throws -> Graphic {
        
        let resolution = CGSize(width: max(resolution.width, graphic.resolution.width),
                                height: resolution.height + graphic.resolution.height)
        
        return  try await Renderer.render(
            name: "ABStack",
            shader: .name("abStack"),
            graphics: [
                self,
                graphic
            ],
            uniforms: ABStackUniforms(
                axis: Int32(StackAxis.vertical.rawValue),
                alignment: Int32(alignment.rawValue)
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
    
    func hStacked(with graphic: Graphic, alignment: HStackAlignment) async throws -> Graphic {
        
        let resolution = CGSize(width: resolution.width + graphic.resolution.width,
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
                alignment: Int32(-alignment.rawValue)
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
}
