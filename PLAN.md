# Plan: Plasma 6 version and publishing

Status as of 2026-10-10; Part 1 updated 2026-10-19. Written on the Plasma 5.27 machine; the Plasma 6 work continues on a different machine that runs Plasma 6.

## Where things stand

- The widget works on Plasma 5.27 (v0.2.0): analog face with any combination of hands and an optional filled dial, digital face, text face with built-in or custom phrases, time zone setting, transparent background.
- Verified on Plasma 5: rendering of all faces in `plasmawindowed`, phrase logic (`make check`), live time zone switching, settings pages loading without QML errors.
- Never verified by clicking: the real settings dialog (saving settings through it), and real transparency on the wallpaper.
- `make preview` has never run on the Plasma 5 machine (no `qmlscene` installed).

## Part 1: Plasma 6 version

**Done 2026-10-19** on this machine after its upgrade to Ubuntu 26.04 / Plasma 6.6, with the layout proposed below (`common/`, `plasma5/`, `plasma6/`, assembled into `build/`). Checked on Plasma 6: `make check`; every face renders in `plasmawindowed` with no QML errors (analog with two hands and with the hour hand alone on a translucent filled dial, digital with seconds and date, text); time zones (Tokyo, New York) give the right time; all four settings pages load and render, the zone list is filled, the Text page scrolls. `ColorSetting.qml` and the faces are shared unchanged. **Not checked yet:** saving settings through the real dialog (Apply), transparency on the real desktop, `make preview` (no Qt 6 `qml` runner installed), the Plasma 5 package after the move (no Plasma 5 here; its files only moved, plus one signal handler written as `function (sourceName, data)`). Known cosmetic difference: in Plasma 6 an unchecked color setting shows an empty swatch rather than the theme color.

The rest of this part is the plan as written before the port.

### Goal

One repo that builds two packages, one for Plasma 5.27 and one for Plasma 6, sharing the faces and phrase logic. Both keep the same features and the same settings names.

### What is shared and what is not

Shared as is (already written to load under Qt 5 and Qt 6):

- `AnalogFace.qml`, `DigitalFace.qml`, `TextFace.qml`, `FuzzyTime.js`
- `contents/config/main.xml` (the settings schema)
- `dev/preview.qml`, `dev/fuzzytime.test.js`

Needs a Plasma 6 variant:

- `main.qml`
- `configGeneral.qml`, `configAnalog.qml`, `configDigital.qml`, `configText.qml`, `ColorSetting.qml`
- `contents/config/config.qml`
- `metadata.json`
- Makefile targets

### Proposed layout (decide at the start of the port)

```
common/          faces, FuzzyTime.js, main.xml
plasma5/         today's main.qml, settings pages, config.qml, metadata.json
plasma6/         the Plasma 6 equivalents
build/plasma5/   assembled package (git-ignored)
build/plasma6/
```

A Makefile step copies `common/` plus one shell into `build/<version>/`, and `install`, `test` and `package` work from there. A package must be a self-contained directory, so some assembly step is needed; copying is simpler and safer than symlinks inside a zip.

### Plasma 6 changes, file by file

The first commit of this project (`1aca9092b`, "multi clock") was written for Plasma 6 and is a useful starting point for `main.qml`, the settings pages and `metadata.json`: `git show 1aca9092b:multiclock/package/contents/ui/main.qml`. It was never run, and it predates the hand checkboxes, custom phrases, time zone and dial, so treat it as a sketch.

- **`metadata.json`**: drop `X-Plasma-API`, `X-Plasma-MainScript` and `ServiceTypes`; add `"X-Plasma-API-Minimum-Version": "6.0"` and `"KPackageStructure": "Plasma/Applet"`.
- **`main.qml`**:
  - Root is `PlasmoidItem`; `fullRepresentation` and `preferredRepresentation` are plain properties on it.
  - Config is `Plasmoid.configuration` (capital P).
  - Theme and units come from `Kirigami.Theme` / `Kirigami.Units`; `PlasmaCore.Types` is still used for `backgroundHints`.
  - Time zone offset: `PlasmaCore.DataSource` is gone from core. The same "time" engine should be available as `import org.kde.plasma.plasma5support as P5Support` with `P5Support.DataSource`. Check this first, since the whole time zone feature depends on it. Keep the logic as it is now: remember the offset together with its zone (`offsetZone`), and refresh `currentTime` when data arrives.
- **Settings pages**:
  - Root is `KCM.SimpleKCM` from `org.kde.kcmutils`, wrapping the `Kirigami.FormLayout`.
  - Row labels stay `Kirigami.FormData.label` (the first commit wrongly used `Kirigami.FormLayout.label`).
  - The zone list on the General page uses the same data source as `main.qml`.
  - Plasma 6 may warn about missing `cfg_<name>Default` properties; harmless.
- **`ColorSetting.qml`**: `import org.kde.kquickcontrols as KQControls`; check `showAlphaChannel` still exists.
- **`config.qml`**: `import org.kde.plasma.configuration` (unversioned).
- **Makefile**: `kpackagetool6`, `plasmoidviewer -a <dir> -f planar` (from `plasma-sdk`) or `plasmawindowed`, and the Qt 6 `qml` runner for `make preview` (`qml6` or `qml-qt6` depending on distro).

### Test checklist on Plasma 6

1. `make check` passes.
2. `make preview` shows all faces.
3. Widget loads with no QML errors in the logs.
4. Each face renders; hour-only, minute-only and all-hands analog.
5. Settings dialog: every page opens, changes apply and survive a restart.
6. Time zone: pick a zone other than the system one; the display changes immediately, not at the next minute.
7. Background off: widget is transparent on the desktop; filled dial with a translucent color looks right.
8. Custom phrases: edit, see the "Right now" preview, see the bad-line warning.

Items 5 and 7 were never checked by hand on Plasma 5 either; check them there too when back on that machine.

### Docs to update when the port lands

- `CLAUDE.md`: the "Plasma 5.27 / Qt 5.15, not Plasma 6" section becomes a two-target section, and the dev-loop section lists both tool sets.
- `README.md`: requirements and usage for both versions.

## Part 2: Publishing

### Getting the code out of the private monorepo

MultiClock currently lives in the private `~/code` monorepo. To work on another machine and to publish, it needs its own repo.

1. Commit and push any outstanding work in the monorepo.
2. Create a public GitHub repo (name to be chosen, e.g. `multiclock`) and copy this directory into it as the root, the same arrangement as gal3.
3. Decide whether the monorepo copy stays as the working copy or the public repo becomes the only one. Recommended: the public repo becomes the only one, to avoid two diverging copies.

### Before the first release

- Add a `LICENSE` file with the GPL-2.0-or-later text (the metadata already declares it).
- Set `Website` in `metadata.json` to the repo URL.
- Take screenshots: analog (two hands, hour only, filled dial on wallpaper), digital, text with custom phrases, the settings pages.
- Bump versions and tag (`v0.2.0` for the Plasma 5 package; the Plasma 6 package gets its version when it works).

### Release channels

- **GitHub releases**: attach `dist/multiclock-<version>-plasma5.plasmoid` and `-plasma6.plasmoid` to each tag. Install with `kpackagetool5 -t Plasma/Applet -i <file>` or `kpackagetool6 -t Plasma/Applet -i <file>`.
- **KDE Store (store.kde.org)**: two listings, one under Plasma 5 widgets and one under Plasma 6 widgets, each with its own file. This makes the widget installable from "Add Widgets… → Get New Widgets…". Needs an account; uploads are done by hand on the website.

### Order of work

1. ~~Commit, split out into the public repo.~~ Done 2026-10-23: https://github.com/erixoltan/multiclock, via `tools/publish.sh`.
2. ~~Port to Plasma 6 on the Plasma 6 machine (Part 1).~~ Done 2026-10-19.
3. ~~License, website field, screenshots.~~ Done 2026-10-23 (`docs/`; author email oss@zoltan.org as in the aquarium). Settings-page screenshots not taken.
4. ~~Tag, GitHub release, KDE Store listings.~~ Done 2026-10-23: v0.2.0 on GitHub; one store listing with both files, uploaded by Erik: https://store.kde.org/p/2380181
