import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami
import "FuzzyTime.js" as FuzzyTime

Kirigami.FormLayout {
    id: page

    property alias cfg_phraseSet: setCombo.currentIndex
    property alias cfg_customStep: stepSpin.value
    property alias cfg_customPhrases: phrasesArea.text

    readonly property bool custom: setCombo.currentIndex === 3
    readonly property string activePhrases: custom
        ? phrasesArea.text : FuzzyTime.preset(setCombo.currentIndex).rules
    readonly property int activeStep: custom
        ? stepSpin.value : FuzzyTime.preset(setCombo.currentIndex).step
    readonly property var badLines: FuzzyTime.parse(phrasesArea.text).errors

    // Copy a built-in set into the editor as a starting point.
    function loadPreset(index) {
        phrasesArea.text = FuzzyTime.preset(index).rules;
        stepSpin.value = FuzzyTime.preset(index).step;
    }

    QQC2.ComboBox {
        id: setCombo
        Kirigami.FormData.label: i18n("Phrases:")
        model: [
            i18n("Nearest five minutes"),
            i18n("Nearest quarter hour"),
            i18n("Time of day"),
            i18n("Custom"),
        ]
        onActivated: {
            if (page.custom && phrasesArea.text.trim() === "")
                page.loadPreset(0);
        }
    }

    QQC2.Label {
        Kirigami.FormData.label: i18n("Right now:")
        text: FuzzyTime.phrase(new Date(), page.activePhrases, page.activeStep)
        font.bold: true
    }

    Item { Kirigami.FormData.isSection: true }

    RowLayout {
        Kirigami.FormData.label: i18n("Start from:")
        enabled: page.custom
        QQC2.Button {
            text: i18n("Five minutes")
            onClicked: page.loadPreset(0)
        }
        QQC2.Button {
            text: i18n("Quarter hour")
            onClicked: page.loadPreset(1)
        }
        QQC2.Button {
            text: i18n("Time of day")
            onClicked: page.loadPreset(2)
        }
    }

    QQC2.SpinBox {
        id: stepSpin
        Kirigami.FormData.label: i18n("Round to (minutes):")
        enabled: page.custom
        from: 1
        to: 60
    }

    // Grows with its content; the settings dialog scrolls the page.
    QQC2.TextArea {
        id: phrasesArea
        Kirigami.FormData.label: i18n("Custom phrases:")
        Kirigami.FormData.labelAlignment: Qt.AlignTop
        enabled: page.custom
        Layout.fillWidth: true
        Layout.preferredWidth: Kirigami.Units.gridUnit * 22
        Layout.preferredHeight: Math.max(Kirigami.Units.gridUnit * 10, implicitHeight)
        font.family: "monospace"
        wrapMode: TextEdit.NoWrap
    }

    QQC2.Label {
        visible: page.custom && page.badLines.length > 0
        text: i18np("Line %2 is not understood and will be ignored.",
                    "Lines %2 are not understood and will be ignored.",
                    page.badLines.length, page.badLines.join(", "))
        color: Kirigami.Theme.negativeTextColor
        wrapMode: Text.WordWrap
        Layout.maximumWidth: Kirigami.Units.gridUnit * 22
    }

    QQC2.Label {
        text: i18n("One phrase per line, as \"when = phrase\". The time is rounded first, then the first line that matches is used.\n\n12:00 = Noon — exactly this time (24-hour clock)\n:15 = Quarter past {hour} — this minute of any hour\n22:00-6:00 = Night — a span of time\n\n{hour} and {next} are this hour and the next as words, {Hour} and {Next} the same capitalized; {h12}, {h24} and {mm} are digits. A line \"hours = twelve, one, two, …\" with 12 or 24 names replaces the hour words. Lines starting with # are notes.")
        wrapMode: Text.WordWrap
        Layout.maximumWidth: Kirigami.Units.gridUnit * 22
        font: Kirigami.Theme.smallFont
        opacity: 0.8
    }
}
