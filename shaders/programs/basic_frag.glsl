

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform mat4 gbufferModelViewInverse;
uniform sampler2D normals;
uniform sampler2D specular;

uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;


in vec2 texCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;
in vec4 tangent;


/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

mat3 tbnNormalTangent(vec3 normal, vec3 tangent){

    vec3 bitangent = cross(tangent, normal);
    return mat3(tangent, bitangent, normal);
}


void main(){

    vec4 outputColorData = texture(gtexture, texCoord);
    vec3 albedo = pow(outputColorData.rgb, vec3(2.2)) * pow(foliageColor, vec3(2.2));
    float transparency = outputColorData.a;
    if (transparency < .1){
        discard;
    }

    outColor0 = vec4(pow(albedo, vec3(1/2.2)), transparency);

    //outColor0 = vec4(worldGeoNormal, transparency);
}
