//
//  Created by Anton Heestand on 2022-04-11.
//

import simd
import CoreGraphics

protocol MultiDimensionalResolution {}

extension CGSize: MultiDimensionalResolution {}

extension SIMD3: MultiDimensionalResolution where Scalar == Int {}
