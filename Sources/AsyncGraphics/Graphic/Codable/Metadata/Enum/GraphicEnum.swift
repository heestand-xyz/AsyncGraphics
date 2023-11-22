
public protocol GraphicEnum: RawRepresentable, Codable, CaseIterable, Identifiable {
    var name: String { get }
}
