import QtQuick 2.15

// Small letter-spaced text button used for session / reboot / shutdown
Text {
    id: btn

    property color accent: "#E60000"
    property real u: 1
    property string fontFamily: "Noto Sans"

    signal clicked()

    color: area.containsMouse ? accent : "#8C8C8C"
    font.family: fontFamily
    font.pixelSize: 20 * u
    font.letterSpacing: 4 * u

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -10 * btn.u
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
