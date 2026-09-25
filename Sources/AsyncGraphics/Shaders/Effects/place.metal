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

float2 translationScale(int place, uint leadingWidth, uint leadingHeight, uint trailingWidth, uint trailingHeight) {
    
    float leadingAspect = float(leadingWidth) / float(leadingHeight);
    float trailingAspect = float(trailingWidth) / float(trailingHeight);
    
    float2 scale = 1.0;
    
    switch (place) {
        case 0: // Stretch
            scale = float2(trailingAspect / leadingAspect, 1.0);
            break;
        case 1: // Aspect Fit
            if (trailingAspect > leadingAspect) {
                scale = trailingAspect / leadingAspect;
            }
            break;
        case 2: // Aspect Fill
            if (trailingAspect < leadingAspect) {
                scale = trailingAspect / leadingAspect;
            }
            break;
        case 3: // Fixed
            scale = float(leadingHeight) / float(trailingHeight);
            break;
    }
    
    return scale;
}

float2 transformPlace(int placement,
                      float2 uv,
                      uint leadingWidth,
                      uint leadingHeight,
                      uint trailingWidth,
                      uint trailingHeight,
                      float2 offset,
                      float2 scale,
                      float rotation,
                      int horizontalAlignment,
                      int verticalAlignment) {
    
    if (scale.x <= 0.0 || scale.y <= 0.0) {
        return 0.5;
    }
    
    float pi = M_PI_F;
    float leadingAspect = float(leadingWidth) / float(leadingHeight);
    float trailingAspect = float(trailingWidth) / float(trailingHeight);

    float2 uvPlacement = place(placement, uv, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    float2 offsetScale = translationScale(placement, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
        
    float x = (uvPlacement.x - 0.5) * trailingAspect - offset.x * offsetScale.x;
    float y = uvPlacement.y - 0.5 - offset.y * offsetScale.y;
    float angle = atan2(y, x) - (rotation * pi * 2);
    float radius = sqrt(pow(x, 2) + pow(y, 2));
    float2 uvTransform;
    if (radius == 0.0) {
        uvTransform = 0.5;
    } else {
        uvTransform = float2((cos(angle) / trailingAspect) * radius, sin(angle) * radius) / scale + 0.5;
    }
    
    float2 uvAlignment = uvTransform;
    switch (placement) {
        case 0: // Stretch
            break;
        case 1: // Aspect Fit
            if (trailingAspect > leadingAspect) {
                float vertical = ((leadingAspect - trailingAspect) / 2) / leadingAspect;
                switch (verticalAlignment) {
                    case -1: // Top
                        uvAlignment.y -= vertical / scale.y;
                    case 0: // Center
                        break;
                    case 1: // Bottom
                        uvAlignment.y += vertical / scale.y;
                }
            } else if (trailingAspect < leadingAspect) {
                float horizontal = ((trailingAspect - leadingAspect) / 2) / trailingAspect;
                switch (horizontalAlignment) {
                    case -1: // Leading (Left)
                        uvAlignment.x -= horizontal / scale.x;
                    case 0: // Center
                        break;
                    case 1: // Trailing (Right)
                        uvAlignment.x += horizontal / scale.x;
                }
            }
            break;
        case 2: // Aspect Fill
            if (trailingAspect > leadingAspect) {
                float horizontal = ((1.0 / leadingAspect - 1.0 / trailingAspect) / 2) * leadingAspect;
                switch (horizontalAlignment) {
                    case -1: // Leading (Left)
                        uvAlignment.x -= horizontal / scale.x;
                    case 0: // Center
                        break;
                    case 1: // Trailing (Right)
                        uvAlignment.x += horizontal / scale.x;
                }
            } else if (trailingAspect < leadingAspect) {
                float vertical = ((1.0 / trailingAspect - 1.0 / leadingAspect) / 2) * trailingAspect;
                switch (verticalAlignment) {
                    case -1: // Top
                        uvAlignment.y -= vertical / scale.y;
                    case 0: // Center
                        break;
                    case 1: // Bottom
                        uvAlignment.y += vertical / scale.y;
                }
            }
            break;
        case 3: // Fixed
            float hFraction = float(leadingWidth) / float(trailingWidth);
            float horizontal = 0.5 - hFraction / 2;
            switch (horizontalAlignment) {
                case -1: // Leading (Left)
                    uvAlignment.x -= horizontal / scale.x;
                case 0: // Center
                    break;
                case 1: // Trailing (Right)
                    uvAlignment.x += horizontal / scale.x;
            }
            float vFraction = float(leadingHeight) / float(trailingHeight);
            float vertical = 0.5 - vFraction / 2;
            switch (verticalAlignment) {
                case -1: // Top
                    uvAlignment.y -= vertical / scale.y;
                case 0: // Center
                    break;
                case 1: // Bottom
                    uvAlignment.y += vertical / scale.y;
            }
            break;
    }
    
    return uvAlignment;
}

float3 place3d(int placement, float3 uvw, uint leadingWidth, uint leadingHeight, uint leadingDepth, uint trailingWidth, uint trailingHeight, uint trailingDepth) {
    float3 leadingSize = float3(leadingWidth, leadingHeight, leadingDepth);
    float3 trailingSize = float3(trailingWidth, trailingHeight, trailingDepth);
    float3 ratio = leadingSize / trailingSize;
    float3 scale = 1.0;
    switch (placement) {
        case 0: // Stretch
            return uvw;
        case 1: // Aspect Fit
            scale = min(min(ratio.x, ratio.y), ratio.z);
            break;
        case 2: // Aspect Fill
            scale = max(max(ratio.x, ratio.y), ratio.z);
            break;
        case 3: // Fixed
            break;
    }
    return (uvw - 0.5) * ratio / scale + 0.5;
}
