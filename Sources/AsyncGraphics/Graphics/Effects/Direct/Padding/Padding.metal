//
//  Created by Anton Heestand on 2023-02-08.
//  Copyright © 2023 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    bool onLeading;
    bool onTrailing;
    bool onTop;
    bool onBottom;
    float padding;
};

fragment float4 padding(VertexOut out [[stage_in]],
                        texture2d<float> texture [[ texture(0) ]],
                        const device Uniforms& uniforms [[ buffer(0) ]],
                        sampler sampler [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    uint width = texture.get_width();
    uint height = texture.get_height();
    
    float padding = uniforms.padding;
    float paddingLeading = uniforms.onLeading ? padding : 0.0;
    float paddingTrailing = uniforms.onTrailing ? padding : 0.0;
    float paddingTop = uniforms.onTop ? padding : 0.0;
    float paddingBottom = uniforms.onBottom ? padding : 0.0;
    float paddingHorizontal = paddingLeading + paddingTrailing;
    float paddingVertical = paddingTop + paddingBottom;
    
    float totalWidth = float(width) + paddingHorizontal;
    float totalHeight = float(height) + paddingVertical;
    
    float uPadding = u / (float(width) / totalWidth) - (paddingLeading / float(width));
    float vPadding = v / (float(height) / totalHeight) - (paddingTop / float(height));
    float2 uvPadding = float2(uPadding, vPadding);
    
    float4 color = texture.sample(sampler, uvPadding);
    
    return color;
}
