pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Io
import "dateIndicator"
import "minuteMarks"
import "../../components"

Item {
    id: root

    property string clockStyle: "cookie"
    property real implicitSize: 230

    // Style properties
    property int sides: 12
    property string dialNumberStyle: "full"
    property string hourHandStyle: "fill"
    property string minuteHandStyle: "medium"
    property string secondHandStyle: "dot"
    property string dateStyle: "bubble"
    property bool constantlyRotate: false
    property bool useSineCookie: false
    property bool hourMarks: true
    property bool timeIndicators: true

    property color colShadow: Colours.palette.m3shadow
    property color colBackground: Colours.palette.m3primaryContainer
    property color colOnBackground: Colours.palette.m3onPrimaryContainer
    property color colBackgroundInfo: Colours.palette.m3tertiaryContainer
    property color colHourHand: Colours.palette.m3primary
    property color colMinuteHand: Colours.palette.m3tertiary
    property color colSecondHand: Colours.palette.m3primary

    readonly property list<string> clockNumbers: Time.timeStr.split(/[: ]/)
    readonly property int clockHour: parseInt(clockNumbers[0]) % 12
    readonly property int clockMinute: Time.minutes
    readonly property int clockSecond: Time.seconds

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    Loader {
        id: sineCookieLoader
        z: 0
        visible: root.useSineCookie
        active: root.useSineCookie
        sourceComponent: SineCookie {
            implicitSize: root.implicitSize
            sides: root.sides
            color: root.colBackground
        }
    }
    Loader {
        id: roundedPolygonCookieLoader
        z: 0
        visible: !root.useSineCookie
        active: !root.useSineCookie
        sourceComponent: MaterialCookie {
            implicitSize: root.implicitSize
            sides: root.sides
            color: root.colBackground
        }
    }

    // Hour/minutes numbers/dots/lines
    MinuteMarks {
        anchors.fill: parent
        color: root.colOnBackground
        style: root.dialNumberStyle
        dateStyle: root.dateStyle
    }

    // Hour marks in the middle
    Loader {
        id: hourMarksLoader
        anchors.centerIn: parent
        active: root.hourMarks
        visible: active
        opacity: active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        sourceComponent: HourMarks {
            implicitSize: 135 * (1.75 - 0.75 * hourMarksLoader.opacity)
            color: root.colOnBackground
            colOnBackground: Colours.palette.m3secondary
        }
    }

    // Number column in the middle
    Loader {
        id: timeColumnLoader
        anchors.centerIn: parent
        active: root.timeIndicators
        visible: active
        opacity: active ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        scale: 1.4 - 0.4 * timeColumnLoader.opacity

        sourceComponent: TimeColumn {
            color: root.colBackgroundInfo
        }
    }

    // Minute hand
    Loader {
        anchors.fill: parent
        z: 1
        active: root.minuteHandStyle !== "hide"
        visible: active
        sourceComponent: MinuteHand {
            anchors.fill: parent
            clockMinute: root.clockMinute
            style: root.minuteHandStyle
            color: root.colMinuteHand
        }
    }

    // Hour hand
    Loader {
        anchors.fill: parent
        z: item?.style === "hollow" ? 0 : 2
        active: root.hourHandStyle !== "hide"
        visible: active
        sourceComponent: HourHand {
            clockHour: root.clockHour
            clockMinute: root.clockMinute
            style: root.hourHandStyle
            color: root.colHourHand
        }
    }

    // Second hand
    Loader {
        id: secondHandLoader
        z: (root.secondHandStyle === "line") ? 2 : 3
        active: root.secondHandStyle !== "hide"
        visible: active
        anchors.fill: parent
        sourceComponent: SecondHand {
            clockSecond: root.clockSecond
            style: root.secondHandStyle
            color: root.colSecondHand
        }
    }

    // Center dot
    Loader {
        z: 4
        anchors.centerIn: parent
        active: root.minuteHandStyle !== "bold"
        visible: active
        sourceComponent: Rectangle {
            color: root.minuteHandStyle === "medium" ? root.colBackground : root.colMinuteHand
            implicitWidth: 6
            implicitHeight: implicitWidth
            radius: width / 2
        }
    }

    // Date
    Loader {
        anchors.fill: parent
        active: root.dateStyle !== "hide"
        visible: active

        sourceComponent: DateIndicator {
            color: root.colBackgroundInfo
            style: root.dateStyle
        }
    }
}
