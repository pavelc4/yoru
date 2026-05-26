pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"

Item {
    id: root

    property string style: "border"
    property color color: Colours.palette.m3primary
    property real angleStep: 12 * Math.PI / 180
    property string dateText: Qt.locale().toString(Time.date, "ddd dd")
    
    readonly property int clockSecond: Time.seconds
    readonly property string dialStyle: "full"
    readonly property bool timeIndicators: true

    property real radius: style === "border" ? 90 : 0
    Behavior on radius {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

    rotation: (360 / 60 * clockSecond) + 180 - (angleStep / Math.PI * 180 * dateText.length) / 2

    Repeater {
        model: root.dateText.length 

        delegate: Text {
            required property int index
            property real angle: index * root.angleStep - Math.PI / 2
            x: root.width / 2 + root.radius * Math.cos(angle) - width / 2
            y: root.height / 2 + root.radius * Math.sin(angle) - height / 2
            rotation: angle * 180 / Math.PI + 90

            color: root.color
            font {
                family: Tokens.font.family.sans
                pixelSize: 14
                weight: Font.DemiBold
            }

            text: root.dateText.charAt(index)
        }
    }
}
