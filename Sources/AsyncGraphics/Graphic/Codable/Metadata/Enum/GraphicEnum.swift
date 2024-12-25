
public protocol GraphicEnum: RawRepresentable, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    var name: String { get }
    var index: UInt32 { get }
}
