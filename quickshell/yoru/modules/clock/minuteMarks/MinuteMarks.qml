pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"

Item {
    id: root

    property color color: Colours.palette.m3onPrimaryContainer
    property string style: "full"
    property string dateStyle: "bubble"

    // 12 Dots
    Loader {
        id: dotsLoader
        anchors {
            fill: parent
            margins: 10
        }
        active: root.style === "dots"
        visible: opacity > 0
        opacity: active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        sourceComponent: Dots {
            color: root.color
            margins: 46 - dotsLoader.opacity * 34
        }
    }

    // 3-6-9-12 hour numbers
    Loader {
        id: bigHourNumbersLoader
        anchors.fill: parent
        active: root.style === "numbers"
        visible: opacity > 0
        opacity: active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        sourceComponent: BigHourNumbers {
            numberSize: 80
            color: root.color
            margins: 20 - 10 * bigHourNumbersLoader.opacity
        }
    }

    // Lines
    Loader {
        id: linesLoader
        anchors {
            fill: parent
            margins: 10
        }
        active: root.style === "full"
        visible: opacity > 0
        opacity: active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        sourceComponent: Lines {
            color: root.color
            margins: 46 - linesLoader.opacity * 34
        }
    }
}
