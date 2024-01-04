
public protocol GraphicEnum: RawRepresentable, Codable, CaseIterable, Identifiable, Hashable {
    var name: String { get }
    var index: UInt32 { get }
}
