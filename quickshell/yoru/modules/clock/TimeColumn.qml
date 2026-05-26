pragma ComponentBehavior: Bound

import QtQuick
import "../../components"

Column {
    id: root
    property list<string> clockNumbers: [Time.hourStr, Time.minuteStr]
    property bool isEnabled: true
    property color color: Colours.palette.m3onPrimaryContainer

    property bool hourMarksEnabled: true
    spacing: -10

    Repeater {
        model: root.clockNumbers

        delegate: StyledText {
            required property string modelData
            text: modelData.padStart(2, "0")
            property bool isAmPm: !text.match(/\d{2}/i)
            property real numberSizeWithoutGlow: isAmPm ? 20 : 48
            property real numberSizeWithGlow: isAmPm ? 16 : 32
            property real numberSize: root.hourMarksEnabled ? numberSizeWithGlow : numberSizeWithoutGlow

            anchors.horizontalCenter: root.horizontalCenter
            color: root.color
            font {
                family: Tokens.font.family.sans
                weight: Font.Bold
                pixelSize: numberSize
            }

            Behavior on numberSize {
                NumberAnimation { duration: 200 }
            }
        }
    }
}
