//
//  gradient.metal
//  Shaders
//
//  Created by Anton Heestand on 2019-10-02.
//  Copyright © 2019 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "radius_header.metal"

float4 radiusColor(float radius,
                   float targetRadius,
                   float edgeRadius,
                   float4 foregroundColor,
                   float4 edgeColor,
                   float4 backgroundColor,
                   bool antiAlias,
                   bool premultiply,
                   float onePixel) {
    
    if (antiAlias) {
    
        if (edgeRadius > 0.0) {
        
            if (radius < targetRadius - edgeRadius / 2 - onePixel / 2) {
           
                return foregroundColor;
            
            } else if (radius < targetRadius - edgeRadius / 2 + onePixel / 2) {
            
                float fraction = (radius - (targetRadius - edgeRadius / 2 - onePixel / 2)) / onePixel;

                return foregroundColor * (1.0 - fraction) + edgeColor * fraction;

            } else if (radius < targetRadius + edgeRadius / 2 - onePixel / 2) {

                return edgeColor;

            } else if (radius < targetRadius + edgeRadius / 2 + onePixel / 2) {

                float fraction = (radius - (targetRadius + edgeRadius / 2 - onePixel / 2)) / onePixel;

                return edgeColor * (1.0 - fraction) + backgroundColor * fraction;
                
            } else {
                
                return backgroundColor;
            }

        } else {

            if (radius < targetRadius - onePixel / 2) {

                return foregroundColor;

            } else if (radius < targetRadius + onePixel / 2) {

                float fraction = (radius - (targetRadius - onePixel / 2)) / onePixel;

                if (premultiply) {
                    return foregroundColor * (1.0 - fraction) + backgroundColor * fraction;
                } else {
                    return float4(foregroundColor.rgb, backgroundColor.a);
                }
            } else {
                
                if (premultiply) {
                    return backgroundColor;
                } else {
                    return float4(foregroundColor.rgb, backgroundColor.a);
                }
            }
        }

    } else {

        if (radius < targetRadius - edgeRadius / 2) {

            return foregroundColor;

        } else if (radius < targetRadius + edgeRadius / 2) {

            return edgeColor;
            
        } else {
            
            return backgroundColor;
        }
    }
}
