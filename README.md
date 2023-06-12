# LevelBlock plugin for Godot 4
![screenshot](https://github.com/Reun-Media/godot-levelblock/assets/37181529/94a5e1c3-e041-46d4-9961-d3cd526bf07a)

![Godot - v4.0](https://img.shields.io/badge/Godot-v4.0-478cbf?style=flat-square&logo=godot-engine&labelColor=25282b)
[![Asset Library](https://img.shields.io/badge/Asset_Library-2ea44f?style=flat-square)](https://godotengine.org/asset-library/asset/1924)

_[Click here for Godot 3.5 version](https://github.com/Reun-Media/godot-levelblock/tree/godot-3)_

**LevelBlock** is a new node for Godot 4 meant for the creation of levels in dungeon crawler -style games.

This node acts as an inside-facing cube, using a texture atlas sheet to display different parts for each face.
## Getting started
1. Download the plugin from GitHub or [Godot Asset Library](https://godotengine.org/asset-library/asset/1924) and install it. See a guide here: [Godot Docs](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)
2. Add new LevelBlock nodes to your scene.
3. Configure the texture sheet (and optionally material) you want to use.
4. Configure the size of the square textures contained in the texture sheet.
5. Customize each face of the LevelBlock using the face values. Negative values disable generating the face.
6. Optionally enable generating collisions, generating occlusion culling and flipping the faces.
## Features
- Use a single texture sheet, with each face displaying a different part of it using an index value. This texture sheet will replace the albedo texture of the material.
- Customize the material or use the included default material.
- Use an arbitary size for the square textures in the atlas.
- Quickly customize the texture displayed on each face.
- Automatic collision generation for visible faces.
- Automatic occluder node generation for visible faces.
- Option to flip faces to face outward instead.
- Uses Godot's server system for optimized results.
## Limitations
- Only square textures supported.
- All textures in the atlas must be the same size.
- Works best if texture filtering is disabled for a pixelated look.
- No support for normal or roughness maps, only albedo.
