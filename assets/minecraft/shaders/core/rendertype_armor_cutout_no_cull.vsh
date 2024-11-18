#version 150

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat4 TextureMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;

flat out float isLeatherLayer;
flat out float interpolClock;
flat out float h_offset;
flat out float emissivity;
flat out float isFirstArmor;

out vec2 nextFrameCoords;

#define TEX_RES 16
#define ANIM_SPEED 50 // Runs every 24 seconds
#define IS_LEATHER_LAYER texelFetch(Sampler0, ivec2(0.0, 1.0), 0) == vec4(1.0) // If it's leather_layer_X.png texture

#define fetchTextureInfo(base, pixel) texelFetch(Sampler0, ivec2(TEX_RES * 4.0 * base + 0.5 + pixel, 0), 0)

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);

    texCoord0 = UV0;

    ivec2 atlasSize = textureSize(Sampler0, 0);
    float armorAmount = atlasSize.x / (TEX_RES * 4.0);
    float maxFrames = atlasSize.y / (TEX_RES * 2.0);

    texCoord0.x /= armorAmount;
    texCoord0.y /= maxFrames;

    vec4 color;
    vec4 tint = Color;

    nextFrameCoords = UV0;
    interpolClock = 0.0;
    h_offset = 1.0 / armorAmount;
    emissivity = 0.0;

    // If it's a leather armor
    isLeatherLayer = float(IS_LEATHER_LAYER);

    if (isLeatherLayer > 0.5) {
        // Texture properties contains extra info about the armor texture, such as to enable shading
        vec4 textureProperties = vec4(0.0);

        // Custom color is the color of the armor
        vec4 colorMatch = vec4(0.0);

        // Loop through all armors in the texture atlas
        for (int i = 1; i < (armorAmount + 1); i++) {
            // Check if the current armor is the one we're looking for
            colorMatch = fetchTextureInfo(i, 0.0); // ~(0,0)
            if (tint == colorMatch) {
                texCoord0.x += (h_offset * i);

                vec4 animInfo = fetchTextureInfo(i, 1.0); // ~(1,0)
                animInfo.rgb *= animInfo.a * 255.0;

                textureProperties = fetchTextureInfo(i, 2.0); // ~(2,0)
                textureProperties.rgb *= textureProperties.a * 255.0;

                // If the armor is animated
                if (animInfo != vec4(0)) {
                    // oh god it's animated
                    // animInfo = rgb(amount of frames, speed, interpolation [1 or 0] )
                    // textureProperties = rgb(emissive, tint, N/A)
                    // fract(GameTime * 1200) blinks every second so [0,1] spans every second.
                    float timer = floor(mod(GameTime * ANIM_SPEED * animInfo.g, animInfo.r));

                    // If the animation is interpolated
                    interpolClock = fract(GameTime * ANIM_SPEED * animInfo.g) * ceil(animInfo.b);

                    float v_offset = (TEX_RES * 2.0) / atlasSize.y * timer;
                    nextFrameCoords = texCoord0;
                    texCoord0.y += v_offset;
                    nextFrameCoords.y += (TEX_RES * 2.0) / atlasSize.y * mod(timer + 1, animInfo.r);
                }
                break;
            }
        }

        bool isTinted = textureProperties.g > 0;
        bool isEmissive = textureProperties.r > 0;

        isFirstArmor = float(texCoord0.x < (1 / armorAmount));
        emissivity = textureProperties.r;

        // If the armor is supposed to be the normal leather armor, return early and don't modify vertexColor.
        if (isFirstArmor > 0.5) return;

        if (isTinted && isEmissive) { // If the armor is tinted and emissive
            vertexColor = tint;
        } else if (isEmissive) { // If the armor is not tinted but is emissive
            vertexColor = vec4(1.0);
        } else if (!isTinted) { // If the armor is not tinted and not emissive
            vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1.0));
        }
    }
}
