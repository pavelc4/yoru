pragma ComponentBehavior: Bound

import QtQuick
import "../../components"

Item {
    id: root
    anchors.fill: parent

    required property int clockMinute
    property string style: "medium"
    property real handLength: parent.width * 0.38
    property real handWidth: style === "bold" ? 20 : style === "medium" ? 12 : 5
    property color color: Colours.palette.m3tertiary

    rotation: -90 + (360 / 60) * root.clockMinute
    Behavior on rotation {
        RotationAnimation {
            direction: RotationAnimation.Clockwise
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: {
            let position = parent.width / 2 - root.handWidth / 2;
            if (root.style === "classic") position -= 15;
            return position;
        }
        width: root.handLength
        height: root.handWidth
        
        radius: root.style === "classic" ? 2 : root.handWidth / 2
        color: root.color

        Behavior on height {
            NumberAnimation { duration: 200 }
        }

        Behavior on x {
            NumberAnimation { duration: 200 }
        }
    }
}
