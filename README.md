# Dora Visual Editor Plugin

Downloadable Dora SSR 2D Visual Editor package.

This repository is a static ResourceDownloader-compatible plugin registry:

- `api/v1/package-list-version` — cache bust version metadata.
- `api/v1/packages` — package list consumed by Dora ResourceDownloader.
- `assets/repos.json` — title/description/category metadata.
- `assets/<package>/banner.jpg` — preview image.
- GitHub Releases — stores the downloadable zip package.

## Use in Dora SSR

Open Dora SSR → Download / ResourceDownloader, then set the resource URL to this repository's raw/static host URL.

Recommended raw base URL:

```text
https://raw.githubusercontent.com/dsadsasdaddas/dora-visual-editor-plugin/main
```

The package will be extracted to:

```text
<Content.writablePath>/Download/dora-visual-editor
```

Then ResourceDownloader can run `init.lua`.

## Build package locally

```bash
python3 scripts/build_package.py /path/to/Dora-SSR
```

This copies runtime Lua/TS source files from Dora SSR into `src/`, creates `dist/dora-visual-editor-<version>.zip`, and updates static manifest files.
