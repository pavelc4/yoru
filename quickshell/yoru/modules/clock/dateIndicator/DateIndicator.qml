pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"

Item {
    id: root
    property string style: "bubble"
    property color color: Colours.palette.m3onSecondaryContainer
    property real dateSquareSize: 64

    // Rotating date
    Loader {
        anchors.fill: parent
        active: root.style === "border"
        visible: opacity > 0
        opacity: active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        sourceComponent: RotatingDate {
            color: root.color
        }
    }

    // Rectangle date (only today's number) in right side of the clock
    Loader {
        id: rectLoader
        active: root.style === "rect"
        visible: opacity > 0
        opacity: active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 40 - rectLoader.opacity * 30
        }

        sourceComponent: RectangleDate {
            color: Colours.palette.m3secondaryContainer
            radius: Tokens.rounding.small
            implicitWidth: 45 * rectLoader.opacity
            implicitHeight: 30 * rectLoader.opacity
        }
    }

    // Bubble style: day of month
    Loader {
        id: dayBubbleLoader
        active: root.style === "bubble"
        visible: opacity > 0
        opacity: active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        property real targetSize: root.dateSquareSize * opacity
        anchors {
            left: parent.left
            top: parent.top
        }

        sourceComponent: BubbleDate {
            implicitWidth: dayBubbleLoader.targetSize
            implicitHeight: dayBubbleLoader.targetSize
            isMonth: false
            targetSize: dayBubbleLoader.targetSize
        }
    }

    // Bubble style: month
    Loader {
        id: monthBubbleLoader
        active: root.style === "bubble"
        visible: opacity > 0
        opacity: active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        property real targetSize: root.dateSquareSize * opacity
        anchors {
            right: parent.right
            bottom: parent.bottom
        }

        sourceComponent: BubbleDate {
            implicitWidth: monthBubbleLoader.targetSize
            implicitHeight: monthBubbleLoader.targetSize
            isMonth: true
            targetSize: monthBubbleLoader.targetSize
        }
    }
}
