# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-04

### Added

- Initial release of WP POT Generator action
- Docker-based action wrapping WP-CLI's `wp i18n make-pot` command
- Support for WordPress plugins and themes
- Auto-detection of plugin/theme slug from source directory basename
- Auto-detection of text domain from plugin/theme `Text Domain:` header
- 10 configurable inputs: `working-directory`, `source`, `output-file`, `slug`, `domain`, `package-name`, `headers`, `exclude`, `include`, `ignore-domain`
- 4 actionable outputs: `output-path`, `output-directory`, `string-count`, `slug`
- `<slug>` placeholder in `output-file` for dynamic slug substitution
- Error handling with GitHub Actions annotations (`::error::`, `::notice::`, `::group::`)
- Comprehensive test suite with plugin and theme fixtures
- CI pipeline with action.yml validation, ShellCheck, actionlint, and E2E tests

[1.0.0]: https://github.com/WPTechnix/wp-pot-generator/releases/tag/v1.0.0
