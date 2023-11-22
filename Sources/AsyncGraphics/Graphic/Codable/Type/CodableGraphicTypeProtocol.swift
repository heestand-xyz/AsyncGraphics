
protocol CodableGraphicTypeProtocol: RawRepresentable, Codable, Equatable, CaseIterable, Identifiable {
    var name: String { get }
}
