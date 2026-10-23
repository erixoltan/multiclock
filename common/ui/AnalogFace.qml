import QtQuick 2.15

// Self-drawn analog face. Pure QtQuick: no Plasma imports, so it can be
// previewed with dev/preview.qml outside Plasma.
Item {
    id: face

    // ---- Inputs --------------------------------------------------------
    property date time: new Date()
    property color fg: "white"
    property color accent: "#3daee9"
    property string fontFamily: ""
    property bool showDial: false     // filled circle behind the face
    property color dialColor: "#232629"
    property bool showHourHand: true
    property bool showMinuteHand: true
    property bool showSecondHand: false
    property bool dial24h: false
    property int tickCount: 60        // 0 hides ticks
    property bool showNumerals: true

    // ---- Geometry ------------------------------------------------------
    readonly property real radius: Math.min(width, height) / 2
    readonly property real cx: width / 2
    readonly property real cy: height / 2
    readonly property int hoursOnDial: dial24h ? 24 : 12

    // A lone hand is the only reference, so it reaches the ticks.
    readonly property int handCount: showHourHand + showMinuteHand + showSecondHand
    readonly property bool soloHand: handCount === 1

    // ---- Angles (degrees clockwise from 12 o'clock / midnight) ----------
    readonly property real secondsFrac: time.getSeconds() / 60
    readonly property real minutesFrac: (time.getMinutes() + secondsFrac) / 60
    readonly property real hourAngle:
        ((time.getHours() % hoursOnDial) + minutesFrac) / hoursOnDial * 360
    readonly property real minuteAngle: minutesFrac * 360
    readonly property real secondAngle: secondsFrac * 360

    // Major ticks fall on the hours when tickCount divides evenly.
    readonly property int majorEvery:
        (tickCount > 0 && tickCount % hoursOnDial === 0) ? tickCount / hoursOnDial : 0

    // ---- Dial ----------------------------------------------------------
    Rectangle {
        visible: face.showDial
        width: face.radius * 2
        height: width
        radius: face.radius
        x: face.cx - face.radius
        y: face.cy - face.radius
        color: face.dialColor
        antialiasing: true
    }

    // ---- Tick marks ----------------------------------------------------
    Repeater {
        model: face.tickCount
        Rectangle {
            readonly property bool major: face.majorEvery > 0 && index % face.majorEvery === 0
            width: major ? face.radius * 0.03 : face.radius * 0.012
            height: major ? face.radius * 0.10 : face.radius * 0.05
            radius: width / 2
            color: face.fg
            opacity: major ? 1.0 : 0.6
            antialiasing: true
            x: face.cx - width / 2
            y: face.cy - face.radius * 0.95
            transform: Rotation {
                origin.x: width / 2
                origin.y: face.radius * 0.95
                angle: index * 360 / face.tickCount
            }
        }
    }

    // ---- Numerals ------------------------------------------------------
    Repeater {
        model: face.showNumerals ? face.hoursOnDial : 0
        Text {
            readonly property real a: index / face.hoursOnDial * 2 * Math.PI
            readonly property real r: face.radius * (face.dial24h ? 0.76 : 0.72)
            text: (!face.dial24h && index === 0) ? "12" : String(index)
            color: face.fg
            font.family: face.fontFamily
            font.pixelSize: face.radius * (face.dial24h ? 0.10 : 0.15)
            x: face.cx + r * Math.sin(a) - width / 2
            y: face.cy - r * Math.cos(a) - height / 2
        }
    }

    // ---- Hands ---------------------------------------------------------
    // A hand is a rectangle standing on the center point, rotated about its
    // base. `tail` extends it a little past the center. Sizes are fractions
    // of `dial` (the face radius).
    component Hand: Rectangle {
        property real dial: 0
        property real length: 0.5
        property real thickness: 0.04
        property real tail: 0.12
        property real handAngle: 0
        width: dial * thickness
        height: dial * (length + tail)
        radius: width / 2
        antialiasing: true
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - dial * length
        transform: Rotation {
            origin.x: width / 2
            origin.y: dial * length
            angle: handAngle
        }
    }

    Hand {
        visible: face.showHourHand
        dial: face.radius
        length: face.soloHand ? 0.84 : 0.5
        thickness: face.soloHand ? 0.035 : 0.06
        color: face.soloHand ? face.accent : face.fg
        handAngle: face.hourAngle
    }

    Hand {
        visible: face.showMinuteHand
        dial: face.radius
        length: face.soloHand ? 0.84 : 0.78
        thickness: face.soloHand ? 0.035 : 0.04
        color: face.soloHand ? face.accent : face.fg
        handAngle: face.minuteAngle
    }

    Hand {
        visible: face.showSecondHand
        dial: face.radius
        length: 0.86
        thickness: 0.015
        tail: 0.18
        color: face.accent
        handAngle: face.secondAngle
    }

    // Center cap
    Rectangle {
        visible: face.handCount > 0
        width: face.radius * 0.09
        height: width
        radius: width / 2
        x: face.cx - width / 2
        y: face.cy - height / 2
        color: (face.showSecondHand || face.soloHand) ? face.accent : face.fg
        antialiasing: true
    }
}
