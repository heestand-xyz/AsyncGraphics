//
//  Graphic+TaskGroup.swift
//  AsyncGraphics
//
//  Created by a-heestand on 2025/01/27.
//

extension Array where Element: Sendable {
    /// A concurrent map based on a task group
    public func asyncMap(
        _ convert: @escaping @Sendable (Element) async throws -> Graphic
    ) async rethrows -> [Graphic] {
        try await withThrowingTaskGroup(of: (Int, Graphic?).self) { group in
            for (index, value) in enumerated() {
                group.addTask {
                    (index, try await convert(value))
                }
            }
            var graphics = Array<Graphic?>(repeating: nil, count: count)
            for try await (index, graphic) in group {
                graphics[index] = graphic
            }
            return graphics.compactMap({ $0 })
        }
    }
}
