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

    function doClick() { btn.clicked() }

    StateLayer {
        id: btn
        radius: Tokens.rounding.normal
        onClicked: {
            if (!root.modelData) return;
            Quickshell.execDetached(["sh", "-c", `echo "${root.modelData.raw}" | cliphist decode | wl-copy`]);
            list.visibilities.launcher = false;
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Tokens.padding.larger
        anchors.rightMargin: Tokens.padding.larger
        anchors.margins: Tokens.padding.smaller

        MaterialIcon {
            id: icon
            text: (root.modelData?.content ?? "").includes("[[ binary data") ? "image" : "content_paste"
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
                text: root.modelData?.content ?? ""
                font.pointSize: Tokens.font.size.normal
                elide: Text.ElideRight
                width: parent.width - Tokens.rounding.normal * 2
            }
        }
    }
}
