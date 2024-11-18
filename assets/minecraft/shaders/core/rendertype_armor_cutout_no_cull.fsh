#version 150

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

flat in float isLeatherLayer;
flat in float interpolClock;
flat in float h_offset;
flat in float emissivity;
flat in float isFirstArmor;

in vec2 nextFrameCoords;

out vec4 fragColor;

#define rougheq(a, b) (abs(a - b) < 0.1)

void main() {
    vec4 color = texture(Sampler0, texCoord0);

    vec4 vertColor = vertexColor;

    if (isLeatherLayer > 0.5) {

        vec4 armor = mix(texture(Sampler0, texCoord0), texture(Sampler0, nextFrameCoords), interpolClock);

        #ifdef ALPHA_CUTOUT
        if (armor.a < ALPHA_CUTOUT) {
            discard;
        }
        #endif

        // If it's the first leather armor texture in the atlas (used for the vanilla leather texture, with no custom color specified)
        if (isFirstArmor > 0.5) {
            color = armor * vertColor * ColorModulator * lightMapColor;
        } else { // If it's a custom armor texture (the actual item being leather)
            bool isPartiallyEmissive = rougheq(emissivity, 1.0);
            bool isEmissive = emissivity > 0.0;
            float controlOpacity = texture(Sampler0, vec2(texCoord0.x + h_offset, texCoord0.y)).a;

            if (!isEmissive) {
                vertColor *= lightMapColor;
            }

            if (isPartiallyEmissive) {
                vertColor *= controlOpacity;
            }

            color = armor * vertColor * ColorModulator;
        }
    } else {
        #ifdef ALPHA_CUTOUT
        if (color.a < ALPHA_CUTOUT) {
            discard;
        }
        #endif

        color *= vertColor * ColorModulator * lightMapColor;

        #ifndef EMISSIVE
            color *= lightMapColor;
        #endif
    }

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
