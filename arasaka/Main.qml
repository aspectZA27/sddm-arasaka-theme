import QtQuick 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.bgColor || "#100E0F"

    // Everything scales from a 1440p design
    readonly property real u: height / 1440
    readonly property color accent: config.accent || "#E60000"
    readonly property string fontFamily: config.fontFamily || "Noto Sans"

    property string authStatus: "STANDBY"
    property string timeText: Qt.formatTime(new Date(), "HH:mm")
    property string dateText: Qt.formatDate(new Date(), "yyyy.MM.dd")

    // username -> real name, filled in from userModel
    property var users: ({})
    property int usersRev: 0

    // session names, filled in from sessionModel
    property var sessionNames: ({})
    property int sessionRev: 0
    property int sessionIdx: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    readonly property string operatorName: {
        var rev = usersRev
        var id = uidField.text
        if (id.length === 0)
            return "AWAITING_UID"
        if (users.hasOwnProperty(id)) {
            var real = users[id]
            return (real && real.length > 0 ? real : id).toUpperCase()
        }
        return "UNREGISTERED"
    }

    readonly property string sessionName: {
        var rev = sessionRev
        var n = sessionNames[sessionIdx]
        return n ? n.toUpperCase() : "DEFAULT"
    }

    function doLogin() {
        if (uidField.text.length === 0) {
            uidField.focusField()
            return
        }
        authStatus = "VERIFYING"
        sddm.login(uidField.text, passField.text, sessionIdx)
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {
            root.authStatus = "ACCESS_GRANTED"
        }
        function onLoginFailed() {
            root.authStatus = "ACCESS_DENIED"
            passField.text = ""
            passField.focusField()
            statusReset.restart()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            root.timeText = Qt.formatTime(d, "HH:mm")
            root.dateText = Qt.formatDate(d, "yyyy.MM.dd")
        }
    }

    Timer {
        id: statusReset
        interval: 3500
        onTriggered: root.authStatus = "STANDBY"
    }

    // Collect real names and session names (invisible helpers)
    Repeater {
        model: userModel
        delegate: Item {
            Component.onCompleted: {
                var map = root.users
                map[model.name] = model.realName
                root.users = map
                root.usersRev++
            }
        }
    }

    Repeater {
        model: sessionModel
        delegate: Item {
            Component.onCompleted: {
                var map = root.sessionNames
                map[index] = model.name
                root.sessionNames = map
                root.sessionRev++
            }
        }
    }

    // ---- Left accent bar and vertical version string ----
    Rectangle {
        x: 0
        y: 0
        width: 22 * root.u
        height: root.height
        color: root.accent
    }

    Text {
        text: config.versionText || "ARASAKA OS V024.11.980"
        color: root.accent
        font.family: root.fontFamily
        font.pixelSize: 22 * root.u
        font.letterSpacing: 5 * root.u
        rotation: -90
        transformOrigin: Item.TopLeft
        x: 32 * root.u
        y: root.height - 24 * root.u
    }

    // ---- Top-right controls ----
    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 48 * root.u
        anchors.rightMargin: 64 * root.u
        spacing: 48 * root.u

        MenuButton {
            u: root.u
            accent: root.accent
            fontFamily: root.fontFamily
            text: "SESSION: " + root.sessionName
            onClicked: {
                if (sessionModel.count > 0)
                    root.sessionIdx = (root.sessionIdx + 1) % sessionModel.count
            }
        }
        MenuButton {
            u: root.u
            accent: root.accent
            fontFamily: root.fontFamily
            text: "REBOOT"
            visible: sddm.canReboot
            onClicked: sddm.reboot()
        }
        MenuButton {
            u: root.u
            accent: root.accent
            fontFamily: root.fontFamily
            text: "SHUTDOWN"
            visible: sddm.canPowerOff
            onClicked: sddm.powerOff()
        }
    }

    // ---- Centre block: logo + login form ----
    Item {
        id: center
        width: 1148 * root.u
        height: 600 * root.u
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -10 * root.u

        Image {
            id: logo
            x: 0
            y: 0
            width: 442 * root.u
            height: 598 * root.u
            source: config.logo || "assets/logo.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            visible: status === Image.Ready
        }

        // Plain-text stand-in shown until you add assets/logo.png
        Column {
            visible: logo.status !== Image.Ready
            x: 0
            y: 160 * root.u
            spacing: 6 * root.u

            Text {
                text: "ARASAKA"
                color: "#FFFFFF"
                font.family: root.fontFamily
                font.pixelSize: 84 * root.u
                font.bold: true
                font.letterSpacing: 6 * root.u
            }
            Text {
                text: "CORPORATION"
                color: "#555555"
                font.family: root.fontFamily
                font.pixelSize: 30 * root.u
                font.letterSpacing: 18 * root.u
            }
        }

        Column {
            id: form
            x: 508 * root.u
            y: 0
            spacing: 22 * root.u

            Text {
                text: config.formTitle || "SECURITY LOGIN"
                color: root.accent
                font.family: root.fontFamily
                font.pixelSize: 24 * root.u
                font.letterSpacing: 5 * root.u
            }

            Field {
                id: uidField
                u: root.u
                accent: root.accent
                fontFamily: root.fontFamily
                placeholder: "UID_"
                text: userModel.lastUser
                onAccepted: passField.focusField()
                onTabbed: passField.focusField()
            }

            Field {
                id: passField
                u: root.u
                accent: root.accent
                fontFamily: root.fontFamily
                placeholder: "KEY_"
                echoMode: TextInput.Password
                implicitHeight: 104 * root.u
                onAccepted: root.doLogin()
                onTabbed: uidField.focusField()
            }

            Item {
                width: 640 * root.u
                height: 40 * root.u

                Text {
                    id: slashes
                    text: "//////////"
                    color: "#FFFFFF"
                    font.family: root.fontFamily
                    font.pixelSize: 32 * root.u
                    font.letterSpacing: 6 * root.u
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    anchors.left: slashes.right
                    anchors.leftMargin: 20 * root.u
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: Math.max(2, Math.round(2 * root.u))
                    color: "#FFFFFF"
                }
            }

            Column {
                spacing: 8 * root.u

                InfoLine {
                    u: root.u
                    accent: root.accent
                    fontFamily: root.fontFamily
                    label: "OPERATOR:"
                    value: root.operatorName
                }
                InfoLine {
                    u: root.u
                    accent: root.accent
                    fontFamily: root.fontFamily
                    label: "LOCAL_TIME:"
                    value: root.timeText + "  //  " + root.dateText
                }
                InfoLine {
                    u: root.u
                    accent: root.accent
                    fontFamily: root.fontFamily
                    label: "AUTH_STATUS:"
                    value: root.authStatus
                }
            }
        }
    }

    // ---- Bottom-right footer ----
    Row {
        id: footerRow
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 44 * root.u
        anchors.bottomMargin: 36 * root.u
        spacing: 14 * root.u

        Rectangle {
            width: 130 * root.u
            height: Math.max(2, Math.round(2 * root.u))
            color: "#FFFFFF"
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: config.footerJp || "アラサカ社"
            color: "#FFFFFF"
            font.family: root.fontFamily
            font.pixelSize: 30 * root.u
        }
    }

    Image {
        id: smallLogo
        anchors.right: parent.right
        anchors.bottom: footerRow.top
        anchors.rightMargin: 44 * root.u
        anchors.bottomMargin: 10 * root.u
        width: 290 * root.u
        height: 70 * root.u
        source: config.logoSmall || "assets/logo-small.png"
        fillMode: Image.PreserveAspectFit
        horizontalAlignment: Image.AlignRight
        smooth: true
        mipmap: true
        visible: status === Image.Ready
    }

    Component.onCompleted: {
        if (uidField.text.length > 0)
            passField.focusField()
        else
            uidField.focusField()
    }
}
