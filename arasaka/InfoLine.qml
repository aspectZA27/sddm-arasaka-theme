import QtQuick 2.15

// "LABEL: value" line - white label, red value
Row {
    id: line

    property string label: ""
    property string value: ""
    property color accent: "#E60000"
    property real u: 1
    property string fontFamily: "Noto Sans"

    spacing: 14 * u

    Text {
        text: line.label
        color: "#FFFFFF"
        font.family: line.fontFamily
        font.pixelSize: 24 * u
        font.letterSpacing: 4 * u
    }

    Text {
        text: line.value
        color: line.accent
        font.family: line.fontFamily
        font.pixelSize: 24 * u
        font.letterSpacing: 4 * u
    }
}
