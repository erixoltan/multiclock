import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    property alias cfg_timeFormat: timeField.text
    property alias cfg_showDate: dateCheck.checked
    property alias cfg_dateFormat: dateField.text

    QQC2.TextField {
        id: timeField
        Kirigami.FormData.label: i18n("Time format:")
        placeholderText: "hh:mm"
    }

    QQC2.Label {
        text: i18n("Qt format codes: HH = 24-hour, h = 12-hour, mm = minutes, ss = seconds, AP = AM/PM.")
        wrapMode: Text.WordWrap
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        font: Kirigami.Theme.smallFont
        opacity: 0.8
    }

    QQC2.CheckBox {
        id: dateCheck
        text: i18n("Show date")
    }

    QQC2.TextField {
        id: dateField
        Kirigami.FormData.label: i18n("Date format:")
        enabled: dateCheck.checked
        placeholderText: "dddd, MMMM d"
    }
}
