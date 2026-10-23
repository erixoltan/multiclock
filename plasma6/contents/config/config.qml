import QtQuick
import org.kde.plasma.configuration

// Registers the settings pages. `source` paths are relative to contents/ui/.
ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-desktop-color"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Analog")
        icon: "clock"
        source: "configAnalog.qml"
    }
    ConfigCategory {
        name: i18n("Digital")
        icon: "preferences-system-time"
        source: "configDigital.qml"
    }
    ConfigCategory {
        name: i18n("Text")
        icon: "format-text-bold"
        source: "configText.qml"
    }
}
