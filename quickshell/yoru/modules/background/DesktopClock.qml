pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Yoru.Config
import qs.components
import qs.services
import "../clock"

Item {
    id: root

    required property Item wallpaper
    required property real absX
    required property real absY

    property bool showAnalog: true
    property real clockScale: Config.background.desktopClock.scale

    property Item dragTarget: null
    property int clockSides: 7
    property string clockDialNumberStyle: "none"
    property bool clockHourMarks: false
    property bool clockTimeIndicators: false

    property int clockColorIndex: 4 // default solid charcoal dark
    readonly property list<color> clockColorPresets: [
        Colours.palette.m3surfaceContainerHighest,
        Colours.palette.m3primaryContainer,
        Colours.palette.m3secondaryContainer,
        Colours.palette.m3surface,
        "#2C2C2C" // Charcoal dark / anime
    ]
    readonly property bool bgEnabled: Config.background.desktopClock.background.enabled
    readonly property bool blurEnabled: bgEnabled && Config.background.desktopClock.background.blur && !GameMode.enabled
    readonly property bool invertColors: Config.background.desktopClock.invertColors
    readonly property bool useLightSet: Colours.light ? !invertColors : invertColors
    readonly property color safePrimary: useLightSet ? Colours.palette.m3primaryContainer : Colours.palette.m3primary
    readonly property color safeSecondary: useLightSet ? Colours.palette.m3secondaryContainer : Colours.palette.m3secondary
    readonly property color safeTertiary: useLightSet ? Colours.palette.m3tertiaryContainer : Colours.palette.m3tertiary

    implicitWidth: showAnalog ? (250 * root.clockScale + Tokens.padding.large * 4 * root.clockScale) : (layout.implicitWidth + (Tokens.padding.large * 4 * root.clockScale))
    implicitHeight: showAnalog ? (250 * root.clockScale + Tokens.padding.large * 2 * root.clockScale) : (layout.implicitHeight + (Tokens.padding.large * 2 * root.clockScale))

    Item {
        id: clockContainer

        anchors.fill: parent

        layer.enabled: Config.background.desktopClock.shadow.enabled
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Colours.palette.m3shadow
            shadowOpacity: Config.background.desktopClock.shadow.opacity
            shadowBlur: Config.background.desktopClock.shadow.blur
        }

        Loader {
            asynchronous: true
            anchors.fill: parent
            active: root.blurEnabled

            sourceComponent: MultiEffect {
                source: ShaderEffectSource {
                    sourceItem: root.wallpaper
                    sourceRect: Qt.rect(root.absX, root.absY, root.width, root.height)
                }
                maskSource: backgroundPlate
                maskEnabled: true
                blurEnabled: true
                blur: 1
                blurMax: 64
                autoPaddingEnabled: false
            }
        }

        StyledRect {
            id: backgroundPlate

            visible: root.bgEnabled
            anchors.fill: parent
            radius: Tokens.rounding.large * root.clockScale
            opacity: Config.background.desktopClock.background.opacity
            color: Colours.palette.m3surface

            layer.enabled: root.blurEnabled
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
                    // Right click cycles analog clock sides / shapes!
                    const sideOptions = [0, 4, 6, 7, 9, 12];
                    let currIndex = sideOptions.indexOf(root.clockSides);
                    let nextIndex = (currIndex + 1) % sideOptions.length;
                    root.clockSides = sideOptions[nextIndex];
                } else {
                    // Left click toggles analog/digital!
                    root.showAnalog = !root.showAnalog;
                }
            }

            onDoubleClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    // Double click cycles dial number style / complexity!
                    if (root.clockDialNumberStyle === "none") {
                        root.clockDialNumberStyle = "dots";
                        root.clockHourMarks = true;
                        root.clockTimeIndicators = false;
                    } else if (root.clockDialNumberStyle === "dots") {
                        root.clockDialNumberStyle = "full";
                        root.clockHourMarks = false;
                        root.clockTimeIndicators = true;
                    } else {
                        root.clockDialNumberStyle = "none";
                        root.clockHourMarks = false;
                        root.clockTimeIndicators = false;
                    }
                } else if (mouse.button === Qt.RightButton) {
                    // Double right-click cycles clock background color presets!
                    root.clockColorIndex = (root.clockColorIndex + 1) % root.clockColorPresets.length;
                }
            }
        }

        Loader {
            id: analogClockLoader
            active: root.showAnalog
            visible: active
            anchors.centerIn: parent
            sourceComponent: CookieClock {
                implicitSize: 230 * root.clockScale
                sides: root.clockSides
                dialNumberStyle: root.clockDialNumberStyle
                hourMarks: root.clockHourMarks
                timeIndicators: root.clockTimeIndicators
                colBackground: root.clockColorPresets[root.clockColorIndex]
                colHourHand: root.safePrimary
                colMinuteHand: root.safeSecondary
                colSecondHand: root.safeTertiary
            }
        }

        RowLayout {
            id: layout
            visible: !root.showAnalog

            anchors.centerIn: parent
            spacing: Tokens.spacing.larger * root.clockScale

            RowLayout {
                spacing: Tokens.spacing.small

                StyledText {
                    text: Time.hourStr
                    font.pointSize: Tokens.font.size.extraLarge * 3 * root.clockScale
                    font.weight: Font.Bold
                    color: root.safePrimary
                }

                StyledText {
                    text: ":"
                    font.pointSize: Tokens.font.size.extraLarge * 3 * root.clockScale
                    color: root.safeTertiary
                    opacity: 0.8
                    Layout.topMargin: -Tokens.padding.large * 1.5 * root.clockScale
                }

                StyledText {
                    text: Time.minuteStr
                    font.pointSize: Tokens.font.size.extraLarge * 3 * root.clockScale
                    font.weight: Font.Bold
                    color: root.safeSecondary
                }

                Loader {
                    asynchronous: true
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: Tokens.padding.large * 1.4 * root.clockScale

                    active: GlobalConfig.services.useTwelveHourClock
                    visible: active

                    sourceComponent: StyledText {
                        text: Time.amPmStr
                        font.pointSize: Tokens.font.size.large * root.clockScale
                        color: root.safeSecondary
                    }
                }
            }

            StyledRect {
                Layout.fillHeight: true
                Layout.preferredWidth: 4 * root.clockScale
                Layout.topMargin: Tokens.spacing.larger * root.clockScale
                Layout.bottomMargin: Tokens.spacing.larger * root.clockScale
                radius: Tokens.rounding.full
                color: root.safePrimary
                opacity: 0.8
            }

            ColumnLayout {
                spacing: 0

                StyledText {
                    text: Time.format("MMMM").toUpperCase()
                    font.pointSize: Tokens.font.size.large * root.clockScale
                    font.letterSpacing: 4
                    font.weight: Font.Bold
                    color: root.safeSecondary
                }

                StyledText {
                    text: Time.format("dd")
                    font.pointSize: Tokens.font.size.extraLarge * root.clockScale
                    font.letterSpacing: 2
                    font.weight: Font.Medium
                    color: root.safePrimary
                }

                StyledText {
                    text: Time.format("dddd")
                    font.pointSize: Tokens.font.size.larger * root.clockScale
                    font.letterSpacing: 2
                    color: root.safeSecondary
                }
            }
        }
    }

    Behavior on clockScale {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.StandardSmall
        }
    }
}

