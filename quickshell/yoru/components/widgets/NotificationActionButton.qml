import Yoru.Config
import qs.components
import qs.services
import QtQuick
import Quickshell.Services.Notifications

RippleButton {
    id: button
    property string buttonText
    property string urgency

    implicitHeight: 34
    leftPadding: 15
    rightPadding: 15
    buttonRadius: Tokens.rounding.small
    colBackground: (urgency == NotificationUrgency.Critical) ? Colours.palette.m3secondaryContainer : Colours.palette.m3surfaceContainerHighest
    colBackgroundHover: (urgency == NotificationUrgency.Critical) ? Colours.palette.m3secondaryContainerHover : Colours.palette.m3surfaceContainerHighestHover
    colRipple: (urgency == NotificationUrgency.Critical) ? Colours.palette.m3secondaryContainerActive : Colours.palette.m3surfaceContainerHighestActive

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        color: (urgency == NotificationUrgency.Critical) ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3onSurface
    }
}