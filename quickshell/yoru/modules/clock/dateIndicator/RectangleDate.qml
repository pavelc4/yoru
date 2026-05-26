import QtQuick
import "../../../components"

Rectangle {
    id: rect

    StyledText {
        anchors.centerIn: parent
        color: Colours.palette.m3primary
        text: Qt.locale().toString(Time.date, "dd")
        font {
            family: Tokens.font.family.sans
            pixelSize: 18
            weight: Font.Bold
        }
    }
}
