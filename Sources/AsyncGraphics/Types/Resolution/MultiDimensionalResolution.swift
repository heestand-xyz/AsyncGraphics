//
//  Created by Anton Heestand on 2022-04-11.
//

import Spatial
import CoreGraphics

protocol MultiDimensionalResolution {}

extension CGSize: MultiDimensionalResolution {}

extension Size3D: MultiDimensionalResolution {}
