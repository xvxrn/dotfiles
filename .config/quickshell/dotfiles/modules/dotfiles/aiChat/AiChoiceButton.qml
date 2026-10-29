import qs.modules.common
import qs.modules.common.widgets
import QtQuick

// Pill-shaped selection button used by the AI panel.
// Backgrounds stay neutral: selection is shown by tone and icon colour, never by a tinted fill.
RippleButton {
    id: root
    property string label
    property string iconName: ""
    implicitHeight: 34
    implicitWidth: (iconName.length > 0 ? 22 : 0) + labelText.implicitWidth + 28
    buttonRadius: Appearance.rounding.full
    colBackground: Appearance.colors.colLayer2
    colBackgroundHover: Appearance.colors.colLayer2Hover
    colBackgroundToggled: Appearance.colors.colLayer3
    colBackgroundToggledHover: Appearance.colors.colLayer3Hover

    contentItem: Row {
        anchors.centerIn: parent
        spacing: 6

        CustomIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            visible: root.iconName.length > 0
            source: root.iconName
            colorize: true
            color: root.toggled ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer2
        }
        StyledText {
            id: labelText
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: root.toggled ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer2
        }
    }
}
