pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../components"

ColumnLayout {
    id: clockColumn
    spacing: 4

    property bool isVertical: true
    property color colText: Colours.palette.m3onPrimaryContainer
    property var textHorizontalAlignment: Text.AlignHCenter

    // Time
    ClockText {
        id: timeTextTop
        text: clockColumn.isVertical ? Time.hourStr.padStart(2, "0") : Time.timeStr
        color: clockColumn.colText
        horizontalAlignment: Text.AlignHCenter
        font {
            pixelSize: 64
            weight: Font.Bold
            family: Tokens.font.family.sans
        }
    }

    Loader {
        Layout.topMargin: -20
        Layout.fillWidth: true
        active: clockColumn.isVertical
        visible: active
        sourceComponent: ClockText {
            id: timeTextBottom
            text: Time.minuteStr.padStart(2, "0")
            color: clockColumn.colText
            horizontalAlignment: clockColumn.textHorizontalAlignment
            font {
                pixelSize: timeTextTop.font.pixelSize
                weight: timeTextTop.font.weight
                family: timeTextTop.font.family
            }
        }
    }

    // Date
    ClockText {
        visible: true
        Layout.topMargin: -10
        Layout.fillWidth: true
        text: Qt.locale().toString(Time.date, "dddd, MMMM dd")
        color: clockColumn.colText
        horizontalAlignment: clockColumn.textHorizontalAlignment
    }
}
