import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "FuzzyTime.js" as FuzzyTime

// Root of the widget. Owns the single time source and resolves settings
// (theme fallbacks etc.), then hands plain values to whichever face is active.
// Faces never touch Plasmoid.configuration or the Plasma theme directly, which
// keeps them pure QtQuick and previewable with dev/preview.qml.
Item {
    id: root

    readonly property var cfg: plasmoid.configuration

    // ---- Resolved appearance -------------------------------------------
    readonly property color fgColor: cfg.foregroundColor !== ""
        ? cfg.foregroundColor : PlasmaCore.Theme.textColor
    readonly property color accentColor: cfg.accentColor !== ""
        ? cfg.accentColor : PlasmaCore.Theme.highlightColor
    readonly property string fontFamily: cfg.fontFamily !== ""
        ? cfg.fontFamily : PlasmaCore.Theme.defaultFont.family

    readonly property color dialColor: cfg.dialColor !== ""
        ? cfg.dialColor : PlasmaCore.Theme.backgroundColor

    // Text face: phraseSet 0-2 are the built-in sets, 3 is the user's own.
    readonly property bool customPhrases: cfg.phraseSet === 3
    readonly property string phrases: customPhrases
        ? cfg.customPhrases : FuzzyTime.preset(cfg.phraseSet).rules
    readonly property int phraseStep: customPhrases
        ? cfg.customStep : FuzzyTime.preset(cfg.phraseSet).step

    // ---- Time zone -----------------------------------------------------
    // An empty timeZone setting means the system zone. Otherwise Plasma's
    // time engine supplies that zone's current UTC offset (it knows about
    // daylight saving); it is used for the offset only, not as a clock.
    // The offset is remembered together with the zone it belongs to, so a
    // stale one is never applied after the setting changes.
    readonly property string timeZone: cfg.timeZone
    property string offsetZone: ""
    property real zoneOffset: 0     // seconds east of UTC, for offsetZone

    PlasmaCore.DataSource {
        engine: "time"
        connectedSources: root.timeZone !== "" ? [root.timeZone] : []
        interval: 60000
        onNewData: function (sourceName, data) {
            root.zoneOffset = data.Offset;
            root.offsetZone = sourceName;
            root.currentTime = root.now();
        }
    }

    onTimeZoneChanged: currentTime = now()

    // The current time as a Date whose local fields (getHours() etc.) read
    // as wall-clock time in the chosen zone, which is what the faces use.
    function now() {
        const d = new Date();
        if (timeZone === "" || offsetZone !== timeZone)
            return d;
        return new Date(d.getTime() + (zoneOffset + d.getTimezoneOffset() * 60) * 1000);
    }

    // ---- Time source ---------------------------------------------------
    property date currentTime: now()

    // Only tick every second when something on screen shows seconds.
    readonly property bool needsSeconds:
        (cfg.displayMode === 0 && cfg.showSecondHand)
        || (cfg.displayMode === 1 && /s/.test(cfg.timeFormat))

    function scheduleNextTick() {
        // Align to the next second/minute boundary so the display doesn't
        // drift, and recover cleanly after suspend/resume.
        const now = new Date();
        const ms = needsSeconds
            ? 1000 - now.getMilliseconds()
            : 60000 - (now.getSeconds() * 1000 + now.getMilliseconds());
        ticker.interval = Math.max(ms + 5, 20);
        ticker.restart();
    }

    Timer {
        id: ticker
        repeat: false
        onTriggered: {
            root.currentTime = root.now();
            root.scheduleNextTick();
        }
    }

    onNeedsSecondsChanged: {
        currentTime = now();
        scheduleNextTick();
    }
    Component.onCompleted: scheduleNextTick()

    // ---- Widget setup --------------------------------------------------
    Plasmoid.backgroundHints: cfg.showBackground
        ? PlasmaCore.Types.DefaultBackground
        : PlasmaCore.Types.NoBackground

    // Desktop widget only: always show the full representation.
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    Plasmoid.fullRepresentation: Item {
        Layout.minimumWidth: PlasmaCore.Units.gridUnit * 4
        Layout.minimumHeight: PlasmaCore.Units.gridUnit * 2
        Layout.preferredWidth: PlasmaCore.Units.gridUnit * 12
        Layout.preferredHeight: root.cfg.displayMode === 0
            ? PlasmaCore.Units.gridUnit * 12
            : PlasmaCore.Units.gridUnit * 6

        Loader {
            anchors.fill: parent
            anchors.margins: PlasmaCore.Units.smallSpacing
            sourceComponent: [analogFace, digitalFace, textFace][root.cfg.displayMode] || analogFace
        }
    }

    // ---- Faces ---------------------------------------------------------
    // Declared as Components (not Loader.source URLs) so bindings stay live.
    Component {
        id: analogFace
        AnalogFace {
            time: root.currentTime
            fg: root.fgColor
            accent: root.accentColor
            fontFamily: root.fontFamily
            showDial: root.cfg.showDial
            dialColor: root.dialColor
            showHourHand: root.cfg.showHourHand
            showMinuteHand: root.cfg.showMinuteHand
            showSecondHand: root.cfg.showSecondHand
            dial24h: root.cfg.dial24h
            tickCount: root.cfg.tickCount
            showNumerals: root.cfg.showNumerals
        }
    }

    Component {
        id: digitalFace
        DigitalFace {
            time: root.currentTime
            fg: root.fgColor
            fontFamily: root.fontFamily
            timeFormat: root.cfg.timeFormat
            showDate: root.cfg.showDate
            dateFormat: root.cfg.dateFormat
        }
    }

    Component {
        id: textFace
        TextFace {
            time: root.currentTime
            fg: root.fgColor
            fontFamily: root.fontFamily
            phrases: root.phrases
            step: root.phraseStep
        }
    }
}
