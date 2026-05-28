pragma ComponentBehavior: Bound

import QtQuick
import Yoru.Config
import qs.components
import qs.services
import "../../../components"

Item {
    id: root
    property bool isMonth: false
    property real targetSize: 0
    property alias text: bubbleText.text

    text: Qt.locale().toString(Time.date, root.isMonth ? "MM" : "d")

    Rectangle {
        id: bubble
        z: 5
        anchors.centerIn: parent
        color: root.isMonth ? Colours.palette.m3secondaryContainer : Colours.palette.m3tertiaryContainer
        width: root.isMonth ? targetSize * 1.3 : targetSize
        height: targetSize
        radius: root.isMonth ? height / 2 : width / 2
    }

    StyledText {
        id: bubbleText
        z: 6
        anchors.centerIn: parent
        color: root.isMonth ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onTertiaryContainer
        font {
            family: Tokens.font.family.sans
            pixelSize: 22
            weight: Font.Black
        }
    }
}