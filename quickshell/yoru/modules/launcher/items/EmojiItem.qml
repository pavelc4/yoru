import QtQuick
import Yoru.Config
import Quickshell
import qs.components
import qs.services

Item {
    id: root

    required property var modelData
    required property var list

    implicitHeight: Tokens.sizes.launcher.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    function doClick() {
        if (!root.modelData) return;
        Quickshell.execDetached(["wl-copy", root.modelData.emoji]);
        list.visibilities.launcher = false;
    }

    StateLayer {
        id: btn
        radius: Tokens.rounding.normal
        onClicked: root.doClick()
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Tokens.padding.larger
        anchors.rightMargin: Tokens.padding.larger
        anchors.margins: Tokens.padding.smaller

        StyledText {
            id: icon
            text: root.modelData?.emoji ?? ""
            font.pointSize: Tokens.font.size.extraLarge
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.left: icon.right
            anchors.leftMargin: Tokens.spacing.normal
            anchors.verticalCenter: icon.verticalCenter

            implicitWidth: parent.width - icon.width
            implicitHeight: name.implicitHeight

            StyledText {
                id: name
                text: root.modelData?.desc ?? ""
                font.pointSize: Tokens.font.size.normal
                elide: Text.ElideRight
                width: parent.width - Tokens.rounding.normal * 2
            }
        }
    }
}
