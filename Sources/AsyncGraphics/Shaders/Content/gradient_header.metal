//
//  gradient_header.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-02.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#ifndef GRADIENT
#define GRADIENT

// Hardcoded. Defined as uniformArrayMaxLimit in source.
constant int ARRMAX = 128;

struct FractionAndZero {
    float fraction;
    bool zero;
};

struct ColorStop {
    bool enabled;
    float position;
    float4 color;
};

struct ColorStopArray {
    float fraction;
    packed_float4 color;
};

FractionAndZero fractionAndZero(float fraction, int extend);
float4 gradient(float fraction, array<ColorStopArray, ARRMAX> inArr, array<bool, ARRMAX> inArrActive);

#endif
