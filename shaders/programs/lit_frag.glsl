#version 460


uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;

uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

uniform float viewHeight;
uniform float viewWidth;


in vec2 texCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;
in vec4 tangent;


/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;


#include "/programs/functions.glsl"


void main(){

    vec4 outputColorData = texture(gtexture, texCoord);
    vec3 albedo = pow(outputColorData.rgb, vec3(2.2)) * pow(foliageColor, vec3(2.2));
    float transparency = outputColorData.a;
    if (transparency < .1){
        discard;
    }
    
    vec3 outputColor = lightCalculations(albedo);


    outColor0 = vec4(pow(outputColor, vec3(1/2.2)), transparency);

    //outColor0 = vec4(worldGeoNormal, transparency);
}