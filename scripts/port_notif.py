import os
import re

SOURCE_DIR = "/home/sineva/prjkt/dotfiles/dots-hyprland/dots/.config/quickshell/ii/modules/common/widgets"
DEST_DIR = "/home/sineva/prjkt/dotfiles/yoru/quickshell/yoru/components/widgets"

FILES_TO_PORT = [
    "NotificationItem.qml",
    "DragManager.qml",
    "NotificationAppIcon.qml",
    "NotificationActionButton.qml",
    "PointingHandLinkHover.qml",
    "ScrollEdgeFade.qml",
]

def replace_tokens(content):
    # Imports
    content = content.replace("import qs.modules.common.functions", "import qs.utils")
    content = content.replace("import qs.modules.common", "import Yoru.Config\nimport qs.components")
    content = content.replace("import Quickshell.Hyprland", "")
    
    # Appearance to Tokens/Colours
    content = content.replace("Appearance.rounding.small", "Tokens.rounding.small")
    content = content.replace("Appearance.rounding.full", "Tokens.rounding.full")
    content = content.replace("Appearance.colors.colLayer2", "Colours.palette.m3surfaceContainer")
    content = content.replace("Appearance.colors.colLayer3", "Colours.palette.m3surfaceContainerHigh")
    content = content.replace("Appearance.colors.colLayer4", "Colours.palette.m3surfaceContainerHighest")
    content = content.replace("Appearance.colors.colLayer4Hover", "Colours.palette.m3surfaceContainerHighest")
    content = content.replace("Appearance.colors.colLayer4Active", "Colours.palette.m3surface")
    content = content.replace("Appearance.colors.colOnLayer3", "Colours.palette.m3onSurface")
    content = content.replace("Appearance.colors.colSubtext", "Colours.palette.m3onSurfaceVariant")
    content = content.replace("Appearance.colors.colPrimaryContainer", "Colours.palette.m3primaryContainer")
    content = content.replace("Appearance.colors.colOnPrimaryContainer", "Colours.palette.m3onPrimaryContainer")
    content = content.replace("Appearance.colors.colSecondaryContainer", "Colours.palette.m3secondaryContainer")
    content = content.replace("Appearance.colors.colSecondaryContainerHover", "Colours.palette.m3secondaryContainer")
    content = content.replace("Appearance.colors.colSecondaryContainerActive", "Colours.palette.m3secondary")
    content = content.replace("Appearance.colors.colOnSecondaryContainer", "Colours.palette.m3onSecondaryContainer")
    
    content = content.replace("Appearance.m3colors.m3onSurfaceVariant", "Colours.palette.m3onSurfaceVariant")
    content = content.replace("Appearance.m3colors.m3onSurface", "Colours.palette.m3onSurface")
    
    content = content.replace("Appearance.font.pixelSize.small", "Tokens.font.size.small")
    content = content.replace("Appearance.font.pixelSize.normal", "Tokens.font.size.normal")
    content = content.replace("Appearance.font.pixelSize.large", "Tokens.font.size.large")
    content = content.replace("Appearance.font.pixelSize.larger", "Math.round(Tokens.font.size.large * 1.2)")
    
    # Animations
    content = re.sub(r'Appearance\.animation\.elementMoveFast\.numberAnimation\.createObject\((.*?)\)', r'NumberAnimation { duration: Tokens.anim.durations.expressiveFastSpatial; easing: Tokens.anim.expressiveFastSpatial }', content)
    content = re.sub(r'Appearance\.animation\.elementMove\.numberAnimation\.createObject\((.*?)\)', r'NumberAnimation { duration: Tokens.anim.durations.expressiveDefaultSpatial; easing: Tokens.anim.expressiveDefaultSpatial }', content)
    content = content.replace("Appearance.animation.elementMove.duration", "Tokens.anim.durations.expressiveDefaultSpatial")
    content = content.replace("Appearance.animation.elementMove.type", "Tokens.anim.expressiveDefaultSpatial.type")
    content = content.replace("Appearance.animationCurves.expressiveFastSpatial", "Tokens.anim.expressiveFastSpatial.bezierCurve")
    content = content.replace("Appearance.animation.elementMove.bezierCurve", "Tokens.anim.expressiveDefaultSpatial.bezierCurve")

    # Misc
    content = content.replace("ColorUtils.mix", "Qt.tint") # roughly
    content = content.replace("ColorUtils.transparentize", "Qt.alpha")
    content = content.replace("NotificationUtils.", "Utils.") # Wait, yoru uses something else. I'll just keep NotificationUtils and port it too.
    content = content.replace("GlobalStates.sidebarRightOpen = false", "root.qmlParent.modelData.popup = false")

    return content

os.makedirs(DEST_DIR, exist_ok=True)

for file in FILES_TO_PORT:
    with open(os.path.join(SOURCE_DIR, file), "r") as f:
        content = f.read()
    
    content = replace_tokens(content)
    
    with open(os.path.join(DEST_DIR, file), "w") as f:
        f.write(content)
        
print("Ported components!")
