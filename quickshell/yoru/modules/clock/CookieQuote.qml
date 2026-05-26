import QtQuick
import QtQuick.Effects
import "../../components"

Item {
    id: root

    readonly property string quoteText: "Yoru, the beautiful night"

    implicitWidth: quoteBox.implicitWidth
    implicitHeight: quoteBox.implicitHeight

    Rectangle {
        id: quoteBox

        implicitWidth: quoteRow.implicitWidth + 8 * 2
        implicitHeight: quoteRow.implicitHeight + 4 * 2
        radius: Tokens.rounding.small
        color: Colours.palette.m3secondaryContainer

        Row {
            id: quoteRow
            anchors.centerIn: parent
            spacing: 4
            
            MaterialIcon {
                id: quoteIcon
                anchors.top: parent.top
                text: "format_quote"
                color: Colours.palette.m3onSecondaryContainer
            }
            StyledText {
                id: quoteStyledText
                horizontalAlignment: Text.AlignLeft
                text: root.quoteText
                color: Colours.palette.m3onSecondaryContainer
                font {
                    family: Tokens.font.family.sans
                    pointSize: Tokens.font.size.normal
                    weight: Font.Normal
                }
            }
        }
    }
}
