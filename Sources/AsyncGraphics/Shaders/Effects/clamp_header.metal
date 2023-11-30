//
//  place_header.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-07.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#ifndef CLAMP
#define CLAMP

float clampValue(float value, float low, float high, int type);

#endif
