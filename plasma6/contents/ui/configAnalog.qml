import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_showHourHand: hourCheck.checked
    property alias cfg_showMinuteHand: minuteCheck.checked
    property alias cfg_showSecondHand: secondCheck.checked
    property alias cfg_showDial: fillCheck.checked
    property alias cfg_dialColor: dialSetting.value
    property alias cfg_dial24h: dialCheck.checked
    property alias cfg_tickCount: tickSpin.value
    property alias cfg_showNumerals: numeralsCheck.checked

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: hourCheck
            Kirigami.FormData.label: i18n("Hands:")
            text: i18n("Hour")
        }

        QQC2.CheckBox {
            id: minuteCheck
            text: i18n("Minute")
        }

        QQC2.CheckBox {
            id: secondCheck
            text: i18n("Second")
        }

        QQC2.Label {
            text: i18n("A hand shown on its own is drawn long, in the accent color.")
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
            font: Kirigami.Theme.smallFont
            opacity: 0.8
        }

        QQC2.CheckBox {
            id: fillCheck
            Kirigami.FormData.label: i18n("Dial:")
            text: i18n("Filled round dial")
        }

        ColorSetting {
            id: dialSetting
            Kirigami.FormData.label: i18n("Dial color:")
            enabled: fillCheck.checked
            themeColor: Kirigami.Theme.backgroundColor
            showAlpha: true
        }

        QQC2.CheckBox {
            id: dialCheck
            text: i18n("24-hour dial (midnight at top)")
        }

        QQC2.SpinBox {
            id: tickSpin
            Kirigami.FormData.label: i18n("Tick marks:")
            from: 0
            to: 288
        }

        QQC2.Label {
            text: i18n("Hours get heavier ticks when the count divides evenly by 12 (or 24). For an hour hand alone on a 12-hour dial, 48 gives 15-minute marks and 144 gives 5-minute marks.")
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
            font: Kirigami.Theme.smallFont
            opacity: 0.8
        }

        QQC2.CheckBox {
            id: numeralsCheck
            text: i18n("Show numerals")
        }
    }
}
