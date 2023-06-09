# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2023-06-07 - Godot 4 support
**🎉 Levelblock has been updated to support Godot 4! 🎉**

Check out the [godot-3 branch](https://github.com/Reun-Media/godot-levelblock/tree/godot-3) for 1.x version that supports Godot 3.5.

Further development efforts will primarily be focused on the new version and we can't guarantee new features for Godot 3.5, but if you encounter any bugs feel free to [submit an issue](https://github.com/Reun-Media/godot-levelblock/issues) or [open a pull request](https://github.com/Reun-Media/godot-levelblock/pulls).

### Added
- Example tileset is bundled with the plugin

### Changed
- Updated plugin to support Godot 4
- Smaller Inspector texture preview

## [1.0.2] - 2022-12-22
### Fixed
- Global transforms are only set inside scene tree
- Physics bodies now have object instance attached (enables getting collider via raycasts)

## [1.0.1] - 2022-12-17
### Fixed
- Fixed node visibility not being applied
- Fixed global transformation not being applied

## [1.0.0] - 2022-12-15
- Initial release

[unreleased]: https://github.com/Reun-Media/godot-levelblock/compare/2.0.0...HEAD
[2.0.0]: https://github.com/Reun-Media/godot-levelblock/compare/1.0.2...2.0.0
[1.0.2]: https://github.com/Reun-Media/godot-levelblock/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/Reun-Media/godot-levelblock/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/Reun-Media/godot-levelblock/releases/tag/1.0.0
