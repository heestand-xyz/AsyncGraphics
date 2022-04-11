//
//  Created by Anton Heestand on 2022-04-11.
//

import simd
import CoreGraphics

public protocol Resolution {}

extension CGSize: Resolution {}

extension SIMD3: Resolution where Scalar == Int {}
