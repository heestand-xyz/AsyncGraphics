//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023/02/06.
//

import CoreGraphics

public struct GBlend: G {
    
    let leading: any G
    let trailing: any G
    
    let blendingMode: BlendingMode
    
    public init(mode: BlendingMode,
                _ leading: @escaping () -> any G,
                with trailing: @escaping () -> any G) {
        blendingMode = mode
        self.leading = leading()
        self.trailing = trailing()
    }
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        let leadingGraphic: Graphic = try await leading.render(at: resolution)
        let trailingGraphic: Graphic = try await trailing.render(at: resolution)
        return try await leadingGraphic.blended(with: trailingGraphic, blendingMode: blendingMode)
    }
}

extension GBlend: Equatable {

    public static func == (lhs: GBlend, rhs: GBlend) -> Bool {
        guard lhs.blendingMode == rhs.blendingMode else { return false }
        guard lhs.leading.isEqual(to: rhs.leading) else { return false }
        guard lhs.trailing.isEqual(to: rhs.trailing) else { return false }
        return true
    }
}

extension GBlend: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(blendingMode)
        hasher.combine(leading)
        hasher.combine(trailing)
    }
}
