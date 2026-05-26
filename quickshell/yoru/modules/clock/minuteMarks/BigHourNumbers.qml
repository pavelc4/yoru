pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"

Item {
    id: root
    property real numberSize: 80
    property real margins: 10
    property color color: Colours.palette.m3onPrimaryContainer

    property int hours: 12
    property int numbers: 4
    property int fontSize: 80

    Repeater {
        model: root.numbers

        Item {
            id: numberItem
            required property int index
            rotation: 360 / root.numbers * (index + 1)
            anchors.fill: parent
            
            Item {
                implicitWidth: root.numberSize
                implicitHeight: implicitWidth
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    topMargin: root.margins
                }
                StyledText {
                    color: root.color
                    anchors.centerIn: parent
                    text: root.hours / root.numbers * (numberItem.index + 1)
                    rotation: -numberItem.rotation

                    font {
                        family: Tokens.font.family.sans
                        pixelSize: root.fontSize
                        weight: Font.Black
                    }
                }
            }
        }
    }
}
