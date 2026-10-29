import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import qs.modules.common.functions

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Item {
    id: root
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property string cleanedTitle: StringUtils.cleanMusicTitle(activePlayer?.trackTitle) || Translation.tr("No media")
    // Long titles get more room, but never more than a quarter of the screen
    readonly property real maxTextWidth: Math.max(180, Math.min(420, (root.Window.window?.screen?.width ?? 1920) * 0.28))

    Layout.fillHeight: true
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    Behavior on implicitWidth {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    TextMetrics {
        id: titleMetrics
        text: root.cleanedTitle
        font {
            family: Appearance.font.family.main
            pixelSize: Appearance.font.pixelSize.normal
            hintingPreference: Font.PreferDefaultHinting
            variableAxes: Appearance.font.variableAxes.main
        }
    }

    Timer {
        running: activePlayer?.playbackState == MprisPlaybackState.Playing
        interval: Config.options.resources.updateInterval
        repeat: true
        onTriggered: activePlayer.positionChanged()
    }

    MouseArea { // Playback control; middle click toggles, left click does nothing
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton | Qt.BackButton | Qt.ForwardButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onPressed: (event) => {
            if (!root.activePlayer)
                return;
            if (event.button === Qt.MiddleButton) {
                root.activePlayer.togglePlaying();
            } else if (event.button === Qt.BackButton) {
                root.activePlayer.previous();
            } else if (event.button === Qt.ForwardButton || event.button === Qt.RightButton) {
                root.activePlayer.next();
            }
        }
    }

    RowLayout { // Real content
        id: rowLayout

        spacing: 4
        anchors.fill: parent

        ClippedFilledCircularProgress {
            id: mediaCircProg
            Layout.alignment: Qt.AlignVCenter
            lineWidth: Appearance.rounding.unsharpen
            value: activePlayer?.position / activePlayer?.length
            implicitSize: 20
            colPrimary: Appearance.colors.colOnSecondaryContainer
            enableAnimation: false

            Item {
                anchors.centerIn: parent
                width: mediaCircProg.implicitSize
                height: mediaCircProg.implicitSize

                MaterialSymbol {
                    anchors.centerIn: parent
                    fill: 1
                    text: activePlayer?.isPlaying ? "pause" : "music_note"
                    iconSize: Appearance.font.pixelSize.normal
                    color: Appearance.m3colors.m3onSecondaryContainer
                }
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: rowLayout.spacing
            Layout.preferredWidth: Math.min(Math.ceil(titleMetrics.advanceWidth), root.maxTextWidth)
            elide: Text.ElideRight
            color: Appearance.colors.colOnLayer1
            text: root.cleanedTitle
        }
    }
}
