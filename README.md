# <u>Fancy Pants</u>

**You are free to use and distribute this pack (non-commercially) without any credit to the original author of the shader (*It would be appreciated though :)*). If used commercially please include some form of credit containing "Ancientkingg"**

Fancy Pants is a 1.17 vanilla core shader that allows datapack developers to add custom armor to the game with custom coloured leather armor.

**<u>Annotation</u>**

Any pixel coordinates prefixed with `~` will be relative to the armor texture itself and will not be absolute. For example `~(0,0)` in absolute coordinates could refer to `(64,0)`, `(128,0)` etc. Otherwise, assume the pixel coordinate is absolute.

**\*** The default speed is (roughly) 24 seconds per frame. So to get 1 frame per second the speed must be set to 24.

**\*\*** This is a boolean and only has two states: on (`> 0`) and off (`0`).

###### <u>Requirements</u>

- `leather_layer_1_overlay` and `leather_layer_2_overlay` must at all times remain completely transparent.

- Fancy Pants supports different texture resolution, but it must be specified in the shader. To change the texture resolution from the default `16` to something else, go to `assets/minecraft/shaders/core/rendertype_armor_cutout_no_cull.fsh`; go to line 3 and change the value of `TEX_RES`. The texture resolution is equal to the width of a **single** armor texture divided by 4. It is not possible to set different texture resolutions per armor texture, but you can however just upscale the textures in the png.

- The pixel located at `(0, 1)` in `leather_layer_1.png` and  `leather_layer_2.png` must at all times be white (`rgba(255,255,255,255)`).

- The pixel located at `~(0,0)` will be the color assigned to the armor texture. If two armor textures have the same color, only the most left one will be recognized.

- An animated armor texture requires a marker pixel at `~(0,1)` of the armor texture.  This pixel contains `rgb(amount of frames, speed*, interpolation**)`.See `leather_layer_1.png` in `assets/minecraft/textures/models/armor/`.

- The pixel located at `~(0,2)` contains information about extra texture properties. Currently this shader supports: toggling color tinting (by default disabled) and emissivity (both partial and full). `rgb(emissivity, tint, N/A)`. Emissivity** can be set to 1 to allow for partial emissivity and `> 1` to enable full emissivity.

- If partial emissivity is enabled the armor texture to the right will be treated as an emissivity map, where the alpha of the pixel will be treated as the amount of emissivity.

  

## How to use

You are able to interact with the shader through the `leather_layer_1.png` and `leather_layer_2.png` located in `assets/minecraft/textures/models/armor`. An example of how those files could look is added to this example pack. To add new armor types you simply insert your armor texture to the right in the aforementioned png files, as shown in this pack.

The shader supports 2 formats: non-animated and animated.

### Non-animated

Add an armor texture to the right in `leather_layer_1.png` and/or `leather_layer_2.png`, add a custom color with `255` alpha at `~(0,0)` and you're done. To access the newly added custom armor texture, you simply equip the corresponding colored leather armor with the color.                                                       (Formula for that is `r << 16 + g << 8 + b`)

### Animated

Fancy Pants supports animated textures (*wow no-one expected that with the heading name*). To add an animated texture, simply add frames below the corresponding armor texture (See `leather_layer_1.png`). Secondly, it is required to add some information for the shader at `~(0,1)`: `rgb(amount of frames, speed*, interpolation**)`.

### Emissivity map

Fancy Pants supports an emissivity map, meaning you can partially make your armor texture emissive. If partial emissivity is enabled the armor texture to the right will be treated as an emissivity map, where the alpha of the pixel will be treated as the amount of emissivity.



If you have any questions feel free to ping me in any discord or message me `Ancientkingg#0420`

![Images](https://media.discordapp.net/attachments/157097006500806656/853186114017558558/unknown.png)
### Tutorial Video by VelVoxelRaptor
![Tutorial Video by VelVoxelRaptor](https://user-images.githubusercontent.com/27242001/141520994-5b5e99e7-f0ac-4cb4-9a01-faaf750fa569.gif)
