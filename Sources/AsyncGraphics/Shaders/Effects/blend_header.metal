//
//  blend_header.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-07.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#ifndef BLEND
#define BLEND

float4 blend(int mode, float4 ca, float4 cb);
float4 blendOver(float4 ca, float4 cb);

#endif
