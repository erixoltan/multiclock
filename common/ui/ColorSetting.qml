import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kquickcontrols 2.0 as KQControls

// "Theme color or custom color" picker used on the settings pages.
// `value` is the stored config string: "" means follow the theme.
RowLayout {
    id: control

    property string value: ""
    property color themeColor: "white"
    property bool showAlpha: false   // let the picker choose transparency

    QQC2.CheckBox {
        id: custom
        text: i18n("Custom")
        checked: control.value !== ""
        onToggled: control.value = checked ? button.color.toString() : ""
    }

    KQControls.ColorButton {
        id: button
        enabled: custom.checked
        showAlphaChannel: control.showAlpha
        color: control.value !== "" ? control.value : control.themeColor
        onColorChanged: {
            if (custom.checked)
                control.value = color.toString();
        }
    }
}
