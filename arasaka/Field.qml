import QtQuick 2.15

// Boxed input field with a red outline and a placeholder like "UID_"
Rectangle {
    id: box

    property alias text: input.text
    property alias echoMode: input.echoMode
    property string placeholder: ""
    property color accent: "#E60000"
    property real u: 1
    property string fontFamily: "Noto Sans"

    signal accepted()
    signal tabbed()

    function focusField() { input.forceActiveFocus() }

    color: "transparent"
    border.width: Math.max(2, Math.round(3 * u))
    border.color: input.activeFocus ? accent : Qt.darker(accent, 1.9)
    implicitWidth: 640 * u
    implicitHeight: 132 * u

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 50 * u
        anchors.rightMargin: 50 * u
        verticalAlignment: TextInput.AlignVCenter
        color: box.accent
        selectionColor: box.accent
        selectedTextColor: "#100E0F"
        font.family: box.fontFamily
        font.pixelSize: 36 * u
        font.letterSpacing: 6 * u
        passwordCharacter: "*"
        clip: true
        autoScroll: true
        onAccepted: box.accepted()
        Keys.onTabPressed: box.tabbed()
    }

    Text {
        visible: input.text.length === 0
        x: 50 * u
        anchors.verticalCenter: parent.verticalCenter
        text: box.placeholder
        color: box.accent
        font.family: box.fontFamily
        font.pixelSize: 36 * u
        font.letterSpacing: 6 * u
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: input.forceActiveFocus()
    }
}
