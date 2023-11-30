//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Shaders/Content/radius_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool premultiply;
    bool antiAlias;
    packed_float2 size;
    packed_float2 position;
    float cornerRadius;
    float edgeRadius;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
    packed_float2 resolution;
};

fragment float4 rectangle(VertexOut out [[stage_in]],
                          const device Uniforms& uniforms [[ buffer(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    float onePixel = 1.0 / max(uniforms.resolution.x, uniforms.resolution.y);

    float4 foregroundColor = uniforms.foregroundColor;
    float4 edgeColor = uniforms.edgeColor;
    float4 backgroundColor = uniforms.backgroundColor;

    float4 color = backgroundColor;
    
    float edgeRadius = max(uniforms.edgeRadius, 0.0);
    
    float aspectRatio = uniforms.resolution.x / uniforms.resolution.y;

    float x = (u - 0.5) * aspectRatio;
    float y = (v - 0.5);

    float2 position = uniforms.position;
    float2 size = uniforms.size;
    
    float width = size.x;
    float height = size.y;

    float left = position.x - size.x / 2;
    float right = position.x + size.x / 2;
    float bottom = position.y - size.y / 2;
    float top = position.y + size.y / 2;

    float cornerRadius = max(min(min(uniforms.cornerRadius, width / 2), height / 2), 0.0);

    float in_x = x > left && x < right;
    float in_y = y > bottom && y < top;
    float in_edge_inner_x = x > left + edgeRadius / 2 && x < right - edgeRadius / 2;
    float in_edge_inner_y = y > bottom + edgeRadius / 2 && y < top - edgeRadius / 2;
    float in_edge_outer_x = x > left - edgeRadius / 2 && x < right + edgeRadius / 2;
    float in_edge_outer_y = y > bottom - edgeRadius / 2 && y < top + edgeRadius / 2;

    if (cornerRadius == 0.0) {

        if (edgeRadius > 0.0) {
            
            if (in_edge_inner_x && in_edge_inner_y) {
                color = foregroundColor;
            } else if (in_edge_outer_x && in_edge_outer_y) {
                color = edgeColor;
            }
            
        } else {
            
            if (in_x && in_y) {
                color = foregroundColor;
            }
        }

    } else {

        float in_x_inset = x > left + cornerRadius && x < right - cornerRadius;
        float in_y_inset = y > bottom + cornerRadius && y < top - cornerRadius;

        if (in_x_inset || in_y_inset) {
        
            if (edgeRadius > 0.0) {
                
                if (in_edge_inner_x && in_edge_inner_y) {
                    color = foregroundColor;
                } else if (in_edge_outer_x && in_edge_outer_y) {
                    color = edgeColor;
                }
                
            } else {
                
                if (in_x && in_y) {
                    color = foregroundColor;
                }
            }
        
        } else {

            float2 corner_bottomLeft = float2(left + cornerRadius, bottom + cornerRadius);
            float2 corner_topLeft = float2(left + cornerRadius, top - cornerRadius);
            float2 corner_bottomRight = float2(right - cornerRadius, bottom + cornerRadius);
            float2 corner_topRight = float2(right - cornerRadius, top - cornerRadius);
            
            float cornerRadius_bottomLeft = sqrt(pow(x - corner_bottomLeft.x, 2) + pow(y - corner_bottomLeft.y, 2));
            float cornerRadius_topLeft = sqrt(pow(x - corner_topLeft.x, 2) + pow(y - corner_topLeft.y, 2));
            float cornerRadius_bottomRight = sqrt(pow(x - corner_bottomRight.x, 2) + pow(y - corner_bottomRight.y, 2));
            float cornerRadius_topRight = sqrt(pow(x - corner_topRight.x, 2) + pow(y - corner_topRight.y, 2));
            
            if (uniforms.antiAlias || edgeRadius > 0.0) {
                
                if (x < position.x && y < position.y) {
                    
                    color = radiusColor(cornerRadius_bottomLeft, cornerRadius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, uniforms.premultiply, onePixel);
                    
                } else if (x < position.x && y > position.y) {

                    color = radiusColor(cornerRadius_topLeft, cornerRadius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, uniforms.premultiply, onePixel);

                } else if (x > position.x && y < position.y) {

                    color = radiusColor(cornerRadius_bottomRight, cornerRadius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, uniforms.premultiply, onePixel);

                } else if (x > position.x && y > position.y) {

                    color = radiusColor(cornerRadius_topRight, cornerRadius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, uniforms.premultiply, onePixel);
                }
                
            } else {
                
                if (cornerRadius_bottomLeft < cornerRadius || cornerRadius_topLeft < cornerRadius || cornerRadius_bottomRight < cornerRadius || cornerRadius_topRight < cornerRadius) {
                    
                    color = foregroundColor;
                }
            }
        }

    }

    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }

    return color;
}
