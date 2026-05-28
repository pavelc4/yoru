pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Yoru.Config
import qs.components
import qs.services
import "../clock"

Item {
    id: root

    property Item dragTarget: null
    property string shapeMode: "blob" // "blob" (default slanted blob), "pill", "polygon"
    property int sides: 7
    property real sizeMultiplier: 1.0

    property int colorIndex: 4 // default solid charcoal dark
    readonly property list<color> colorPresets: [
        Colours.palette.m3primaryContainer,
        Colours.palette.m3secondaryContainer,
        Colours.palette.m3surfaceContainerHighest,
        Colours.palette.m3surface,
        "#2C2C2C" // Charcoal dark / anime
    ]
    readonly property list<color> textPresets: [
        Colours.palette.m3onPrimaryContainer,
        Colours.palette.m3onSecondaryContainer,
        Colours.palette.m3onSurface,
        Colours.palette.m3onSurface,
        "#FFFFFF" // White for charcoal
    ]
    readonly property list<color> iconPresets: [
        Colours.palette.m3primary,
        Colours.palette.m3secondary,
        Colours.palette.m3primary,
        Colours.palette.m3secondary,
        Colours.palette.m3primary
    ]

    property real clockScale: Config.background.desktopClock.scale
    implicitWidth: (shapeMode === "pill" ? 240 : (shapeMode === "blob" ? 160 : 180)) * root.clockScale * root.sizeMultiplier
    implicitHeight: (shapeMode === "pill" ? 130 : (shapeMode === "blob" ? 225 : 180)) * root.clockScale * root.sizeMultiplier

    layer.enabled: Config.background.desktopClock.shadow.enabled
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Colours.palette.m3shadow
        shadowOpacity: Config.background.desktopClock.shadow.opacity
        shadowBlur: Config.background.desktopClock.shadow.blur
    }

    // Background plate container that rotates, keeping text/icon perfectly upright
    Item {
        id: bgContainer
        anchors.fill: parent
        rotation: root.shapeMode === "blob" ? -30 : 0

        Behavior on rotation {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        // Asymmetric organic vertical pill/oval shape (lonjong) matching mockup
        Rectangle {
            id: blobBgShape
            anchors.fill: parent
            
            topLeftRadius: width * 0.5
            topRightRadius: width * 0.46
            bottomLeftRadius: width * 0.46
            bottomRightRadius: width * 0.5
            
            color: root.colorPresets[root.colorIndex]
            visible: root.shapeMode === "blob"
        }

        Rectangle {
            id: pillBgShape
            anchors.fill: parent
            radius: height / 2
            color: root.colorPresets[root.colorIndex]
            visible: root.shapeMode === "pill"
        }

        MaterialCookie {
            id: bgShape
            anchors.fill: parent
            sides: root.sides
            implicitSize: root.implicitWidth
            color: root.colorPresets[root.colorIndex]
            visible: root.shapeMode === "polygon"
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: root.dragTarget
        drag.axis: Drag.XAndYAxis
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: {
            if (root.dragTarget && root.dragTarget.anchors) {
                var curX = root.dragTarget.x;
                var curY = root.dragTarget.y;
                root.dragTarget.anchors.top = undefined;
                root.dragTarget.anchors.bottom = undefined;
                root.dragTarget.anchors.left = undefined;
                root.dragTarget.anchors.right = undefined;
                root.dragTarget.anchors.horizontalCenter = undefined;
                root.dragTarget.anchors.verticalCenter = undefined;
                root.dragTarget.x = curX;
                root.dragTarget.y = curY;
            }
        }

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                // Cycle shape: Blob -> Pill -> Heptagon -> Square -> Circle -> Blob
                if (root.shapeMode === "blob") {
                    root.shapeMode = "pill";
                } else if (root.shapeMode === "pill") {
                    root.shapeMode = "polygon";
                    root.sides = 7;
                } else if (root.shapeMode === "polygon" && root.sides === 7) {
                    root.sides = 4;
                } else if (root.shapeMode === "polygon" && root.sides === 4) {
                    root.sides = 0;
                } else {
                    root.shapeMode = "blob";
                }
            } else {
                // Left click cycles color theme presets!
                root.colorIndex = (root.colorIndex + 1) % root.colorPresets.length;
            }
        }

        onDoubleClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                // Double left-click cycles sizes!
                const sizeOptions = [0.8, 1.0, 1.2, 1.5];
                let currIndex = sizeOptions.indexOf(root.sizeMultiplier);
                let nextIndex = (currIndex + 1) % sizeOptions.length;
                root.sizeMultiplier = sizeOptions[nextIndex];
            } else if (mouse.button === Qt.RightButton) {
                // Double right-click toggles temperature unit globally!
                GlobalConfig.services.useFahrenheit = !GlobalConfig.services.useFahrenheit;
            }
        }
    }

    StyledText {
        font.pointSize: (root.shapeMode === "blob" ? 48 : (root.shapeMode === "pill" ? 42 : (root.sides === 4 ? 38 : 44))) * root.clockScale * root.sizeMultiplier
        font.weight: Font.Medium
        color: root.textPresets[root.colorIndex]
        text: Weather.cc ? (GlobalConfig.services.useFahrenheit ? `${Weather.cc.tempF}°` : `${Weather.cc.tempC}°`) : "--°"
        
        anchors {
            horizontalCenter: root.shapeMode === "blob" ? parent.horizontalCenter : undefined
            right: root.shapeMode === "blob" ? undefined : parent.right
            
            top: root.shapeMode === "pill" ? undefined : parent.top
            verticalCenter: root.shapeMode === "pill" ? parent.verticalCenter : undefined
            
            rightMargin: (root.shapeMode === "blob" ? 0 : (root.shapeMode === "pill" ? 36 : (root.sides === 4 ? 20 : 26))) * root.clockScale * root.sizeMultiplier
            topMargin: root.shapeMode === "pill" ? undefined : (root.shapeMode === "blob" ? 38 : (root.sides === 4 ? 22 : 30)) * root.clockScale * root.sizeMultiplier
        }
    }

    MaterialIcon {
        font.pointSize: (root.shapeMode === "blob" ? 48 : (root.shapeMode === "pill" ? 42 : (root.sides === 4 ? 38 : 44))) * root.clockScale * root.sizeMultiplier
        color: root.iconPresets[root.colorIndex]
        text: Weather.icon || "cloud"
        
        anchors {
            horizontalCenter: root.shapeMode === "blob" ? parent.horizontalCenter : undefined
            left: root.shapeMode === "blob" ? undefined : parent.left
            
            bottom: root.shapeMode === "pill" ? undefined : parent.bottom
            verticalCenter: root.shapeMode === "pill" ? parent.verticalCenter : undefined
            
            leftMargin: (root.shapeMode === "blob" ? 0 : (root.shapeMode === "pill" ? 36 : (root.sides === 4 ? 22 : 30))) * root.clockScale * root.sizeMultiplier
            bottomMargin: root.shapeMode === "pill" ? undefined : (root.shapeMode === "blob" ? 38 : (root.sides === 4 ? 22 : 30)) * root.clockScale * root.sizeMultiplier
        }
    }
}
