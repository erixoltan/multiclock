import QtQuick 2.15

// Digital face. Text scales to fit the widget.
Item {
    id: face

    property date time: new Date()
    property color fg: "white"
    property string fontFamily: ""
    property string timeFormat: "hh:mm"
    property bool showDate: false
    property string dateFormat: "dddd, MMMM d"

    Text {
        id: timeText
        width: parent.width
        height: face.showDate ? parent.height * 0.72 : parent.height
        text: Qt.formatDateTime(face.time, face.timeFormat)
        color: face.fg
        font.family: face.fontFamily
        font.pixelSize: height          // upper bound; Fit shrinks it
        minimumPixelSize: 6
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        visible: face.showDate
        anchors.top: timeText.bottom
        width: parent.width
        height: parent.height - timeText.height
        text: Qt.formatDateTime(face.time, face.dateFormat)
        color: face.fg
        opacity: 0.8
        font.family: face.fontFamily
        font.pixelSize: height
        minimumPixelSize: 6
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
    }
}
