//
//  gradient_header.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-02.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#ifndef RADIUS
#define RADIUS

float4 radiusColor(float radius, float targetRadius, float edgeRadius, float4 foregroundColor, float4 edgeColor, float4 backgroundColor, bool antiAlias, bool premultiply, float onePixel);

#endif
