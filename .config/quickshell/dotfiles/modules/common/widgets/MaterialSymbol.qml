import qs.modules.common
import QtQuick

// Material Symbols Rounded, tuned for Material 3 Expressive: solid glyphs by default.
StyledText {
    id: root
    property real iconSize: Appearance?.font.pixelSize.small ?? 16
    property real fill: 1
    property real truncatedFill: fill.toFixed(1) // Reduce memory consumption spikes from constant font remapping
    font {
        hintingPreference: Font.PreferNoHinting
        family: Appearance?.font.family.iconMaterial ?? "Material Symbols Rounded"
        pixelSize: iconSize
        // Axes only: a font.weight would pin a named instance and reset FILL
        variableAxes: {
            "FILL": truncatedFill,
            "wght": 500,
            "opsz": Math.max(20, Math.min(48, iconSize)),
        }
    }

    Behavior on fill {
        NumberAnimation {
            duration: Appearance?.animation.elementMoveFast.duration ?? 200
            easing.type: Appearance?.animation.elementMoveFast.type ?? Easing.BezierSpline
            easing.bezierCurve: Appearance?.animation.elementMoveFast.bezierCurve ?? [0.34, 0.80, 0.34, 1.00, 1, 1]
        }
    }
}
