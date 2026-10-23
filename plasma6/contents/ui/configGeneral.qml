import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasma5support as P5Support

// Settings page: General. Each `cfg_<name>` property is two-way bound by
// Plasma to the matching entry in contents/config/main.xml.
KCM.SimpleKCM {
    id: page

    property alias cfg_displayMode: modeCombo.currentIndex
    property alias cfg_showBackground: backgroundCheck.checked
    property alias cfg_foregroundColor: fgSetting.value
    property alias cfg_accentColor: accentSetting.value
    property string cfg_fontFamily
    property string cfg_timeZone

    Kirigami.FormLayout {
        // Used only for its list of time zone names.
        P5Support.DataSource {
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
            currentIndex: page.cfg_timeZone === "" ? 0 : Math.max(0, model.indexOf(page.cfg_timeZone))
            onActivated: page.cfg_timeZone = currentIndex === 0 ? "" : currentText
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
            currentIndex: page.cfg_fontFamily === "" ? 0 : Math.max(0, model.indexOf(page.cfg_fontFamily))
            onActivated: page.cfg_fontFamily = currentIndex === 0 ? "" : currentText
        }
    }
}
