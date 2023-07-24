//
//  place.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2019-10-07.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "place_header.metal"

float2 place(int place, float2 uv, uint leadingWidth, uint leadingHeight, uint trailingWidth, uint trailingHeight) {
   
    float aspect_a = float(leadingWidth) / float(leadingHeight);
    float aspect_b = float(trailingWidth) / float(trailingHeight);
    
    float u = uv.x;
    float v = uv.y;
    
    switch (place) {
        case 0: // Stretch
            break;
        case 1: // Aspect Fit
            if (aspect_b > aspect_a) {
                v /= aspect_a;
                v *= aspect_b;
                v += ((aspect_a - aspect_b) / 2) / aspect_a;
            } else if (aspect_b < aspect_a) {
                u /= aspect_b;
                u *= aspect_a;
                u += ((aspect_b - aspect_a) / 2) / aspect_b;
            }
            break;
        case 2: // Aspect Fill
            if (aspect_b > aspect_a) {
                u *= aspect_a;
                u /= aspect_b;
                u += ((1.0 / aspect_a - 1.0 / aspect_b) / 2) * aspect_a;
            } else if (aspect_b < aspect_a) {
                v *= aspect_b;
                v /= aspect_a;
                v += ((1.0 / aspect_b - 1.0 / aspect_a) / 2) * aspect_b;
            }
            break;
        case 3: // Fixed
            u = 0.5 + ((uv.x - 0.5) * leadingWidth) / trailingWidth;
            v = 0.5 + ((uv.y - 0.5) * leadingHeight) / trailingHeight;
            break;
    }

    return float2(u, v);
}

// Deprecated
float unitPlace(int place, uint leadingWidth, uint leadingHeight, uint trailingWidth, uint trailingHeight) {
    
    float aspect_a = float(leadingWidth) / float(leadingHeight);
    float aspect_b = float(trailingWidth) / float(trailingHeight);
    
    float unit = 1.0;
    
    switch (place) {
        case 0: // Stretch
            break;
        case 1: // Aspect Fit
            if (aspect_b > aspect_a) {
                unit /= aspect_a;
                unit *= aspect_b;
                unit += ((aspect_a - aspect_b) / 2) / aspect_a;
            }
            break;
        case 2: // Aspect Fill
            if (aspect_b < aspect_a) {
                unit *= aspect_b;
                unit /= aspect_a;
                unit += ((1.0 / aspect_b - 1.0 / aspect_a) / 2) * aspect_b;
            }
            break;
        case 3: // Fixed
            unit = float(leadingHeight) / float(trailingHeight);
            break;
    }
    
    return unit;
}

float2 transformPlace(int placement,
                      float2 uv,
                      uint leadingWidth,
                      uint leadingHeight,
                      uint trailingWidth,
                      uint trailingHeight,
                      float2 translation,
                      float2 scale,
                      float rotation,
                      int horizontalAlignment,
                      int verticalAlignment) {
    
    float pi = M_PI_F;
    float aspectRatio = float(trailingWidth) / float(trailingHeight);

    float2 uvPlacement = place(placement, uv, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    float unit = unitPlace(placement, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
        
    float x = (uvPlacement.x - 0.5) * aspectRatio - translation.x * unit;
    float y = uvPlacement.y - 0.5 - translation.y * unit;
    float angle = atan2(y, x) - (rotation * pi * 2);
    float radius = sqrt(pow(x, 2) + pow(y, 2));
    float2 uvTransform;
    if (radius == 0.0) {
        uvTransform = 0.5;
    } else {
        uvTransform = float2((cos(angle) / aspectRatio) * radius, sin(angle) * radius) / scale + 0.5;
    }

    return uvTransform;
}

float3 place3d(int place, float3 uvw, uint leadingWidth, uint leadingHeight, uint leadingDepth, uint trailingWidth, uint trailingHeight, uint trailingDepth) {

//    float aspect_a = float(leadingWidth) / float(leadingHeight);
//    float depthAspect_a = float(leadingDepth) / float(leadingHeight);
//    float aspect_b = float(trailingWidth) / float(trailingHeight);
//    float depthAspect_b = float(trailingDepth) / float(trailingHeight);

    float u = uvw.x;
    float v = uvw.y;
    float w = uvw.z;

    switch (place) {
        case 0: // Stretch
            break;
//        case 1: // Aspect Fit
//            if (aspect_b > aspect_a) {
//                v /= aspect_a;
//                v *= aspect_b;
//                v += ((aspect_a - aspect_b) / 2) / aspect_a;
//            } else if (aspect_b < aspect_a) {
//                u /= aspect_b;
//                u *= aspect_a;
//                u += ((aspect_b - aspect_a) / 2) / aspect_b;
//                if (depthAspect_b > depthAspect_a) {
//
//                } else if (depthAspect_b < depthAspect_a) {
//
//                }
//            } else {
//                if (depthAspect_b > depthAspect_a) {
//                    u /= depthAspect_a;
//                    u *= depthAspect_b;
//                    u += ((depthAspect_a - depthAspect_b) / 2) / depthAspect_a;
//                    v /= depthAspect_a;
//                    v *= depthAspect_b;
//                    v += ((depthAspect_a - depthAspect_b) / 2) / depthAspect_a;
//                } else if (depthAspect_b < depthAspect_a) {
//                    w /= depthAspect_b;
//                    w *= depthAspect_a;
//                    w += ((depthAspect_b - depthAspect_a) / 2) / depthAspect_b;
//                }
//            }
//            break;
//        case 2: // Aspect Fill
//            if (aspect_b > aspect_a) {
//                u *= aspect_a;
//                u /= aspect_b;
//                u += ((1.0 / aspect_a - 1.0 / aspect_b) / 2) * aspect_a;
//            } else if (aspect_b < aspect_a) {
//                v *= aspect_b;
//                v /= aspect_a;
//                v += ((1.0 / aspect_b - 1.0 / aspect_a) / 2) * aspect_b;
//            }
//            break;
        case 3: // Fixed
            u = 0.5 + ((u - 0.5) * leadingWidth) / trailingWidth;
            v = 0.5 + ((v - 0.5) * leadingHeight) / trailingHeight;
            w = 0.5 + ((w - 0.5) * leadingDepth) / trailingDepth;
            break;
    }
    
    return float3(u, v, w);
}
