# WP POT Generator

Generate `.pot` translation files for WordPress plugins and themes using [WP-CLI](https://wp-cli.org/)'s [`wp i18n make-pot`](https://developer.wordpress.org/cli/commands/i18n/make-pot/).

## Quick start

Add this step to your workflow:

```yaml
- name: Generate POT file
  uses: WPTechnix/wp-pot-generator@v1
```

That's it. The action scans your repository, auto-detects the plugin/theme slug and text domain, and writes a `.pot` file to `./languages/<slug>.pot`.

## Inputs

All inputs are optional. Defaults work for most standard setups.

| Input | Default | Description |
|---|---|---|
| `working-directory` | `.` | Root for relative paths. Relative to repo root, or absolute. |
| `source` | `.` | Directory to scan for translatable strings. Relative to working-directory, or absolute. |
| `output-file` | `./languages/<slug>.pot` | Where to write the `.pot` file. `<slug>` is replaced with the actual slug. Relative to working-directory, or absolute. |
| `slug` | _(auto-detected)_ | Plugin or theme slug. Auto-detected from the source directory name. For example, if source is `/repos/my-plugin`, slug becomes `my-plugin`. |
| `domain` | _(auto-detected)_ | Text domain to filter by. Auto-detected from the plugin's `Text Domain:` header or theme's `style.css`. When set, only strings with this domain are extracted. |
| `package-name` | _(none)_ | Value for the `Project-Id-Version` POT header. Defaults to the slug if not set. |
| `headers` | _(none)_ | Additional POT headers as a JSON string. Example: `{"Report-Msgid-Bugs-To":"https://example.com"}` |
| `exclude` | _(none)_ | Comma-separated patterns to skip. Example: `vendor,node_modules,build` |
| `include` | _(none)_ | Comma-separated patterns to scan **only** these paths. Files outside the patterns are ignored. |
| `ignore-domain` | `false` | When `true`, extract strings with **any** text domain. Useful when your plugin bundles third-party libraries. |

## Outputs

These are available for downstream steps:

| Output | Description |
|---|---|
| `output-path` | Absolute path to the generated `.pot` file. |
| `output-directory` | Absolute path to the directory containing the `.pot` file. |
| `string-count` | Number of translatable strings found (excluding the POT header). |
| `slug` | The slug that was used (auto-detected or explicitly set). |

## Examples

### Plugin with custom values

Use when the directory name differs from your canonical slug, or you want full control.

```yaml
- name: Generate POT
  uses: WPTechnix/wp-pot-generator@v1
  with:
    slug: my-plugin
    domain: my-plugin
    package-name: My Plugin
```

### WordPress theme

Themes declare their text domain in `style.css` instead of a PHP file.

```yaml
- name: Generate POT
  uses: WPTechnix/wp-pot-generator@v1
  with:
    working-directory: ./my-theme
    output-file: ./languages/my-theme.pot
```

### Exclude third-party directories

Skip vendor, build, or dependency directories.

```yaml
- name: Generate POT
  uses: WPTechnix/wp-pot-generator@v1
  with:
    exclude: "vendor,node_modules,build,dist"
```

### Scan only specific files

Limit scanning to certain paths when your source is large.

```yaml
- name: Generate POT
  uses: WPTechnix/wp-pot-generator@v1
  with:
    include: "includes/*,templates/*"
```

### Extract all strings (ignore text domain)

Catch strings from third-party libraries that use their own domain.

```yaml
- name: Generate POT
  uses: WPTechnix/wp-pot-generator@v1
  with:
    ignore-domain: true
```

### Use outputs in later steps

Report or upload the generated file.

```yaml
- name: Generate POT
  id: pot
  uses: WPTechnix/wp-pot-generator@v1

- name: Report result
  run: |
    echo "Found ${{ steps.pot.outputs.string-count }} translatable strings"
    echo "POT saved to ${{ steps.pot.outputs.output-path }}"
```

### Full CI/CD integration

Generate the POT on every push and save it as a build artifact.

```yaml
name: Generate translations

on:
  push:
    branches: [main]

jobs:
  pot:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate POT
        id: pot
        uses: WPTechnix/wp-pot-generator@v1
        with:
          slug: my-plugin
          domain: my-plugin
          package-name: My Plugin
          exclude: "vendor,node_modules"

      - name: Upload POT
        uses: actions/upload-artifact@v4
        with:
          name: translations
          path: ${{ steps.pot.outputs.output-directory }}
```

## How it works

This action runs `wp i18n make-pot` inside the official [WP-CLI Docker image](https://hub.docker.com/_/wordpress/). Your repository is mounted into the container, the source directory is scanned for `__()` and `_e()` calls, and the resulting `.pot` file is written back to your workspace.

The entrypoint script handles path resolution, slug and domain auto-detection, optional WP-CLI flags, and outputs the result for downstream steps. Refer to the [WP-CLI documentation](https://developer.wordpress.org/cli/commands/i18n/make-pot/) for details on how strings are extracted.

## Prerequisites

Your repository needs to contain a WordPress **plugin** or **theme** with a text domain declared:

- **Plugin:** add `Text Domain: my-plugin` to the main plugin file's comment block.
- **Theme:** add `Text Domain: my-theme` to `style.css`.

Without these, WP-CLI will fall back to the directory name as the text domain.

## License

MIT
