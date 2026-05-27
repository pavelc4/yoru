import QtQuick
import Yoru.Config
import Quickshell
import qs.components
import qs.services

Item {
    id: root

    required property var modelData
    required property var list

    property bool isImage: (root.modelData?.content ?? "").includes("[[ binary data")
    property string imagePath: "/tmp/yoru-cliphist-" + (root.modelData?.id ?? "0") + ".png"

    implicitHeight: isImage ? 160 : Tokens.sizes.launcher.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    function doClick() { btn.clicked() }

    Component.onCompleted: {
        if (isImage && root.modelData) {
            Quickshell.execDetached(["sh", "-c", `[ -f "${imagePath}" ] || echo '${root.modelData.raw.replace(/'/g, "'\\''")}' | cliphist decode > "${imagePath}"`]);
        }
    }

    Component.onDestruction: {
        if (isImage) {
            Quickshell.execDetached(["rm", "-f", imagePath]);
        }
    }

    StateLayer {
        id: btn
        radius: Tokens.rounding.normal
        onClicked: {
            if (!root.modelData) return;
            Quickshell.execDetached(["sh", "-c", `echo '${root.modelData.raw.replace(/'/g, "'\\''")}' | cliphist decode | wl-copy`]);
            list.visibilities.launcher = false;
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Tokens.padding.larger
        anchors.rightMargin: Tokens.padding.larger
        anchors.margins: Tokens.padding.smaller

        Item {
            id: row
            height: Tokens.sizes.launcher.itemHeight - Tokens.padding.smaller * 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            MaterialIcon {
                id: icon
                text: root.isImage ? "image" : "content_paste"
                font.pointSize: Tokens.font.size.extraLarge
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                anchors.left: icon.right
                anchors.leftMargin: Tokens.spacing.normal
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    id: name
                    text: root.modelData?.content ?? ""
                    font.pointSize: Tokens.font.size.normal
                    elide: Text.ElideRight
                    width: parent.width
                }
            }
        }

        Loader {
            active: root.isImage
            anchors.top: row.bottom
            anchors.topMargin: Tokens.spacing.small
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            sourceComponent: Image {
                source: "file://" + root.imagePath
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
            }
        }
    }
}
