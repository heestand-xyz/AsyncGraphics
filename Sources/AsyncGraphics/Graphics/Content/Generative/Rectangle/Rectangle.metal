////
////  Created by Anton Heestand on 2017-11-17.
////  Copyright © 2017 Anton Heestand. All rights reserved.
////
//
//#include <metal_stdlib>
//using namespace metal;
//
//struct VertexOut {
//    float4 position [[position]];
//    float2 texCoord;
//};
//
//struct Uniforms {
//    packed_float2 size;
//    packed_float2 position;
//    float cornerRadius;
//    float ar;
//    float ag;
//    float ab;
//    float aa;
//    float br;
//    float bg;
//    float bb;
//    float ba;
//    float premultiply;
//    float resx;
//    float resy;
//    float aspect;
//    float tile;
//    float tileX;
//    float tileY;
//    float tileResX;
//    float tileResY;
//    float tileFraction;
//};
//
//fragment float4 contentGeneratorRectanglePIX(VertexOut out [[stage_in]],
//                                             const device Uniforms& uniforms [[ buffer(0) ]],
//                                             sampler s [[ sampler(0) ]]) {
//
//    float u = out.texCoord[0];
//    float v = out.texCoord[1];
//    if (in.tile > 0.0) {
//        u = (in.tileX / in.tileResX) + u * in.tileFraction;
//        v = (in.tileY / in.tileResY) + v * in.tileFraction;
//    }
//
//    float4 ac = float4(in.ar, in.ag, in.ab, in.aa);
//    float4 bc = float4(in.br, in.bg, in.bb, in.ba);
//
//    float4 c = bc;
//
//    float x = (u - 0.5) * in.aspect;
//    float y = v - 0.5;
//
//    float left = uniforms.position.x - uniforms.size.x / 2;
//    float right = uniforms.position.x + uniforms.size.x / 2;
//    float bottom = -uniforms.position.y - uniforms.size.y / 2;
//    float top = -uniforms.position.y + uniforms.size.y / 2;
//
//    float width = right - left;
//    float height = top - bottom;
//
//    float cornerRadius = max(min(min(uniforms.cornerRadius, width / 2), height / 2), 0.0);
//
//    float in_x = x > left && x < right;
//    float in_y = y > bottom && y < top;
//
//    if (cornerRadius == 0.0) {
//        if (in_x && in_y) {
//            c = ac;
//        }
//    } else {
//        float in_x_inset = x > left + cornerRadius && x < right - cornerRadius;
//        float in_y_inset = y > bottom + cornerRadius && y < top - cornerRadius;
//        if ((in_x_inset && in_y) || (in_x && in_y_inset)) {
//            c = ac;
//        }
//        float2 c1 = float2(left + cornerRadius, bottom + cornerRadius);
//        float2 c2 = float2(left + cornerRadius, top - cornerRadius);
//        float2 c3 = float2(right - cornerRadius, bottom + cornerRadius);
//        float2 c4 = float2(right - cornerRadius, top - cornerRadius);
//        float c1r = sqrt(pow(x - c1.x, 2) + pow(y - c1.y, 2));
//        float c2r = sqrt(pow(x - c2.x, 2) + pow(y - c2.y, 2));
//        float c3r = sqrt(pow(x - c3.x, 2) + pow(y - c3.y, 2));
//        float c4r = sqrt(pow(x - c4.x, 2) + pow(y - c4.y, 2));
//        if (c1r < cornerRadius || c2r < cornerRadius || c3r < cornerRadius || c4r < cornerRadius) {
//            c = ac;
//        }
//    }
//
//    if (in.premultiply) {
//        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
//    }
//
//    return c;
//}
