//
//  Created by Anton Heestand on 2022-04-03.
//

protocol RawUniform {
    var size: Int { get }
}

extension Bool: RawUniform {
    var size: Int { MemoryLayout<Bool>.size }
}

extension Int: RawUniform {
    var size: Int { MemoryLayout<Int>.size }
}

extension Float: RawUniform {
    var size: Int { MemoryLayout<Float>.size }
}
