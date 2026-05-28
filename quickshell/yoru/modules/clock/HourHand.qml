pragma ComponentBehavior: Bound

import QtQuick
import "../../components"

Item {
    id: root

    required property int clockHour
    required property int clockMinute
    property real handLength: parent.width * 0.28
    property real handWidth: 20
    property string style: "fill"
    property color color: Colours.palette.m3primary

    property real fillColorAlpha: root.style === "hollow" ? 0 : 1
    Behavior on fillColorAlpha {
        NumberAnimation { duration: 200 }
    }

    rotation: -90 + (360 / 12) * (root.clockHour + root.clockMinute / 60)
    Behavior on rotation {
        RotationAnimation {
            direction: RotationAnimation.Clockwise
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: (parent.width - root.handWidth) / 2 - 15 * (root.style === "classic")
        width: root.handLength
        height: root.style === "classic" ? 8 : root.handWidth
        radius: root.style === "classic" ? 2 : root.handWidth / 2
        color : Qt.rgba(root.color.r, root.color.g, root.color.b, root.fillColorAlpha)
        border.color: root.color
        border.width: 4

        Behavior on x {
            NumberAnimation { duration: 200 }
        }
    }
}
