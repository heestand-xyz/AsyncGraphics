//
//  blend_header.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-07.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#ifndef BLENDS
#define BLENDS

float4 blends(int mode, float2 uv, texture2d_array<float> textures, sampler s);

#endif
