
protocol CodableGraphicTypeProtocol: RawRepresentable, Codable, Equatable, CaseIterable, Identifiable, Sendable {
    var name: String { get }
    var symbolName: String { get }
    var complexity: GraphicComplexity { get }
}
