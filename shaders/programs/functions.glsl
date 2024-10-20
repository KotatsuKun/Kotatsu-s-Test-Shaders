
mat3 tbnNormalTangent(vec3 normal, vec3 tangent){

    vec3 bitangent = cross(tangent, normal);
    return mat3(tangent, bitangent, normal);
}

vec3 brdf(vec3 lightDir, vec3 viewDir, float roughness, vec3 normal, vec3 albedo, float metallic, vec3 reflectance) {
    
    viewDir = viewDir;
    float alpha = pow(roughness,2);

    vec3 H = normalize(lightDir + viewDir);
    

    //dot products
    float NdotV = clamp(dot(normal, viewDir), 0.001,1.0);
    float NdotL = clamp(dot(normal, lightDir), 0.001,1.0);
    float NdotH = clamp(dot(normal,H), 0.001,1.0);
    float VdotH = clamp(dot(viewDir, H), 0.001,1.0);

    // Fresnel
    vec3 F0 = reflectance;
    vec3 fresnelReflectance = F0 + (1.0 - F0) * pow(1.0 - VdotH, 5.0); //Schlick's Approximation

    //phong diffuse
    vec3 rhoD = albedo;
    rhoD *= (vec3(1.0)- fresnelReflectance); //energy conservation - light that doesn't reflect adds to diffuse

    //rhoD *= (1-metallic); //diffuse is 0 for metals

    // Geometric attenuation
    float k = alpha/2;
    float geometry = (NdotL / (NdotL*(1-k)+k)) * (NdotV / ((NdotV*(1-k)+k)));

    // Distribution of Microfacets
    float lowerTerm = pow(NdotH,2) * (pow(alpha,2) - 1.0) + 1.0;
    float normalDistributionFunctionGGX = pow(alpha,2) / (3.14159 * pow(lowerTerm,2));

    vec3 phongDiffuse = rhoD; //
    vec3 cookTorrance = (fresnelReflectance*normalDistributionFunctionGGX*geometry)/(4*NdotL*NdotV);
    
    vec3 BRDF = (phongDiffuse+cookTorrance)*NdotL;
   
    vec3 diffFunction = BRDF;
    
    return BRDF;
}

vec3 lightCalculations(vec3 albedo){

    //normal
    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;

    vec3 worldTangent = mat3(gbufferModelViewInverse) * tangent.xyz;

    vec4 normalData = texture(normals, texCoord)*2.0-1.0;

    vec3 normalNormalSpace = vec3(normalData.xy, sqrt(1.0 - dot(normalData.xy, normalData.xy)));

    mat3 TBN = tbnNormalTangent(worldGeoNormal, worldTangent);

    vec3 normalWorldSpace = TBN * normalNormalSpace;

    //specular
    vec4 specularData = texture(specular, texCoord);
    float percentualSmoothness = specularData.r;
    float metallic = 0.0;

    vec3 reflectance = vec3(0);

    if (specularData.g*255 > 299) {
        metallic = 1.0;
        reflectance = albedo;
    } else {
        reflectance = vec3(specularData.g);
    }

    float roughness = pow(1.0 - percentualSmoothness, 2.0);
    float smoothness = 1-roughness;
    float shininess = (1+(smoothness) * 100);

    //transforms
    vec3 fragFeetPlayerSpace = (gbufferModelViewInverse * vec4(viewSpacePosition, 1.0)).xyz;
    vec3 fragWorldSpace = fragFeetPlayerSpace + cameraPosition;

    vec3 fragShadowScreenSpace;

    //dirs
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);
    vec3 reflectionDirection = reflect(-shadowLightDirection, normalWorldSpace);
    vec3 viewDirection = normalize(cameraPosition - fragWorldSpace);

    //shadow
    vec3 shadow = texture(shadowtex0, fragShadowScreenSpace.xy).rgb;


    //light
    vec3 ambientLightDirection = worldGeoNormal;
    float ambientLight = .2 * clamp(dot(ambientLightDirection, normalNormalSpace), 0.1, 1.0);


    vec3 outputColor = albedo * ambientLight + brdf(shadowLightDirection, viewDirection, roughness, normalWorldSpace, albedo, metallic, reflectance);


    vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2));

    outputColor *= lightColor;

    outputColor = shadow;
    return outputColor;
}