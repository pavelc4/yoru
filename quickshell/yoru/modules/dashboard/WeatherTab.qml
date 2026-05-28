import QtQuick
import QtQuick.Layouts
import Yoru.Config
import qs.components
import qs.services
import Quickshell
import QtQuick.Effects

Item {
    id: root

    readonly property int minWidth: 400 + 400 + Tokens.spacing.normal + 120 + Tokens.padding.large * 2
    readonly property var today: Weather.forecast && Weather.forecast.length > 0 ? Weather.forecast[0] : null

    implicitWidth: Math.max(minWidth, mainCard.implicitWidth)
    implicitHeight: mainCard.implicitHeight

    Component.onCompleted: Weather.reload()

    StyledRect {
        id: mainCard

        anchors.left: parent.left
        anchors.right: parent.right
        radius: 28
        color: Colours.layer(Colours.palette.m3surfaceContainer, 0)
        implicitHeight: mainCol.implicitHeight + 48

        ColumnLayout {
            id: mainCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 24
            spacing: 20

            // Header Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MaterialIcon {
                    text: Weather.icon || "cloud"
                    font.pointSize: 20
                    color: Colours.palette.m3primary
                }

                StyledText {
                    text: qsTr("Weather")
                    font.pointSize: 18
                    font.weight: Font.Bold
                    color: Colours.palette.m3onSurface
                }

                Item { Layout.fillWidth: true }

                // Date Pill Badge
                StyledRect {
                    radius: 16
                    implicitWidth: dateText.implicitWidth + 24
                    implicitHeight: dateText.implicitHeight + 12
                    color: Qt.alpha(Colours.palette.m3primary, 0.15)
                    border.color: Qt.alpha(Colours.palette.m3primary, 0.25)
                    border.width: 1

                    StyledText {
                        id: dateText
                        anchors.centerIn: parent
                        text: new Date().toLocaleDateString(Qt.locale(), "ddd, MMM d")
                        font.pointSize: 10
                        font.weight: Font.Medium
                        color: Colours.palette.m3primary
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                // Top row: Current Weather Card
                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: 180
                    radius: 20
                    color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 20

                        // Left info
                        ColumnLayout {
                            Layout.fillHeight: true
                            spacing: 4
                            Layout.alignment: Qt.AlignLeft

                            RowLayout {
                                spacing: 6
                                MaterialIcon {
                                    text: "location_on"
                                    font.pointSize: 12
                                    color: Colours.palette.m3tertiary
                                }
                                StyledText {
                                    text: Weather.city || qsTr("Loading...")
                                    font.pointSize: 13
                                    font.weight: Font.Medium
                                    color: Colours.palette.m3onSurfaceVariant
                                }
                            }

                            // Stacked Temp
                            Row {
                                spacing: 2
                                StyledText {
                                    text: Weather.cc ? (GlobalConfig.services.useFahrenheit ? `${Weather.cc.tempF}°` : `${Weather.cc.tempC}°`) : "--°"
                                    font.pointSize: 52
                                    font.weight: Font.Bold
                                    color: Colours.palette.m3onSurface
                                }
                                StyledText {
                                    text: GlobalConfig.services.useFahrenheit ? "F" : "C"
                                    font.pointSize: 18
                                    font.weight: Font.Bold
                                    color: Colours.palette.m3primary
                                    anchors.top: parent.top
                                    anchors.topMargin: 12
                                }
                            }

                            StyledText {
                                text: Weather.description || qsTr("Unknown")
                                font.pointSize: 13
                                font.weight: Font.Medium
                                color: Colours.palette.m3primary
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Right large weather icon
                        MaterialIcon {
                            Layout.alignment: Qt.AlignVCenter
                            text: Weather.icon || "cloud"
                            font.pointSize: 64
                            color: Colours.palette.m3secondary
                        }
                    }
                }

                // Middle row: 2x2 Details Card Grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 16
                    columnSpacing: 16

                    DetailCard {
                        Layout.fillWidth: true
                        implicitHeight: 70
                        icon: "water_drop"
                        iconColor: Colours.palette.m3primary
                        label: qsTr("HUMIDITY")
                        value: Weather.humidity + "%"
                    }

                    DetailCard {
                        Layout.fillWidth: true
                        implicitHeight: 70
                        icon: "air"
                        iconColor: Colours.palette.m3secondary
                        label: qsTr("WIND")
                        value: Weather.windSpeed ? Weather.windSpeed.toFixed(1) + " km/h" : "--"
                    }

                    DetailCard {
                        Layout.fillWidth: true
                        implicitHeight: 70
                        icon: "thermostat"
                        iconColor: Colours.palette.m3tertiary
                        label: qsTr("FEELS LIKE")
                        value: Weather.feelsLike
                    }

                    DetailCard {
                        Layout.fillWidth: true
                        implicitHeight: 70
                        icon: "wb_twilight"
                        iconColor: Colours.palette.m3secondary
                        label: qsTr("SUNRISE")
                        value: Weather.sunrise
                    }
                }

                // Bottom row: Forecast Card
                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: forecastCol.implicitHeight + 32
                    radius: 20
                    color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

                    readonly property real globalMin: {
                        if (!Weather.forecast || Weather.forecast.length === 0) return 0;
                        const slice = Weather.forecast.slice(0, 3);
                        return Math.min(...slice.map(d => GlobalConfig.services.useFahrenheit ? d.minTempF : d.minTempC));
                    }
                    readonly property real globalMax: {
                        if (!Weather.forecast || Weather.forecast.length === 0) return 100;
                        const slice = Weather.forecast.slice(0, 3);
                        return Math.max(...slice.map(d => GlobalConfig.services.useFahrenheit ? d.maxTempF : d.maxTempC));
                    }

                    ColumnLayout {
                        id: forecastCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 16

                        Repeater {
                            model: Weather.forecast ? Weather.forecast.slice(0, 3) : []

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 20

                                readonly property int dayIndex: index
                                readonly property real dayMin: GlobalConfig.services.useFahrenheit ? modelData.minTempF : modelData.minTempC
                                readonly property real dayMax: GlobalConfig.services.useFahrenheit ? modelData.maxTempF : modelData.maxTempC
                                readonly property real leftPad: parent.parent.globalMax > parent.parent.globalMin ? (dayMin - parent.parent.globalMin) / (parent.parent.globalMax - parent.parent.globalMin) : 0
                                readonly property real widthPct: parent.parent.globalMax > parent.parent.globalMin ? (dayMax - dayMin) / (parent.parent.globalMax - parent.parent.globalMin) : 1

                                StyledText {
                                    Layout.preferredWidth: 60
                                    text: index === 0 ? qsTr("Today") : new Date(modelData.date).toLocaleDateString(Qt.locale(), "ddd")
                                    font.pointSize: 12
                                    font.weight: Font.Medium
                                    color: Colours.palette.m3onSurface
                                }

                                MaterialIcon {
                                    text: modelData.icon || "cloud"
                                    font.pointSize: 16
                                    color: Colours.palette.m3secondary
                                }

                                // Horizontal Range Bar
                                StyledRect {
                                    Layout.fillWidth: true
                                    implicitHeight: 8
                                    radius: 4
                                    color: Qt.alpha(Colours.palette.m3onSurface, 0.08)

                                    StyledRect {
                                        anchors.left: parent.left
                                        anchors.leftMargin: parent.width * leftPad
                                        width: parent.width * widthPct
                                        height: parent.height
                                        radius: 4
                                        color: dayIndex === 0 ? Colours.palette.m3primary : dayIndex === 1 ? Colours.palette.m3secondary : Colours.palette.m3tertiary
                                    }
                                }

                                // Stacked High/Low Temps
                                ColumnLayout {
                                    spacing: 0
                                    Layout.alignment: Qt.AlignRight
                                    StyledText {
                                        text: `${Math.round(dayMin)}°`
                                        font.pointSize: 9
                                        color: Colours.palette.m3onSurfaceVariant
                                        Layout.alignment: Qt.AlignRight
                                    }
                                    StyledText {
                                        text: `${Math.round(dayMax)}°`
                                        font.pointSize: 13
                                        font.weight: Font.Bold
                                        color: Colours.palette.m3onSurface
                                        Layout.alignment: Qt.AlignRight
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component DetailCard: StyledRect {
        id: detailCard
        radius: 16
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

        property string icon
        property color iconColor
        property string label
        property string value

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            StyledRect {
                implicitWidth: 36
                implicitHeight: 36
                radius: 18
                color: Qt.alpha(detailCard.iconColor, 0.15)
                Layout.alignment: Qt.AlignVCenter

                MaterialIcon {
                    anchors.centerIn: parent
                    text: detailCard.icon
                    font.pointSize: 14
                    color: detailCard.iconColor
                }
            }

            ColumnLayout {
                spacing: 2
                Layout.alignment: Qt.AlignVCenter

                StyledText {
                    text: detailCard.label
                    font.pointSize: 8.5
                    font.weight: Font.Bold
                    color: Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    text: detailCard.value
                    font.pointSize: 12
                    font.weight: Font.Bold
                    color: Colours.palette.m3onSurface
                }
            }
        }
    }
}
