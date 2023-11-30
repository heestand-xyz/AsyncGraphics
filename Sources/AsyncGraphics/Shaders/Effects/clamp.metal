//
//  place.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-07.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "clamp_header.metal"

float clampValue(float value, float low, float high, int type) {
    float rel = 0.0;
    float vala = 0.0;
    float valb = 0.0;
    if (type == 1 || type == 2 || type == 4) {
        rel = (value - low) / (high - low);
        if (rel > 0.0) {
            vala = rel - float(int(rel));
        } else {
            valb = rel + float(int(1.0 - rel));
        }
    }
    switch (type) {
        case 0: // hold
            if (value < low) {
                return low;
            } else if (value > high) {
                return high;
            }
            return value;
        case 1: // relativeLoop
            if (rel > 0.0) {
                return vala;
            } else {
                return valb;
            }
        case 2: // relativeMirror
            if (rel > 0.0) {
                return int(rel) % 2 == 0 ? vala : 1.0 - vala;
            } else {
                return int(1.0 - rel) % 2 == 0 ? valb : 1.0 - valb;
            }
        case 3: // zero
            if (value < low || value > high) {
                return 0.0;
            }
            return value;
        case 4: // relative
            if (value < low) {
                return 0.0;
            } else if (value > high) {
                return 1.0;
            }
            return rel;
        default: return 0.0;
    }
}
