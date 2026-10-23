PLASMOID_ID := com.erikzoltan.multiclock

# Each package is assembled into build/<version>/ from its shell (plasma5/ or plasma6/:
# metadata.json, main.qml, settings pages) plus common/ (faces, FuzzyTime.js, ColorSetting.qml,
# the settings schema). A package must be one self-contained directory.
#
# The targets without a suffix are for Plasma 6, which this machine runs; the ones ending in 5
# are for a Plasma 5.27 machine.

# Qt 6 QML runner for `make preview` (Ubuntu/Debian package: qml6, binary qml6 or qml-qt6).
# Override with: make preview QML=/path/to/runner
QML ?= qml6

.PHONY: install uninstall test install5 uninstall5 test5 preview check restart logs package clean

build/%: FORCE
	rm -rf $@
	mkdir -p $@
	cp -r $*/. $@/
	cp common/ui/* $@/contents/ui/
	cp common/config/* $@/contents/config/
FORCE:
.PRECIOUS: build/%

## Install or update the widget for the current user (Plasma 6)
install: build/plasma6
	kpackagetool6 -t Plasma/Applet -u build/plasma6 2>/dev/null || kpackagetool6 -t Plasma/Applet -i build/plasma6

uninstall:
	kpackagetool6 -t Plasma/Applet -r $(PLASMOID_ID)

## Run the installed widget in a standalone window (right-click to configure)
test: install
	plasmawindowed $(PLASMOID_ID)

## The same for Plasma 5.27
install5: build/plasma5
	kpackagetool5 -t Plasma/Applet -u build/plasma5 2>/dev/null || kpackagetool5 -t Plasma/Applet -i build/plasma5

uninstall5:
	kpackagetool5 -t Plasma/Applet -r $(PLASMOID_ID)

test5: install5
	plasmawindowed $(PLASMOID_ID)

## Preview the faces without Plasma (fast iteration on drawing). The faces load under Qt 5 and
## Qt 6, so QML=qmlscene works on a Plasma 5 machine.
preview:
	$(QML) dev/preview.qml

## Test the fuzzy-phrase logic (needs node)
check:
	node dev/fuzzytime.test.js

## Restart plasmashell so an updated widget on the real desktop picks up changes
restart:
	systemctl --user restart plasma-plasmashell

## Follow plasmashell logs (QML errors show up here)
logs:
	journalctl --user -f -t plasmashell

## Build the store / release packages into dist/: multiclock-<version>-plasma5.plasmoid and
## multiclock-<version>-plasma6.plasmoid, each with the LICENSE inside
package: build/plasma5 build/plasma6
	rm -rf dist; mkdir -p dist
	for v in plasma5 plasma6; do \
	  cp LICENSE build/$$v/; \
	  n=$$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['KPlugin']['Version'])" build/$$v/metadata.json); \
	  (cd build/$$v && zip -qr -X ../../dist/multiclock-$$n-$$v.plasmoid .); \
	done
	ls -l dist

clean:
	rm -rf build dist *.plasmoid
