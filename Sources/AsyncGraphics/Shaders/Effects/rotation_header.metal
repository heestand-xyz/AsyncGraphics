//
//  hsv_header.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//

#include <metal_stdlib>
using namespace metal;

#ifndef ROTATE
#define ROTATE

float3 rotateRadians(float3 vector, float angle, float3 axis);
float3 rotateDegrees(float3 vector, float angle, float3 axis);

#endif
