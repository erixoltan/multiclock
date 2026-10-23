import QtQuick 2.15
import QtQuick.Window 2.15
import "../common/ui"

// Standalone preview of all faces, outside Plasma.
// Run:  make preview   (or: qmlscene dev/preview.qml)
// Faces are pure QtQuick, so this needs no KDE libraries.
Window {
    id: win
    width: 960
    height: 640
    visible: true
    color: "#232629"
    title: "MultiClock preview"

    readonly property color fg: "#eff0f1"
    readonly property color accent: "#3daee9"

    property date now: new Date()
    Timer {
        interval: 250; running: true; repeat: true
        onTriggered: win.now = new Date()
    }

    Grid {
        anchors.fill: parent
        anchors.margins: 20
        columns: 3
        spacing: 20
        readonly property real cellW: (width - spacing * 2) / 3
        readonly property real cellH: (height - spacing) / 2

        AnalogFace {
            width: parent.cellW; height: parent.cellH
            time: win.now; fg: win.fg; accent: win.accent
            showSecondHand: true
        }
        AnalogFace {
            width: parent.cellW; height: parent.cellH
            time: win.now; fg: win.fg; accent: win.accent
            showMinuteHand: false; tickCount: 144
            showDial: true; dialColor: "#80000000"
        }
        AnalogFace {
            width: parent.cellW; height: parent.cellH
            time: win.now; fg: win.fg; accent: win.accent
            showHourHand: false; showNumerals: false; tickCount: 12
        }
        DigitalFace {
            width: parent.cellW; height: parent.cellH
            time: win.now; fg: win.fg
            timeFormat: "HH:mm:ss"; showDate: true
        }
        TextFace {
            width: parent.cellW; height: parent.cellH
            time: win.now; fg: win.fg
        }
        TextFace {
            width: parent.cellW; height: parent.cellH
            time: win.now; fg: win.fg
            step: 30
            phrases: "22:00-6:00 = Sleep\n:00 = {Hour} sharp\n:30 = {Hour} and a half"
        }
    }
}
