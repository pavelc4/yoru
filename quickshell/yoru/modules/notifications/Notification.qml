pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Services.Notifications
import Yoru.Config
import qs.components
import qs.components.effects
import qs.services
import qs.utils

Item {
    id: root

    required property NotifData modelData
    readonly property bool hasImage: modelData.image.length > 0
    readonly property bool hasAppIcon: modelData.appIcon.length > 0
    property bool expanded: Config.notifs.openExpanded

    readonly property int nonAnimHeight: background.implicitHeight
    readonly property int radius: Tokens.rounding.normal

    implicitWidth: Tokens.sizes.notifs.width
    implicitHeight: background.implicitHeight

    // Floating App Icon logic
    readonly property real appIconSize: Tokens.sizes.notifs.badge * 1.5

    x: Tokens.sizes.notifs.width
    Component.onCompleted: {
        x = 0;
        modelData.lock(this);
    }
    Component.onDestruction: modelData.unlock(this)

    Behavior on x {
        Anim {
            easing: Tokens.anim.emphasizedDecel
        }
    }

    MouseArea {
        property int startY
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.expanded && body.hoveredLink ? Qt.PointingHandCursor : pressed ? Qt.ClosedHandCursor : undefined
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        preventStealing: true

        onEntered: root.modelData.timer.stop()
        onExited: {
            if (!pressed) root.modelData.timer.start();
        }

        drag.target: parent
        drag.axis: Drag.XAxis

        onPressed: event => {
            root.modelData.timer.stop();
            startY = event.y;
            if (event.button === Qt.MiddleButton)
                root.modelData.close();
        }
        onReleased: event => {
            if (!containsMouse) root.modelData.timer.start();

            if (Math.abs(root.x) < Tokens.sizes.notifs.width * Config.notifs.clearThreshold)
                root.x = 0;
            else
                root.modelData.popup = false;
        }
        onPositionChanged: event => {
            if (pressed) {
                const diffY = event.y - startY;
                if (Math.abs(diffY) > Config.notifs.expandThreshold)
                    root.expanded = diffY > 0;
            }
        }
        onClicked: event => {
            if (!GlobalConfig.notifs.actionOnClick || event.button !== Qt.LeftButton)
                return;

            const actions = root.modelData.actions;
            if (actions.length === 1) actions[0].invoke();
        }

        // --- Floating App Icon (Caelestia-shell style) ---
        Loader {
            id: floatingAppIcon
            active: root.hasAppIcon && !root.hasImage
            anchors.right: background.left
            anchors.top: background.top
            anchors.rightMargin: Tokens.spacing.small
            
            sourceComponent: StyledRect {
                radius: Tokens.rounding.full
                color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3error : Colours.palette.m3secondaryContainer
                implicitWidth: root.appIconSize
                implicitHeight: root.appIconSize

                ColouredIcon {
                    anchors.centerIn: parent
                    width: parent.width * 0.6
                    height: parent.height * 0.6
                    source: Quickshell.iconPath(root.modelData.appIcon)
                    colour: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : Colours.palette.m3onSecondaryContainer
                }
            }
        }

        // --- Floating App Icon (when there is an image, only show if expanded) ---
        Loader {
            id: floatingAppIconWithImage
            active: root.hasAppIcon && root.hasImage
            anchors.right: background.left
            anchors.top: background.top
            anchors.rightMargin: Tokens.spacing.small
            opacity: root.expanded ? 1 : 0
            visible: opacity > 0
            
            Behavior on opacity { Anim {} }
            
            sourceComponent: StyledRect {
                radius: Tokens.rounding.full
                color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3error : Colours.palette.m3secondaryContainer
                implicitWidth: root.appIconSize
                implicitHeight: root.appIconSize

                ColouredIcon {
                    anchors.centerIn: parent
                    width: parent.width * 0.6
                    height: parent.height * 0.6
                    source: Quickshell.iconPath(root.modelData.appIcon)
                    colour: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : Colours.palette.m3onSecondaryContainer
                }
            }
        }

        // --- Background Card ---
        StyledRect {
            id: background
            anchors.right: parent.right
            width: Tokens.sizes.notifs.width
            implicitHeight: contentColumn.implicitHeight + Tokens.padding.normal * 2
            
            radius: Tokens.rounding.normal
            color: {
                if (root.modelData.urgency === NotificationUrgency.Critical) {
                    return root.expanded ? Colours.palette.m3errorContainer : Colours.layer(Colours.palette.m3errorContainer, 2);
                }
                return root.expanded ? Colours.layer(Colours.palette.m3surfaceContainerHigh, 2) : Colours.tPalette.m3surfaceContainer;
            }

            Behavior on implicitHeight {
                Anim {}
            }

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: Tokens.padding.normal
                spacing: Tokens.spacing.small

                // Header / Summary Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    // Title
                    StyledText {
                        id: summary
                        Layout.fillWidth: true
                        text: root.modelData.summary
                        font.pointSize: Tokens.font.size.normal
                        font.weight: Font.Bold
                        color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onErrorContainer : Colours.palette.m3onSurface
                        elide: Text.ElideRight
                    }

                    // Time
                    StyledText {
                        text: root.modelData.timeStr
                        color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onErrorContainer : Colours.palette.m3onSurfaceVariant
                        font.pointSize: Tokens.font.size.small
                    }

                    // Expand Button
                    Item {
                        implicitWidth: expandIcon.implicitWidth + Tokens.padding.small * 2
                        implicitHeight: expandIcon.implicitHeight + Tokens.padding.small * 2
                        StateLayer {
                            radius: Tokens.rounding.full
                            color: Colours.palette.m3onSurface
                            onClicked: root.expanded = !root.expanded
                        }
                        MaterialIcon {
                            id: expandIcon
                            anchors.centerIn: parent
                            text: "expand_more"
                            rotation: root.expanded ? 180 : 0
                            font.pointSize: Tokens.font.size.large
                            color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onErrorContainer : Colours.palette.m3onSurfaceVariant
                            Behavior on rotation { Anim {} }
                        }
                    }
                }

                // Image Preview
                Loader {
                    active: root.hasImage
                    Layout.fillWidth: true
                    visible: root.expanded
                    sourceComponent: StyledClippingRect {
                        implicitHeight: Tokens.sizes.notifs.image * 2.5
                        radius: Tokens.rounding.small
                        Image {
                            anchors.fill: parent
                            source: Qt.resolvedUrl(root.modelData.image)
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                }

                // Body Text
                StyledText {
                    id: body
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    text: {
                        let textBody = root.modelData.body.replace(/\n/g, "<br/>");
                        if (root.expanded) {
                            return `<style>img{max-width:${body.width}px;}</style>${textBody}`;
                        } else {
                            // Strip html tags if not expanded to prevent weird formatting
                            return textBody.replace(/<\/?[^>]+(>|$)/g, "");
                        }
                    }
                    maximumLineCount: root.expanded ? undefined : 2
                    elide: Text.ElideRight
                    color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onErrorContainer : Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.small
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    
                    onLinkActivated: link => {
                        if (!root.expanded) return;
                        Quickshell.execDetached(["app2unit", "-O", "--", link]);
                        root.modelData.popup = false;
                    }
                }

                // Actions
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small
                    visible: root.expanded && root.modelData.actions.length > 0

                    Repeater {
                        model: root.modelData.actions
                        delegate: StyledRect {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: actionText.implicitHeight + Tokens.padding.small * 2
                            radius: Tokens.rounding.full
                            color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3error : Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
                            
                            StateLayer {
                                radius: Tokens.rounding.full
                                color: Colours.palette.m3onSurface
                                onClicked: modelData.invoke()
                            }
                            StyledText {
                                id: actionText
                                anchors.centerIn: parent
                                text: modelData.text
                                color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : Colours.palette.m3onSurface
                                font.pointSize: Tokens.font.size.small
                            }
                        }
                    }
                }
            }
        }
    }

    component Anim: NumberAnimation {
        duration: Tokens.anim.durations.expressiveDefaultSpatial
        easing: Tokens.anim.expressiveDefaultSpatial
    }
}
