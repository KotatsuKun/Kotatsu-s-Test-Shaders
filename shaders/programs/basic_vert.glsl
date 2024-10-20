#version 460

in vec3 vaPosition; //vertex
in vec2 vaUV0;
in vec4 vaColor;

uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;

void main() {



    texCoord = vaUV0;
    foliageColor= vaColor.rgb;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition+chunkOffset, 1);
}