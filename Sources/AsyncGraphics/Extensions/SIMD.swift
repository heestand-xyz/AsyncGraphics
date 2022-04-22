//
//  Created by Anton Heestand on 2022-04-22.
//

import simd

extension SIMD3 where Scalar == Int {
    
    var asDouble: SIMD3<Double> { SIMD3<Double>(Double(x), Double(y), Double(z)) }
}

extension SIMD3 where Scalar == Double {
    
    var asInt: SIMD3<Int> { SIMD3<Int>(Int(x), Int(y), Int(z)) }
}
