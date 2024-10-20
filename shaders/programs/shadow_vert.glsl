#version 460 compatibility

out vec2 texCoord;
out vec3 foliageColor;

void main() {

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    foliageColor= gl_Color.rgb;

    //vec3 worldSpaceVertexPosition = cameraPosition + ( gbufferModelViewInverse * modelViewMatrix * vec4(vaPosition+chunkOffset, 1)).xyz;
    //float distanceFromCamera = distance(worldSpaceVertexPosition, cameraPosition);

    gl_Position = ftransform();
}