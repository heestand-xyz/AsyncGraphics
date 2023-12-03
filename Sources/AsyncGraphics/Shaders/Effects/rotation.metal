#include <metal_stdlib>
using namespace metal;

#include "rotation_header.metal"

float4 createQuaternion(float angle, float3 axis) {
    float halfAngle = angle * 0.5;
    float sinHalfAngle = sin(halfAngle);
    return float4(axis * sinHalfAngle, cos(halfAngle));
}

float4 multiplyQuaternions(float4 q1, float4 q2) {
    return float4(
        q1.w * q2.xyz + q2.w * q1.xyz + cross(q1.xyz, q2.xyz),
        q1.w * q2.w - dot(q1.xyz, q2.xyz)
    );
}

float4 conjugate(float4 q) {
    return float4(-q.x, -q.y, -q.z, q.w);
}

float3 rotateRadians(float3 vector, float angle, float3 axis) {
    
    float4 rotationQuaternion = createQuaternion(angle, normalize(axis));
    
    float4 inputQuaternion = float4(vector, 0.0);
    float4 rotatedQuaternion = multiplyQuaternions(multiplyQuaternions(rotationQuaternion, inputQuaternion), conjugate(rotationQuaternion));
    return rotatedQuaternion.xyz;
}

float3 rotateDegrees(float3 vector, float angle, float3 axis) {
    return rotateRadians(vector, angle / 360 * (M_PI_F * 2), axis);
}
