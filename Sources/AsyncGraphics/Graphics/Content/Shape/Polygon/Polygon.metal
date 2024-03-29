//
//  Created by Anton Heestand on 2017-11-21.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//
//  https://stackoverflow.com/a/2049593/4586652
//

#include <metal_stdlib>
using namespace metal;

float2 lerp2d(float fraction, float2 from, float2 to) {
    return from * (1.0 - fraction) + to * fraction;
}

float2 proportion(float2 point, float segment, float length, float dx, float dy) {
    float factor = segment / length;
    return float2((float)(point.x - dx * factor),
                  (float)(point.y - dy * factor));
}

struct CornerCircle {
    float2 p;
    float2 c1;
    float2 c2;
};

CornerCircle cornerCircle(float2 p, float2 p1, float2 p2, float r) {
    
    //Vector 1
    float dx1 = p.x - p1.x;
    float dy1 = p.y - p1.y;
    
    //Vector 2
    float dx2 = p.x - p2.x;
    float dy2 = p.y - p2.y;
    
    //Angle between vector 1 and vector 2 divided by 2
    float angle = (atan2(dy1, dx1) - atan2(dy2, dx2)) / 2;
    
    // The length of segment between angular point and the
    // points of intersection with the circle of a given radius
    float _tan = abs(tan(angle));
    float segment = r / _tan;
    
    //Check the segment
    float length1 = sqrt(pow(dx1, 2) + pow(dy1, 2));
    float length2 = sqrt(pow(dx2, 2) + pow(dy2, 2));
    
    float _length = min(length1, length2);
    
    if (segment > _length)
    {
        segment = _length;
        r = _length * _tan;
    }
    
    // Points of intersection are calculated by the proportion between
    // the coordinates of the vector, length of vector and the length of the segment.
    float2 p1Cross = proportion(p, segment, length1, dx1, dy1);
    float2 p2Cross = proportion(p, segment, length2, dx2, dy2);
    
    // Calculation of the coordinates of the circle
    // center by the addition of angular vectors.
    float dx = p.x * 2 - p1Cross.x - p2Cross.x;
    float dy = p.y * 2 - p1Cross.y - p2Cross.y;
    
    float L = sqrt(pow(dx, 2) + pow(dy, 2));
    float d = sqrt(pow(segment, 2) + pow(r, 2));
    
    float2 circlePoint = proportion(p, d, L, dx, dy);
    
    CornerCircle cc;
    cc.p = circlePoint;
    cc.c1 = p1Cross;
    cc.c2 = p2Cross;
    return cc;
    
}

float sign(float2 p1, float2 p2, float2 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool pointInTriangle(float2 pt, float2 v1, float2 v2, float2 v3) {
    bool b1, b2, b3;
    b1 = sign(pt, v1, v2) < 0.0f;
    b2 = sign(pt, v2, v3) < 0.0f;
    b3 = sign(pt, v3, v1) < 0.0f;
    return (b1 == b2) && (b2 == b3);
}

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float radius;
    packed_float2 position;
    float rotation;
    uint count;
    packed_float4 foregroundColor;
    packed_float4 backgroundColor;
    float cornerRadius;
    float premultiply;
    packed_float2 resolution;
    packed_float2 tileOrigin;
    packed_float2 tileSize;
};

fragment float4 polygon(VertexOut out [[stage_in]],
                        const device Uniforms& uniforms [[ buffer(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    u = u * uniforms.tileSize.x + uniforms.tileOrigin.x;
    v = v * uniforms.tileSize.y + uniforms.tileOrigin.y;
    float2 uv = float2(u, v);
    
    float aspectRatio = uniforms.resolution.x / uniforms.resolution.y;
    
    float2 uvp = float2((u - 0.5) * aspectRatio, v - 0.5);
    
    float2 p = float2(uniforms.position.x / aspectRatio, uniforms.position.y);
    
    float4 ac = uniforms.foregroundColor;
    float4 bc = uniforms.backgroundColor;
    
    float4 c = bc;
    
    float rotation = uniforms.rotation + 0.5;
    
    if (uniforms.radius <= 0) {
        return c;
    }
    
    for (uint i = 0; i < uniforms.count; ++i) {
        float fia = float(i) / uniforms.count;
        float fib = float(i + 1) / uniforms.count;
        float fic = float(i + 2) / uniforms.count;
        float fid = float(i + 3) / uniforms.count;
        
        float2 p1 = 0.5 + p;
        float p2r = (fia + rotation) * pi * 2;
        float2 p2 = p1 + float2((sin(p2r) * uniforms.radius) / aspectRatio, cos(p2r) * uniforms.radius);
        float p3r = (fib + rotation) * pi * 2;
        float2 p3 = p1 + float2((sin(p3r) * uniforms.radius) / aspectRatio, cos(p3r) * uniforms.radius);
        
        float r = uniforms.cornerRadius;
        if (r <= 0) {
            
            bool pit = pointInTriangle(uv, p1, p2, p3);
            
            if (pit) {
                c = ac;
                break;
            }
            
        } else {
            
            float p4r = (fic + rotation) * pi * 2;
            float2 p4 = p1 + float2((sin(p4r) * uniforms.radius) / aspectRatio, cos(p4r) * uniforms.radius);
            float p5r = (fid + rotation) * pi * 2;
            float2 p5 = p1 + float2((sin(p5r) * uniforms.radius) / aspectRatio, cos(p5r) * uniforms.radius);
            
            float2 p2x = float2((p2.x - 0.5) * aspectRatio, p2.y - 0.5);
            float2 p3x = float2((p3.x - 0.5) * aspectRatio, p3.y - 0.5);
            float2 p4x = float2((p4.x - 0.5) * aspectRatio, p4.y - 0.5);
            float2 p5x = float2((p5.x - 0.5) * aspectRatio, p5.y - 0.5);
            
            CornerCircle cc1 = cornerCircle(p3x, p2x, p4x, r);
            CornerCircle cc2 = cornerCircle(p4x, p3x, p5x, r);
            
            float cc1d = sqrt(pow(cc1.p.x - uvp.x, 2) + pow(cc1.p.y - uvp.y, 2));
            float cc2d = sqrt(pow(cc2.p.x - uvp.x, 2) + pow(cc2.p.y - uvp.y, 2));
            
            float2 cc1p = float2(cc1.p.x / aspectRatio + 0.5, cc1.p.y + 0.5);
            float2 cc1c2 = float2(cc1.c2.x / aspectRatio + 0.5, cc1.c2.y + 0.5);
            float2 cc2p = float2(cc2.p.x / aspectRatio + 0.5, cc2.p.y + 0.5);
            float2 cc2c1 = float2(cc2.c1.x / aspectRatio + 0.5, cc2.c1.y + 0.5);
            
            bool pit = pointInTriangle(uv, p1, cc1p, cc2p);
            bool pit1 = pointInTriangle(uv, cc1p, cc1c2, cc2c1);
            bool pit2 = pointInTriangle(uv, cc2p, cc1p, cc2c1);
            
            if (cc1d < r || cc2d < r || pit || pit1 || pit2) {
                c = ac;
                break;
            }
        }
    }
    
    if (uniforms.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}
