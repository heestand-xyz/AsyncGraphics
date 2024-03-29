//
//  ContentGeneratorPolygonPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-21.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//
//  https://stackoverflow.com/a/2049593/4586652
//

#include <metal_stdlib>
using namespace metal;

float2 starProportion(float2 point, float segment, float length, float dx, float dy) {
    float factor = segment / length;
    return float2((float)(point.x - dx * factor),
                  (float)(point.y - dy * factor));
}

struct StarCornerCircle {
    float2 p;
    float2 c1;
    float2 c2;
};

StarCornerCircle starCornerCircle(float2 p, float2 p1, float2 p2, float r) {
    
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
    float2 p1Cross = starProportion(p, segment, length1, dx1, dy1);
    float2 p2Cross = starProportion(p, segment, length2, dx2, dy2);
    
    // Calculation of the coordinates of the circle
    // center by the addition of angular vectors.
    float dx = p.x * 2 - p1Cross.x - p2Cross.x;
    float dy = p.y * 2 - p1Cross.y - p2Cross.y;
    
    float L = sqrt(pow(dx, 2) + pow(dy, 2));
    float d = sqrt(pow(segment, 2) + pow(r, 2));
    
    float2 circlePoint = starProportion(p, d, L, dx, dy);
    
    StarCornerCircle cc;
    cc.p = circlePoint;
    cc.c1 = p1Cross;
    cc.c2 = p2Cross;
    return cc;
    
}

float starSign(float2 p1, float2 p2, float2 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool starPointInTriangle(float2 pt, float2 v1, float2 v2, float2 v3) {
    bool b1, b2, b3;
    b1 = starSign(pt, v1, v2) < 0.0f;
    b2 = starSign(pt, v2, v3) < 0.0f;
    b3 = starSign(pt, v3, v1) < 0.0f;
    return (b1 == b2) && (b2 == b3);
}

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool premultiply;
    int count;
    float innerRadius;
    float outerRadius;
    float rotation;
    float cornerRadius;
    packed_float2 position;
    packed_float4 foregroundColor;
    packed_float4 backgroundColor;
    packed_float2 resolution;
    packed_float2 tileOrigin;
    packed_float2 tileSize;
};

fragment float4 star(VertexOut out [[stage_in]],
                     const device Uniforms& uniforms [[ buffer(0) ]]) {
    
    float pi = M_PI_F;

    float width = uniforms.resolution.x;
    float height = uniforms.resolution.y;
    float aspectRatio = width / height;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    u = u * uniforms.tileSize.x + uniforms.tileOrigin.x;
    v = v * uniforms.tileSize.y + uniforms.tileOrigin.y;
    v = 1.0 - v;
    float2 uv = float2(u, v);
    float2 uvp = float2((u - 0.5) * aspectRatio, v - 0.5);
    
    float x = uniforms.position.x;
    float y = uniforms.position.y;
    
    float2 p = float2(x / aspectRatio, y);
    
    float4 ac = uniforms.foregroundColor;
    float4 bc = uniforms.backgroundColor;

    float4 c = bc;
    
    if (uniforms.outerRadius <= 0 || uniforms.innerRadius <= 0) {
        return c;
    }
    
    bool isConcave = uniforms.outerRadius > uniforms.innerRadius;
    
    float count = uniforms.count;
    for (int j = 0; j < int(count); ++j) {
        int i = j;
        
        float largeScale = isConcave ? uniforms.outerRadius : uniforms.innerRadius;
        float smallScale = isConcave ? uniforms.innerRadius : uniforms.outerRadius;
        
        float fraction = 1.0 / count;
        float2 pntA = float2(cos(0.0) * largeScale, sin(0.0) * largeScale);
        float2 pntB = float2(cos(fraction * pi * 2.0) * largeScale, sin(fraction * pi * 2.0) * largeScale);
        float2 pntAB = (pntA + pntB) / 2;
        float distAB = sqrt(pow(pntAB.x, 2.0) + pow(pntAB.y, 2.0));
        bool isSubConvex = smallScale > distAB;
        
        float offset = isConcave ? 0.0 : 0.5;
        
        float fia = (float(i) + offset) / count;
        float fiab = (float(i) + 0.5 + offset) / count;
        float fib = (float(i) + 1.0 + offset) / count;
        float fibc = (float(i) + 1.5 + offset) / count;
        float fic = (float(i) + 2.0 + offset) / count;
        float ficd = (float(i) + 2.5 + offset) / count;
//        float fid = (float(i) + 3.0 + offset) / count;

        float2 p1 = 0.5 + p;
        float p2r = (fia + uniforms.rotation) * pi * 2;
        float2 p2 = p1 + float2((sin(p2r) * largeScale) / aspectRatio, cos(p2r) * largeScale);
        float p23r = (fiab + uniforms.rotation) * pi * 2;
        float2 p23 = p1 + float2((sin(p23r) * smallScale) / aspectRatio, cos(p23r) * smallScale);
        float p3r = (fib + uniforms.rotation) * pi * 2;
        float2 p3 = p1 + float2((sin(p3r) * largeScale) / aspectRatio, cos(p3r) * largeScale);
        
        float r = uniforms.cornerRadius;
        if (r <= 0) {
            
            bool pitA = starPointInTriangle(uv, p1, p2, p23);
            bool pitB = starPointInTriangle(uv, p1, p23, p3);

            if (pitA || pitB) {
                c = ac;
                break;
            }
            
        } else {
            
            float p34r = (fibc + uniforms.rotation) * pi * 2;
            float2 p34 = p1 + float2((sin(p34r) * smallScale) / aspectRatio, cos(p34r) * smallScale);
            float p4r = (fic + uniforms.rotation) * pi * 2;
            float2 p4 = p1 + float2((sin(p4r) * largeScale) / aspectRatio, cos(p4r) * largeScale);
            float p45r = (ficd + uniforms.rotation) * pi * 2;
            float2 p45 = p1 + float2((sin(p45r) * smallScale) / aspectRatio, cos(p45r) * smallScale);
//            float p5r = (fid + uniforms.rotation) * pi * 2;
//            float2 p5 = p1 + float2((sin(p5r) * largeScale) / aspectRatio, cos(p5r) * largeScale);

//            float2 p2x = float2((p2.x - 0.5) * aspectRatio, p2.y - 0.5);
            float2 p23x = float2((p23.x - 0.5) * aspectRatio, p23.y - 0.5);
            float2 p3x = float2((p3.x - 0.5) * aspectRatio, p3.y - 0.5);
            float2 p34x = float2((p34.x - 0.5) * aspectRatio, p34.y - 0.5);
            float2 p4x = float2((p4.x - 0.5) * aspectRatio, p4.y - 0.5);
            float2 p45x = float2((p45.x - 0.5) * aspectRatio, p45.y - 0.5);
//            float2 p5x = float2((p5.x - 0.5) * aspectRatio, p5.y - 0.5);
            
            StarCornerCircle cc1 = starCornerCircle(p3x, p23x, p34x, r);
            StarCornerCircle cc12 = starCornerCircle(p34x, p3x, p4x, r);
            StarCornerCircle cc2 = starCornerCircle(p4x, p34x, p45x, r);

            float cc1d = sqrt(pow(cc1.p.x - uvp.x, 2) + pow(cc1.p.y - uvp.y, 2));
            float cc12d = sqrt(pow(cc12.p.x - uvp.x, 2) + pow(cc12.p.y - uvp.y, 2));;
            float cc2d = sqrt(pow(cc2.p.x - uvp.x, 2) + pow(cc2.p.y - uvp.y, 2));

            float2 cc1p = float2(cc1.p.x / aspectRatio + 0.5, cc1.p.y + 0.5);
            float2 cc1c2 = float2(cc1.c2.x / aspectRatio + 0.5, cc1.c2.y + 0.5);
//            float2 cc12p = float2(cc12.p.x / aspectRatio + 0.5, cc12.p.y + 0.5);
            float2 cc12c1 = float2(cc12.c1.x / aspectRatio + 0.5, cc12.c1.y + 0.5);
            float2 cc12c2 = float2(cc12.c2.x / aspectRatio + 0.5, cc12.c2.y + 0.5);
            float2 cc2p = float2(cc2.p.x / aspectRatio + 0.5, cc2.p.y + 0.5);
            float2 cc2c1 = float2(cc2.c1.x / aspectRatio + 0.5, cc2.c1.y + 0.5);

            bool pit1 = starPointInTriangle(uv, p1, cc1p, cc1c2);
            bool pit1_12 = starPointInTriangle(uv, p1, cc1c2, cc12c1);
            bool pit12 = starPointInTriangle(uv, p1, cc12c1, cc12c2);
            bool pit12_2 = starPointInTriangle(uv, p1, cc12c2, cc2c1);
            bool pit2 = starPointInTriangle(uv, p1, cc2c1, cc2p);

            if ((cc1d < r || cc2d < r || pit1 || pit1_12 || pit12 || pit12_2 || pit2 || (isSubConvex ? cc12d < r : false)) && (isSubConvex ? true : cc12d > r)) {
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
