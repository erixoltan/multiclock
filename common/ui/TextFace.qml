import QtQuick 2.15
import "FuzzyTime.js" as FuzzyTime

// Text ("fuzzy") face. Phrase logic and the rule format live in FuzzyTime.js.
Item {
    id: face

    property date time: new Date()
    property color fg: "white"
    property string fontFamily: ""
    property string phrases: FuzzyTime.preset(0).rules   // rule text
    property int step: FuzzyTime.preset(0).step          // round to this many minutes

    Text {
        anchors.fill: parent
        text: FuzzyTime.phrase(face.time, face.phrases, face.step)
        color: face.fg
        font.family: face.fontFamily
        font.pixelSize: height
        minimumPixelSize: 6
        fontSizeMode: Text.Fit
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
