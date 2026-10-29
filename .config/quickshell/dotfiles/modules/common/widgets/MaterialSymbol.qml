import qs.modules.common
import QtQuick

// Material Symbols Rounded, filled for Material 3 Expressive.
// Qt ignores variable axes in this shell, so the filled weight is a static font instance
// (MaterialSymbolsRoundedFilled.ttf, installed by hand next to Google Sans Flex).
StyledText {
    id: root
    property real iconSize: Appearance?.font.pixelSize.small ?? 16
    property real fill: 1

    font {
        hintingPreference: Font.PreferNoHinting
        family: root.fill >= 0.5 ? "Material Symbols Rounded Filled" : "Material Symbols Rounded"
        pixelSize: iconSize
    }
    // Native text rendering does not shape the ligatures of the static filled instance
    renderType: Text.QtRendering
}
