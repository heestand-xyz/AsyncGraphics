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
    
    if (pos.x >= targetTexture.get_width()) {
        return;
    } else if (pos.y >= targetTexture.get_height()) {
        return;
    } else if (pos.z >= targetTexture.get_depth()) {
        return;
    }
    
    float4 color = uniforms.color;
    
    if (uniforms.premultiply) {
        color = float4(color.rgb * color.a, color.a);
    }
    
    targetTexture.write(color, pos);
}

