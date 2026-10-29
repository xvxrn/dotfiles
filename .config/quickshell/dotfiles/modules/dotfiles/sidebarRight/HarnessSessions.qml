import qs.modules.common
import qs.modules.common.widgets
import qs
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    radius: Appearance.rounding.normal
    color: Appearance.colors.colLayer1
    implicitHeight: sessionsColumn.implicitHeight + 20

    property var sessions: []
    property var buffer: []

    function formatElapsed(seconds) {
        const total = Number(seconds) || 0;
        const hours = Math.floor(total / 3600);
        const minutes = Math.floor((total % 3600) / 60);
        return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
    }

    Process {
        id: sessionProcess
        command: ["bash", `${FileUtils.trimFileProtocol(Directories.scriptPath)}/harness-sessions.sh`]
        stdout: SplitParser {
            onRead: line => {
                if (line.length > 0)
                    root.buffer.push(line);
            }
        }
        onExited: {
            root.sessions = root.buffer;
            root.buffer = [];
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.buffer = [];
            sessionProcess.running = true;
        }
    }

    ColumnLayout {
        id: sessionsColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            MaterialSymbol {
                text: "terminal"
                iconSize: Appearance.font.pixelSize.normal
                color: Appearance.colors.colOnLayer1
            }
            StyledText {
                text: Translation.tr("Active sessions")
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
            }
            Item {
                Layout.fillWidth: true
            }
            StyledText {
                text: root.sessions.length
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colSubtext
            }
        }

        StyledText {
            visible: root.sessions.length === 0
            text: Translation.tr("No active sessions")
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colSubtext
        }

        Repeater {
            model: root.sessions

            RowLayout {
                id: sessionRow
                required property string modelData
                readonly property var parts: modelData.split("\t")
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    text: sessionRow.parts[0] ?? ""
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer1
                }
                StyledText {
                    Layout.fillWidth: true
                    text: (sessionRow.parts[2] ?? "").split("/").slice(-2).join("/")
                    elide: Text.ElideLeft
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colSubtext
                }
                StyledText {
                    text: root.formatElapsed(sessionRow.parts[1])
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}
