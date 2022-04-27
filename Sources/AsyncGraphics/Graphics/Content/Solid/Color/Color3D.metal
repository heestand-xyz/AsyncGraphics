//
//  Created by Anton Heestand on 2022-04-11.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    bool premultiply;
    packed_float4 color;
};

kernel void color3d(const device Uniforms& uniforms [[ buffer(0) ]],
                    texture3d<float, access::write>  targetTexture [[ texture(0) ]],
                    uint3 pos [[ thread_position_in_grid ]]) {
    
    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();
    
    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }
    
    float4 color = uniforms.color;
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    targetTexture.write(color, pos);
}

