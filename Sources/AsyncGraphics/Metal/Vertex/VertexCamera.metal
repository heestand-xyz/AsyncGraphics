//
//  Created by Warren Moore, edited by Anton Heestand on 2023-11-23.
//

#include <metal_stdlib>
#include <simd/simd.h>

struct VertexIn {
    packed_float3 position;
    packed_float3 texCoord;
};

struct VertexOut {
    float4 position [[position]];
    float3 texCoord;
};

struct Uniforms {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
};

vertex VertexOut vertexCamera(const device VertexIn* vertex_array [[ buffer(0) ]],
                              constant Uniforms & uniforms [[ buffer(1) ]],
                              unsigned int vid [[ vertex_id ]])
{
    VertexIn in = vertex_array[vid];

    VertexOut out;

    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.texCoord = in.texCoord;

    return out;
}
