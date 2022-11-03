//
//  place_header.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-07.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#ifndef PLACE
#define PLACE

float2 place(int place, float2 uv, uint leadingWidth, uint leadingHeight, uint trailingWidth, uint trailingHeight);
float unitPlace(int place, uint leadingWidth, uint leadingHeight, uint trailingWidth, uint trailingHeight);
float3 place3d(int place, float3 uvw, uint leadingWidth, uint leadingHeight, uint leadingDepth, uint trailingWidth, uint trailingHeight, uint trailingDepth);

#endif
