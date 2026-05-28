import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.UPower
import Yoru.Config
import Yoru.Internal
import qs.components
import qs.components.misc
import qs.services
import Quickshell.Io
import qs.utils
import QtQuick.Effects

Item {
    id: root

    readonly property int minWidth: 400 + 400 + Tokens.spacing.normal + 120 + Tokens.padding.large * 2

    Ref {
        service: SystemUsage
    }

    function displayTemp(temp: real): string {
        return `${Math.ceil(GlobalConfig.services.useFahrenheitPerformance ? temp * 1.8 + 32 : temp)}°${GlobalConfig.services.useFahrenheitPerformance ? "F" : "C"}`;
    }

    function getBatterySvg(percentage: real, isCharging: bool): string {
        if (isCharging && percentage < 1)
            return Qt.resolvedUrl("../../assets/icons/fluent/battery-charge.svg");

        const pct = Math.round(percentage * 100);
        if (pct >= 95) return Qt.resolvedUrl("../../assets/icons/fluent/battery-full.svg");
        if (pct >= 85) return Qt.resolvedUrl("../../assets/icons/fluent/battery-9.svg");
        if (pct >= 75) return Qt.resolvedUrl("../../assets/icons/fluent/battery-8.svg");
        if (pct >= 65) return Qt.resolvedUrl("../../assets/icons/fluent/battery-7.svg");
        if (pct >= 55) return Qt.resolvedUrl("../../assets/icons/fluent/battery-6.svg");
        if (pct >= 45) return Qt.resolvedUrl("../../assets/icons/fluent/battery-5.svg");
        if (pct >= 35) return Qt.resolvedUrl("../../assets/icons/fluent/battery-4.svg");
        if (pct >= 25) return Qt.resolvedUrl("../../assets/icons/fluent/battery-3.svg");
        if (pct >= 15) return Qt.resolvedUrl("../../assets/icons/fluent/battery-2.svg");
        if (pct >= 5) return Qt.resolvedUrl("../../assets/icons/fluent/battery-1.svg");
        return Qt.resolvedUrl("../../assets/icons/fluent/battery-0.svg");
    }

    implicitWidth: Math.max(minWidth, mainCard.implicitWidth)
    implicitHeight: mainCard.implicitHeight

    property string uptimeStr: ""

    FileView {
        id: fileUptime
        path: "/proc/uptime"
        onLoaded: {
            const up = parseInt(text().split(" ")[0] ?? 0);
            const days = Math.floor(up / 86400);
            const hours = Math.floor((up % 86400) / 3600);
            const minutes = Math.floor((up % 3600) / 60);

            let str = "";
            if (days > 0) str += `${days}d `;
            if (hours > 0) str += `${hours}h `;
            if (minutes > 0 || !str) str += `${minutes}m`;
            uptimeStr = str.trim();
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 30000
        triggeredOnStart: true
        onTriggered: fileUptime.reload()
    }

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

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MaterialIcon {
                    text: "memory"
                    font.pointSize: 20
                    color: Colours.palette.m3primary
                }

                StyledText {
                    text: qsTr("Performance")
                    font.pointSize: 18
                    font.weight: Font.Bold
                    color: Colours.palette.m3onSurface
                }

                Item { Layout.fillWidth: true }

                StyledRect {
                    radius: 16
                    implicitWidth: uptimeText.implicitWidth + 24
                    implicitHeight: uptimeText.implicitHeight + 12
                    color: Qt.alpha(Colours.palette.m3primary, 0.15)
                    border.color: Qt.alpha(Colours.palette.m3primary, 0.25)
                    border.width: 1

                    StyledText {
                        id: uptimeText
                        anchors.centerIn: parent
                        text: uptimeStr ? qsTr("Uptime: %1").arg(uptimeStr) : qsTr("Uptime: --")
                        font.pointSize: 10
                        font.weight: Font.Medium
                        color: Colours.palette.m3primary
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    CpuCard {
                        Layout.fillWidth: true
                        implicitHeight: 145
                    }

                    GpuCard {
                        Layout.fillWidth: true
                        implicitHeight: 145
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    MemoryCard {
                        Layout.fillWidth: true
                        implicitHeight: 130
                    }

                    BatteryCard {
                        Layout.preferredWidth: 260
                        implicitHeight: 130
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    StorageCard {
                        Layout.fillWidth: true
                        implicitHeight: 100
                    }

                    NetworkCard {
                        Layout.fillWidth: true
                        implicitHeight: 100
                    }
                }
            }
        }
    }

    component CpuCard: StyledRect {
        radius: 20
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledRect {
                    implicitWidth: 40
                    implicitHeight: 40
                    radius: 20
                    color: Qt.alpha(Colours.palette.m3primary, 0.15)

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "memory"
                        font.pointSize: 16
                        color: Colours.palette.m3primary
                    }
                }

                ColumnLayout {
                    spacing: 2
                    StyledText {
                        text: qsTr("CPU")
                        font.pointSize: 13
                        font.weight: Font.Bold
                        color: Colours.palette.m3onSurface
                    }
                    StyledText {
                        text: SystemUsage.cpuName || qsTr("Unknown CPU")
                        font.pointSize: 9.5
                        color: Colours.palette.m3onSurfaceVariant
                        elide: Text.ElideRight
                        Layout.maximumWidth: 150
                    }
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: `${Math.round(SystemUsage.cpuPerc * 100)}%`
                    font.pointSize: 16
                    font.weight: Font.Bold
                    color: Colours.palette.m3primary
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledRect {
                    id: cpuBarTrack
                    Layout.fillWidth: true
                    implicitHeight: 8
                    radius: 4
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.1)

                    StyledRect {
                        width: parent.width * SystemUsage.cpuPerc
                        height: parent.height
                        radius: 4
                        color: Colours.palette.m3primary

                        StyledRect {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            implicitWidth: 12
                            implicitHeight: 12
                            radius: 6
                            color: Colours.palette.m3onPrimaryContainer
                            border.color: Colours.palette.m3primary
                            border.width: 2
                            visible: SystemUsage.cpuPerc > 0.02
                        }
                    }
                }

                StyledText {
                    text: root.displayTemp(SystemUsage.cpuTemp)
                    font.pointSize: 10.5
                    font.weight: Font.Medium
                    color: Colours.palette.m3onSurfaceVariant
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledRect {
                    visible: !!SystemUsage.cpuGovernor
                    radius: 8
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.08)
                    implicitWidth: govRow.implicitWidth + 16
                    implicitHeight: govRow.implicitHeight + 8

                    RowLayout {
                        id: govRow
                        anchors.centerIn: parent
                        spacing: 6
                        MaterialIcon {
                            text: "settings"
                            font.pointSize: 9
                            color: Colours.palette.m3onSurfaceVariant
                        }
                        StyledText {
                            text: SystemUsage.cpuGovernor
                            font.pointSize: 9
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }

                StyledRect {
                    visible: SystemUsage.cpuFreqMhz > 0
                    radius: 8
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.08)
                    implicitWidth: freqRow.implicitWidth + 16
                    implicitHeight: freqRow.implicitHeight + 8

                    RowLayout {
                        id: freqRow
                        anchors.centerIn: parent
                        spacing: 6
                        MaterialIcon {
                            text: "timeline"
                            font.pointSize: 9
                            color: Colours.palette.m3onSurfaceVariant
                        }
                        StyledText {
                            text: `${(SystemUsage.cpuFreqMhz / 1000).toFixed(1)} GHz`
                            font.pointSize: 9
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }

                StyledRect {
                    visible: SystemUsage.cpuCores > 0
                    radius: 8
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.08)
                    implicitWidth: coreText.implicitWidth + 16
                    implicitHeight: coreText.implicitHeight + 8

                    StyledText {
                        id: coreText
                        anchors.centerIn: parent
                        text: `${SystemUsage.cpuCores > 4 ? Math.ceil(SystemUsage.cpuCores / 2) : SystemUsage.cpuCores}C`
                        font.pointSize: 9
                        font.weight: Font.Medium
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }

                StyledRect {
                    visible: SystemUsage.cpuCores > 0
                    radius: 8
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.08)
                    implicitWidth: threadText.implicitWidth + 16
                    implicitHeight: threadText.implicitHeight + 8

                    StyledText {
                        id: threadText
                        anchors.centerIn: parent
                        text: `${SystemUsage.cpuCores}T`
                        font.pointSize: 9
                        font.weight: Font.Medium
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
            }
        }
    }

    component GpuCard: StyledRect {
        radius: 20
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledRect {
                    implicitWidth: 40
                    implicitHeight: 40
                    radius: 20
                    color: Qt.alpha(Colours.palette.m3secondary, 0.15)

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "developer_board"
                        font.pointSize: 16
                        color: Colours.palette.m3secondary
                    }
                }

                ColumnLayout {
                    spacing: 2
                    StyledText {
                        text: qsTr("GPU")
                        font.pointSize: 13
                        font.weight: Font.Bold
                        color: Colours.palette.m3onSurface
                    }
                    StyledText {
                        text: SystemUsage.gpuName || qsTr("Unknown GPU")
                        font.pointSize: 9.5
                        color: Colours.palette.m3onSurfaceVariant
                        elide: Text.ElideRight
                        Layout.maximumWidth: 150
                    }
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: `${Math.round(SystemUsage.gpuPerc * 100)}%`
                    font.pointSize: 16
                    font.weight: Font.Bold
                    color: Colours.palette.m3secondary
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledRect {
                    id: gpuBarTrack
                    Layout.fillWidth: true
                    implicitHeight: 8
                    radius: 4
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.1)

                    StyledRect {
                        width: parent.width * SystemUsage.gpuPerc
                        height: parent.height
                        radius: 4
                        color: Colours.palette.m3secondary

                        StyledRect {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            implicitWidth: 12
                            implicitHeight: 12
                            radius: 6
                            color: Colours.palette.m3onSecondaryContainer
                            border.color: Colours.palette.m3secondary
                            border.width: 2
                            visible: SystemUsage.gpuPerc > 0.02
                        }
                    }
                }

                StyledText {
                    text: root.displayTemp(SystemUsage.gpuTemp)
                    font.pointSize: 10.5
                    font.weight: Font.Medium
                    color: Colours.palette.m3onSurfaceVariant
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledRect {
                    visible: SystemUsage.gpuVramTotal > 0
                    radius: 8
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.08)
                    implicitWidth: vramRow.implicitWidth + 16
                    implicitHeight: vramRow.implicitHeight + 8

                    RowLayout {
                        id: vramRow
                        anchors.centerIn: parent
                        spacing: 6
                        MaterialIcon {
                            text: "storage"
                            font.pointSize: 9
                            color: Colours.palette.m3onSurfaceVariant
                        }
                        StyledText {
                            text: `${Math.round(SystemUsage.gpuVramTotal)} MiB`
                            font.pointSize: 9
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }

                StyledRect {
                    visible: SystemUsage.gpuPowerW > 0
                    radius: 8
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.08)
                    implicitWidth: powerRow.implicitWidth + 16
                    implicitHeight: powerRow.implicitHeight + 8

                    RowLayout {
                        id: powerRow
                        anchors.centerIn: parent
                        spacing: 6
                        MaterialIcon {
                            text: "bolt"
                            font.pointSize: 9
                            color: Colours.palette.m3onSurfaceVariant
                        }
                        StyledText {
                            text: `${SystemUsage.gpuPowerW.toFixed(1)} W`
                            font.pointSize: 9
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }
            }
        }
    }

    component MemoryCard: StyledRect {
        radius: 20
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                RowLayout {
                    spacing: 8
                    MaterialIcon {
                        text: "developer_board"
                        font.pointSize: 16
                        color: Colours.palette.m3onSurface
                    }
                    StyledText {
                        text: qsTr("Memory")
                        font.pointSize: 13
                        font.weight: Font.Bold
                        color: Colours.palette.m3onSurface
                    }
                }

                Item { Layout.fillWidth: true }

                StyledRect {
                    radius: 8
                    implicitWidth: memPercText.implicitWidth + 16
                    implicitHeight: memPercText.implicitHeight + 8
                    color: Qt.alpha(Colours.palette.m3onSurface, 0.08)

                    StyledText {
                        id: memPercText
                        anchors.centerIn: parent
                        text: `${Math.round(SystemUsage.memPerc * 100)}%`
                        font.pointSize: 9.5
                        font.weight: Font.Bold
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
            }

            StyledText {
                text: {
                    const usedFmt = SystemUsage.formatKib(SystemUsage.memUsed);
                    const totalFmt = SystemUsage.formatKib(SystemUsage.memTotal);
                    return `${usedFmt.value.toFixed(1)} / ${Math.floor(totalFmt.value)} ${totalFmt.unit}`;
                }
                font.pointSize: 22
                font.weight: Font.Bold
                color: Colours.palette.m3onSurface
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 8
                radius: 4
                color: Qt.alpha(Colours.palette.m3onSurface, 0.1)

                StyledRect {
                    width: parent.width * SystemUsage.memPerc
                    height: parent.height
                    radius: 4
                    color: Colours.palette.m3primary
                }
            }
        }
    }

    component BatteryCard: StyledRect {
        radius: 20
        color: Colours.palette.m3primary

        readonly property real percentage: UPower.displayDevice.percentage
        readonly property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4

            Item {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 48
                implicitHeight: 48

                Image {
                    id: batterySvg
                    source: root.getBatterySvg(parent.parent.percentage, parent.parent.isCharging)
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    visible: false
                }

                MultiEffect {
                    source: batterySvg
                    anchors.fill: batterySvg
                    colorization: 1.0
                    colorizationColor: Colours.palette.m3onPrimary
                }
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: `${Math.round(parent.parent.percentage * 100)}%`
                font.pointSize: 22
                font.weight: Font.Bold
                color: Colours.palette.m3onPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: {
                    if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
                        return qsTr("Charged");

                    if (parent.parent.isCharging)
                        return qsTr("Charging");

                    const s = UPower.displayDevice.timeToEmpty;
                    if (s === 0)
                        return qsTr("Discharging");

                    const hr = Math.floor(s / 3600);
                    const min = Math.floor((s % 3600) / 60);
                    if (hr > 0)
                        return `${hr}h ${min}m`;

                    return `${min}m`;
                }
                font.pointSize: 10
                font.weight: Font.Medium
                color: Qt.alpha(Colours.palette.m3onPrimary, 0.7)
            }
        }
    }

    component StorageCard: StyledRect {
        id: storageCard
        radius: 20
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

        property var currentDisk: null

        Connections {
            target: SystemUsage
            function onDisksChanged() {
                if (SystemUsage.disks && SystemUsage.disks.length > 0) {
                    storageCard.currentDisk = SystemUsage.disks[0];
                } else {
                    storageCard.currentDisk = null;
                }
            }
        }

        Component.onCompleted: {
            if (SystemUsage.disks && SystemUsage.disks.length > 0) {
                storageCard.currentDisk = SystemUsage.disks[0];
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Item {
                    implicitWidth: 64
                    implicitHeight: 64
                    Layout.alignment: Qt.AlignVCenter

                    ArcGauge {
                        anchors.fill: parent
                        percentage: storageCard.currentDisk ? storageCard.currentDisk.perc : 0
                        accentColor: Colours.palette.m3secondary
                        trackColor: Qt.alpha(Colours.palette.m3onSurface, 0.08)
                        startAngle: -0.5 * Math.PI
                        sweepAngle: 2 * Math.PI
                        lineWidth: 6
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: storageCard.currentDisk ? `${Math.round(storageCard.currentDisk.perc * 100)}%` : "0%"
                        font.pointSize: 10
                        font.weight: Font.Bold
                        color: Colours.palette.m3onSurface
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    StyledText {
                        text: qsTr("Storage")
                        font.pointSize: 13
                        font.weight: Font.Bold
                        color: Colours.palette.m3onSurface
                    }

                    StyledText {
                        text: {
                            if (!storageCard.currentDisk)
                                return "—";
                            const usedFmt = SystemUsage.formatKib(storageCard.currentDisk.used);
                            const totalFmt = SystemUsage.formatKib(storageCard.currentDisk.total);
                            return `${usedFmt.value.toFixed(1)} / ${Math.floor(totalFmt.value)} ${totalFmt.unit}`;
                        }
                        font.pointSize: 10
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
            }
        }
    }

    component NetworkCard: StyledRect {
        radius: 20
        color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

        Ref {
            service: NetworkUsage
        }

        Timer {
            running: true
            repeat: true
            interval: 1000
            onTriggered: {
                histRepeater.model = 0;
                histRepeater.model = 6;
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                RowLayout {
                    spacing: 6
                    MaterialIcon {
                        text: "arrow_downward"
                        font.pointSize: 12
                        color: Colours.palette.m3tertiary
                    }
                    StyledText {
                        text: {
                            const fmt = NetworkUsage.formatBytes(NetworkUsage.downloadSpeed ?? 0);
                            return fmt ? `${fmt.value.toFixed(1)} ${fmt.unit.split("/")[0]}` : "0.0 B";
                        }
                        font.pointSize: 12
                        font.weight: Font.Bold
                        color: Colours.palette.m3onSurface
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 6
                    MaterialIcon {
                        text: "arrow_upward"
                        font.pointSize: 12
                        color: Colours.palette.m3secondary
                    }
                    StyledText {
                        text: {
                            const fmt = NetworkUsage.formatBytes(NetworkUsage.uploadSpeed ?? 0);
                            return fmt ? `${fmt.value.toFixed(1)} ${fmt.unit.split("/")[0]}` : "0.0 B";
                        }
                        font.pointSize: 12
                        font.weight: Font.Bold
                        color: Colours.palette.m3onSurface
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Row {
                    height: 40
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Repeater {
                        id: histRepeater
                        model: 6

                        delegate: StyledRect {
                            width: 8
                            radius: 4
                            anchors.bottom: parent.bottom

                            readonly property real downSample: {
                                const vals = NetworkUsage.downloadBuffer.values;
                                const idx = vals.length - 1 - (5 - index);
                                return idx >= 0 ? vals[idx] : 0;
                            }
                            readonly property real upSample: {
                                const vals = NetworkUsage.uploadBuffer.values;
                                const idx = vals.length - 1 - (5 - index);
                                return idx >= 0 ? vals[idx] : 0;
                            }

                            height: {
                                const maxVal = Math.max(NetworkUsage.downloadBuffer.maximum, NetworkUsage.uploadBuffer.maximum, 1024);
                                const val = Math.max(downSample, upSample);
                                const ratio = maxVal > 0 ? val / maxVal : 0;
                                return 12 + ratio * 28;
                            }

                            color: {
                                const val = Math.max(downSample, upSample);
                                if (val < 1024)
                                    return Qt.alpha(Colours.palette.m3onSurface, 0.15);

                                if (downSample > upSample)
                                    return Colours.palette.m3tertiary;

                                return Colours.palette.m3secondary;
                            }

                            Behavior on height {
                                NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
                            }
                        }
                    }
                }
            }
        }
    }
}
