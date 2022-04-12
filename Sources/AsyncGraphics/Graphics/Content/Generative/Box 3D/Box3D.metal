//
//  Created by Anton Heestand on 2022-04-11.
//  Copyright © 2022 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Content/radius_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool premultiply;
    bool antiAlias;
    packed_float3 size;
    packed_float3 position;
    float cornerRadius;
    float edgeRadius;
    packed_float4 foregroundColor;
    packed_float4 edgeColor;
    packed_float4 backgroundColor;
};

kernel void box3d(const device Uniforms& uniforms [[ buffer(0) ]],
                  texture3d<float, access::write> targetTexture [[ texture(0) ]],
                  uint3 pos [[ thread_position_in_grid ]]) {

    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();

    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }

    float onePixel = 1.0 / float(max(max(width, height), depth));

    float u = float(pos.x + 0.5) / float(width);
    float v = float(pos.y + 0.5) / float(height);
    float w = float(pos.z + 0.5) / float(depth);

    float4 foregroundColor = uniforms.foregroundColor;
    float4 edgeColor = uniforms.edgeColor;
    float4 backgroundColor = uniforms.backgroundColor;

    float4 color = backgroundColor;

    float edgeRadius = max(uniforms.edgeRadius, 0.0);

    float aspectRatio = float(width) / float(height);
    float depthAspectRatio = float(depth) / float(height);

    float x = (u - 0.5) * aspectRatio;
    float y = v - 0.5;
    float z = (w - 0.5) * depthAspectRatio;
    
    float3 position = uniforms.position;
    float3 size = uniforms.size;

    float left = position.x - size.x / 2;
    float right = position.x + size.x / 2;
    float bottom = position.y - size.y / 2;
    float top = position.y + size.y / 2;
    float near = position.z - size.z / 2;
    float far = position.z + size.z / 2;

    float cornerRadius = max(min(min(min(uniforms.cornerRadius, size.x / 2), size.y / 2), size.z / 2), 0.0);

    float in_x = x > left && x < right;
    float in_y = y > bottom && y < top;
    float in_z = z > near && z < far;
    float in_edge_inner_x = x > left + edgeRadius / 2 && x < right - edgeRadius / 2;
    float in_edge_inner_y = y > bottom + edgeRadius / 2 && y < top - edgeRadius / 2;
    float in_edge_inner_z = z > near + edgeRadius / 2 && z < far - edgeRadius / 2;
    float in_edge_outer_x = x > left - edgeRadius / 2 && x < right + edgeRadius / 2;
    float in_edge_outer_y = y > bottom - edgeRadius / 2 && y < top + edgeRadius / 2;
    float in_edge_outer_z = z > near - edgeRadius / 2 && z < far + edgeRadius / 2;

    if (cornerRadius == 0.0) {

        if (edgeRadius > 0.0) {

            if (in_edge_inner_x && in_edge_inner_y && in_edge_inner_z) {
                color = foregroundColor;
            } else if (in_edge_outer_x && in_edge_outer_y && in_edge_outer_z) {
                color = edgeColor;
            }

        } else {

            if (in_x && in_y && in_z) {
                color = foregroundColor;
            }
        }

    } else {

        float in_x_inset = x > left + cornerRadius && x < right - cornerRadius;
        float in_y_inset = y > bottom + cornerRadius && y < top - cornerRadius;
        float in_z_inset = z > near + cornerRadius && z < far - cornerRadius;

        if (in_x_inset || in_y_inset || in_z_inset) {

            if (edgeRadius > 0.0) {

                if (in_edge_inner_x && in_edge_inner_y && in_edge_inner_z) {
                    color = foregroundColor;
                } else if (in_edge_outer_x && in_edge_outer_y && in_edge_outer_z) {
                    color = edgeColor;
                }

            } else {

                if (in_x && in_y && in_z) {
                    color = foregroundColor;
                }
            }

        } else {

            float3 corner_nearBottomLeft = float3(left + cornerRadius, bottom + cornerRadius, near + cornerRadius);
            float3 corner_nearTopLeft = float3(left + cornerRadius, top - cornerRadius, near + cornerRadius);
            float3 corner_nearBottomRight = float3(right - cornerRadius, bottom + cornerRadius, near + cornerRadius);
            float3 corner_nearTopRight = float3(right - cornerRadius, top - cornerRadius, near + cornerRadius);
            float3 corner_farBottomLeft = float3(left + cornerRadius, bottom + cornerRadius, far - cornerRadius);
            float3 corner_farTopLeft = float3(left + cornerRadius, top - cornerRadius, far - cornerRadius);
            float3 corner_farBottomRight = float3(right - cornerRadius, bottom + cornerRadius, far - cornerRadius);
            float3 corner_farTopRight = float3(right - cornerRadius, top - cornerRadius, far - cornerRadius);

            float cornerRadius_nearBottomLeft = sqrt(pow(sqrt(pow(x - corner_nearBottomLeft.x, 2) + pow(y - corner_nearBottomLeft.y, 2)), 2) + pow(z - corner_nearBottomLeft.z, 2));
            float cornerRadius_nearTopLeft = sqrt(pow(sqrt(pow(x - corner_nearTopLeft.x, 2) + pow(y - corner_nearTopLeft.y, 2)), 2) + pow(z - corner_nearTopLeft.z, 2));
            float cornerRadius_nearBottomRight = sqrt(pow(sqrt(pow(x - corner_nearBottomRight.x, 2) + pow(y - corner_nearBottomRight.y, 2)), 2) + pow(z - corner_nearBottomRight.z, 2));
            float cornerRadius_nearTopRight = sqrt(pow(sqrt(pow(x - corner_nearTopRight.x, 2) + pow(y - corner_nearTopRight.y, 2)), 2) + pow(z - corner_nearTopRight.z, 2));
            float cornerRadius_farBottomLeft = sqrt(pow(sqrt(pow(x - corner_farBottomLeft.x, 2) + pow(y - corner_farBottomLeft.y, 2)), 2) + pow(z - corner_farBottomLeft.z, 2));
            float cornerRadius_farTopLeft = sqrt(pow(sqrt(pow(x - corner_farTopLeft.x, 2) + pow(y - corner_farTopLeft.y, 2)), 2) + pow(z - corner_farTopLeft.z, 2));
            float cornerRadius_farBottomRight = sqrt(pow(sqrt(pow(x - corner_farBottomRight.x, 2) + pow(y - corner_farBottomRight.y, 2)), 2) + pow(z - corner_farBottomRight.z, 2));
            float cornerRadius_farTopRight = sqrt(pow(sqrt(pow(x - corner_farTopRight.x, 2) + pow(y - corner_farTopRight.y, 2)), 2) + pow(z - corner_farTopRight.z, 2));

//            if (uniforms.antiAlias || edgeRadius > 0.0) {
//
//                if (x < position.x && y < position.y) {
//
//                    color = radiusColor(cornerRadius_bottomLeft, cornerRadius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, onePixel);
//
//                } else if (x < position.x && y > position.y) {
//
//                    color = radiusColor(cornerRadius_topLeft, cornerRadius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, onePixel);
//
//                } else if (x > position.x && y < position.y) {
//
//                    color = radiusColor(cornerRadius_bottomRight, cornerRadius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, onePixel);
//
//                } else if (x > position.x && y > position.y) {
//
//                    color = radiusColor(cornerRadius_topRight, cornerRadius, edgeRadius, foregroundColor, edgeColor, backgroundColor, uniforms.antiAlias, onePixel);
//                }
//
//            } else {
//
//                if (cornerRadius_bottomLeft < cornerRadius || cornerRadius_topLeft < cornerRadius || cornerRadius_bottomRight < cornerRadius || cornerRadius_topRight < cornerRadius) {
//                    color = foregroundColor;
//                }
//            }
        }

    }

    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }

    targetTexture.write(color, pos);
}
