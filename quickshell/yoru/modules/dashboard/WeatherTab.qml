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

                // Row 1: Left tall card & Right two cards
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    // Left Tall Current Weather Card
                    StyledRect {
                        Layout.preferredWidth: mainCol.width * 0.45
                        implicitHeight: 236
                        radius: 20
                        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

                        Row {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 20
                            anchors.leftMargin: 20
                            spacing: 6
                            MaterialIcon {
                                text: "location_on"
                                font.pointSize: 12
                                color: Colours.palette.m3tertiary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            StyledText {
                                text: Weather.city || qsTr("Loading...")
                                font.pointSize: 13
                                font.weight: Font.Medium
                                color: Colours.palette.m3onSurfaceVariant
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 12
                            spacing: 4
                            width: parent.width - 32

                            MaterialIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Weather.icon || "cloud"
                                font.pointSize: 64
                                color: Colours.palette.m3secondary
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 2
                                StyledText {
                                    text: Weather.cc ? (GlobalConfig.services.useFahrenheit ? `${Weather.cc.tempF}` : `${Weather.cc.tempC}`) : "--"
                                    font.pointSize: 48
                                    font.weight: Font.Bold
                                    color: Colours.palette.m3onSurface
                                }
                                StyledText {
                                    text: "°" + (GlobalConfig.services.useFahrenheit ? "F" : "C")
                                    font.pointSize: 18
                                    font.weight: Font.Bold
                                    color: Colours.palette.m3primary
                                    anchors.top: parent.top
                                    anchors.topMargin: 8
                                }
                            }

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Weather.description || qsTr("Unknown")
                                font.pointSize: 13
                                font.weight: Font.Medium
                                color: Colours.palette.m3primary
                            }
                        }
                    }

                    // Right Side: Two Stacked Cards (Humidity & Wind)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        // Humidity Card
                        DetailCardHorizontal {
                            Layout.fillWidth: true
                            implicitHeight: 110
                            icon: "water_drop"
                            iconColor: Colours.palette.m3primary
                            label: qsTr("HUMIDITY")
                            value: Weather.humidity + "%"
                        }

                        // Wind Card
                        DetailCardHorizontal {
                            Layout.fillWidth: true
                            implicitHeight: 110
                            icon: "air"
                            iconColor: Colours.palette.m3secondary
                            label: qsTr("WIND")
                            value: Weather.windSpeed ? Weather.windSpeed.toFixed(1) + " km/h" : "--"
                        }
                    }
                }

                // Row 2: Wide split Sunrise & Feels Like card
                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: 64
                    radius: 20
                    color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 0

                        // Left section: Sunrise
                        Row {
                            spacing: 12
                            Layout.alignment: Qt.AlignVCenter

                            StyledRect {
                                width: 36
                                height: 36
                                radius: 18
                                color: Qt.alpha(Colours.palette.m3tertiary, 0.15)
                                anchors.verticalCenter: parent.verticalCenter

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    text: "wb_twilight"
                                    font.pointSize: 14
                                    color: Colours.palette.m3tertiary
                                }
                            }

                            Row {
                                spacing: 8
                                anchors.verticalCenter: parent.verticalCenter
                                StyledText {
                                    text: qsTr("SUNRISE")
                                    font.pointSize: 8.5
                                    font.weight: Font.Bold
                                    color: Colours.palette.m3onSurfaceVariant
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: Weather.sunrise
                                    font.pointSize: 12
                                    font.weight: Font.Bold
                                    color: Colours.palette.m3onSurface
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Right section: Feels Like
                        Row {
                            spacing: 12
                            Layout.alignment: Qt.AlignVCenter

                            Row {
                                spacing: 8
                                anchors.verticalCenter: parent.verticalCenter
                                StyledText {
                                    text: qsTr("FEELS LIKE")
                                    font.pointSize: 8.5
                                    font.weight: Font.Bold
                                    color: Colours.palette.m3onSurfaceVariant
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: Weather.feelsLike
                                    font.pointSize: 12
                                    font.weight: Font.Bold
                                    color: Colours.palette.m3onSurface
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            StyledRect {
                                width: 36
                                height: 36
                                radius: 18
                                color: Qt.alpha(Colours.palette.m3primary, 0.15)
                                anchors.verticalCenter: parent.verticalCenter

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    text: "thermostat"
                                    font.pointSize: 14
                                    color: Colours.palette.m3primary
                                }
                            }
                        }
                    }
                }

                // Row 3: Forecast Card
                StyledRect {
                    id: forecastCard
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
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        anchors.topMargin: 16
                        anchors.bottomMargin: 16
                        spacing: 16

                        Repeater {
                            model: Weather.forecast ? Weather.forecast.slice(0, 3) : []

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 20

                                readonly property int dayIndex: index
                                readonly property real dayMin: GlobalConfig.services.useFahrenheit ? modelData.minTempF : modelData.minTempC
                                readonly property real dayMax: GlobalConfig.services.useFahrenheit ? modelData.maxTempF : modelData.maxTempC
                                readonly property real leftPad: forecastCard.globalMax > forecastCard.globalMin ? (dayMin - forecastCard.globalMin) / (forecastCard.globalMax - forecastCard.globalMin) : 0
                                readonly property real widthPct: forecastCard.globalMax > forecastCard.globalMin ? (dayMax - dayMin) / (forecastCard.globalMax - forecastCard.globalMin) : 1

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
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop {
                                                position: 0.0
                                                color: dayIndex === 0 ? Qt.alpha(Colours.palette.m3primary, 0.5) :
                                                       dayIndex === 1 ? Qt.alpha(Colours.palette.m3success, 0.5) :
                                                       Qt.alpha(Colours.palette.m3tertiary, 0.5)
                                            }
                                            GradientStop {
                                                position: 1.0
                                                color: dayIndex === 0 ? Colours.palette.m3primary :
                                                       dayIndex === 1 ? Colours.palette.m3success :
                                                       Colours.palette.m3tertiary
                                            }
                                        }
                                    }
                                }

                                // Stacked High/Low Temps
                                Item {
                                    Layout.preferredWidth: 32
                                    Layout.fillHeight: true

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.right: parent.right
                                        spacing: 1

                                        StyledText {
                                            text: `${Math.round(dayMin)}°`
                                            font.pointSize: 9.5
                                            color: Colours.palette.m3onSurfaceVariant
                                            anchors.right: parent.right
                                        }
                                        StyledText {
                                            text: `${Math.round(dayMax)}°`
                                            font.pointSize: 13
                                            font.weight: Font.Bold
                                            color: Colours.palette.m3onSurface
                                            anchors.right: parent.right
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component DetailCardHorizontal: StyledRect {
        id: detCardHoriz
        radius: 16
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

        property string icon
        property color iconColor
        property string label
        property string value

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 24
            spacing: 20

            StyledRect {
                width: 44
                height: 44
                radius: 22
                color: Qt.alpha(detCardHoriz.iconColor, 0.15)
                anchors.verticalCenter: parent.verticalCenter

                MaterialIcon {
                    anchors.centerIn: parent
                    text: detCardHoriz.icon
                    font.pointSize: 16
                    color: detCardHoriz.iconColor
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                StyledText {
                    text: detCardHoriz.label
                    font.pointSize: 8.5
                    font.weight: Font.Bold
                    color: Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    text: detCardHoriz.value
                    font.pointSize: 18
                    font.weight: Font.Bold
                    color: Colours.palette.m3onSurface
                }
            }
        }
    }
}
