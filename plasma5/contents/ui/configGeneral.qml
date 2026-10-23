import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

// Settings page: General. Each `cfg_<name>` property is two-way bound by
// Plasma to the matching entry in contents/config/main.xml.
Kirigami.FormLayout {
    property alias cfg_displayMode: modeCombo.currentIndex
    property alias cfg_showBackground: backgroundCheck.checked
    property alias cfg_foregroundColor: fgSetting.value
    property alias cfg_accentColor: accentSetting.value
    property string cfg_fontFamily
    property string cfg_timeZone

    // Used only for its list of time zone names.
    PlasmaCore.DataSource {
        id: zones
        engine: "time"
    }

    QQC2.ComboBox {
        id: modeCombo
        Kirigami.FormData.label: i18n("Display:")
        model: [i18n("Analog"), i18n("Digital"), i18n("Text")]
    }

    QQC2.ComboBox {
        id: zoneCombo
        Kirigami.FormData.label: i18n("Time zone:")
        model: [i18n("System")].concat(
            zones.sources.filter(function (z) { return z !== "Local"; }).sort())
        currentIndex: cfg_timeZone === "" ? 0 : Math.max(0, model.indexOf(cfg_timeZone))
        onActivated: cfg_timeZone = currentIndex === 0 ? "" : currentText
    }

    QQC2.CheckBox {
        id: backgroundCheck
        Kirigami.FormData.label: i18n("Background:")
        text: i18n("Show widget background")
    }

    QQC2.Label {
        text: i18n("Turn this off for a transparent widget. The analog face can then draw its own round dial (see Analog).")
        wrapMode: Text.WordWrap
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        font: Kirigami.Theme.smallFont
        opacity: 0.8
    }

    Item { Kirigami.FormData.isSection: true }

    ColorSetting {
        id: fgSetting
        Kirigami.FormData.label: i18n("Foreground color:")
        themeColor: Kirigami.Theme.textColor
    }

    ColorSetting {
        id: accentSetting
        Kirigami.FormData.label: i18n("Accent color:")
        themeColor: Kirigami.Theme.highlightColor
    }

    QQC2.ComboBox {
        id: fontCombo
        Kirigami.FormData.label: i18n("Font:")
        model: [i18n("Theme default")].concat(Qt.fontFamilies())
        currentIndex: cfg_fontFamily === "" ? 0 : Math.max(0, model.indexOf(cfg_fontFamily))
        onActivated: cfg_fontFamily = currentIndex === 0 ? "" : currentText
    }
}
