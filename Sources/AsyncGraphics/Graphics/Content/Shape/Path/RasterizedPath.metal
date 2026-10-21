#include <metal_stdlib>
#include "../../../../Shaders/Content/shape_coverage_header.metal"
using namespace metal;

struct RasterizedPathVertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct RasterizedPathUniforms {
    bool premultiply;
    packed_float4 foregroundColor;
    packed_float4 backgroundColor;
};

fragment float4 rasterizedPathColor(RasterizedPathVertexOut out [[stage_in]],
                                    texture2d<float> texture [[texture(0)]],
                                    const device RasterizedPathUniforms& uniforms [[buffer(0)]],
                                    sampler sampler [[sampler(0)]]) {
    float coverage = texture.sample(sampler, out.texCoord).r;
    return agShapeColor(coverage, uniforms.foregroundColor, uniforms.backgroundColor, uniforms.premultiply);
}
