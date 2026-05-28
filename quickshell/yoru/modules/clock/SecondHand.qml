pragma ComponentBehavior: Bound

import QtQuick
import "../../components"

Item {
    id: root
    anchors.fill: parent

    required property int clockSecond
    property real handWidth: 2
    property real handLength: parent.width * 0.38
    property real dotSize: 20
    property string style: "dot"
    property color color: Colours.palette.m3primary
    
    rotation: (360 / 60 * clockSecond) + 90

    Behavior on rotation {
        enabled: true
        RotationAnimation {
            direction: RotationAnimation.Clockwise
            duration: 1000
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 10 + (root.style === "dot" ? root.dotSize : 0)
        }
        implicitWidth: root.style === "dot" ? root.dotSize : root.handLength
        implicitHeight: root.style === "dot" ? root.dotSize : root.handWidth
        radius: Math.min(width, height) / 2
        color: root.color
        Behavior on implicitHeight {
            NumberAnimation { duration: 200 }
        }
        Behavior on implicitWidth {
            NumberAnimation { duration: 200 }
        }
    }

    // Classic style dot in the middle of the hand
    Loader {
        id: classicDotLoader
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        active: root.style === "classic"
        visible: opacity > 0
        opacity: active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        
        sourceComponent: Rectangle {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 40
            }
            implicitWidth: 14
            implicitHeight: implicitWidth
            color: root.color
            radius: 4

            Behavior on implicitWidth {
                NumberAnimation { duration: 200 }
            }
        }
    }
}
