//
//  gradient.metal
//  Shaders
//
//  Created by Anton Heestand on 2019-10-02.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "gradient_header.metal"

FractionAndZero fractionAndZero(float fraction, int extend) {
   
    bool zero = false;
    switch (extend) {
        case 0: // Zero
            if (fraction < 0) {
                zero = true;
            } else if (fraction > 1) {
                zero = true;
            }
            break;
        case 1: // Hold
            if (fraction < 0.0001) {
                fraction = 0.0001;
            } else if (fraction > 0.9999) {
                fraction = 0.9999;
            }
            break;
        case 2: // Repeat
            fraction = fraction - floor(fraction);
            break;
        case 3: // Mirror
            bool mirror = false;
            if (fraction > 0 ? int(fraction) % 2 == 1 : int(fraction) % 2 == 0) {
                mirror = true;
            }
            fraction = fraction - floor(fraction);
            if (mirror) {
                fraction = 1.0 - fraction;
            }
            break;
    }
    
    FractionAndZero fz = FractionAndZero();
    fz.zero = zero;
    fz.fraction = fraction;
    
    return fz;
    
}

float4 gradient(float fraction,
                const device array<ColorStopArray, ARRMAX>& stops,
                const device array<bool, ARRMAX>& active,
                bool smooth) {
    int low = -1;
    int high = -1;
    for (int i = 0; i < ARRMAX && active[i]; ++i) {
        float position = stops[i].fraction;
        if (position == fraction) {
            return stops[i].color;
        }
        if (position < fraction && (low < 0 || position > stops[low].fraction)) {
            low = i;
        }
        if (position > fraction && (high < 0 || position < stops[high].fraction)) {
            high = i;
        }
    }

    if (low < 0 && high < 0) { return float4(0.0); }
    if (low < 0) { return stops[high].color; }
    if (high < 0) { return stops[low].color; }

    float t = (fraction - stops[low].fraction) / (stops[high].fraction - stops[low].fraction);
    if (smooth) {
        t = 0.5 - 0.5 * cos(M_PI_F * t);
    }
    return mix(float4(stops[low].color), float4(stops[high].color), t);
}
