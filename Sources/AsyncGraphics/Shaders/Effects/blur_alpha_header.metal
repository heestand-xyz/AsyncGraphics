#ifndef ASYNCGRAPHICS_BLUR_ALPHA_HEADER
#define ASYNCGRAPHICS_BLUR_ALPHA_HEADER

#include <metal_stdlib>
using namespace metal;

// Normalize only the completed blur. Preserve alpha, HDR values, and hidden RGB
// at zero alpha, where division would be undefined.
inline float4 agBlurOutput(float4 color, bool pureAlpha) {
    if (pureAlpha && color.a != 0.0) {
        color.rgb /= color.a;
    }
    return color;
}

#endif
