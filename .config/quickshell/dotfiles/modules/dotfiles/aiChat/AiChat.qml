pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

// Right-hand panel, same surface and appearance animation as the quick settings sidebar.
PanelWindow {
    id: root
    visible: content.opacity > 0.01
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Appearance.sizes.sidebarWidth
    WlrLayershell.namespace: "quickshell:aiChat"
    WlrLayershell.keyboardFocus: GlobalStates.aiChatOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        top: true
        right: true
        bottom: true
    }

    onVisibleChanged: {
        if (visible) {
            GlobalFocusGrab.addDismissable(root);
            Qt.callLater(() => inputField.forceActiveFocus());
        } else {
            GlobalFocusGrab.removeDismissable(root);
        }
    }
    Connections {
        target: GlobalFocusGrab
        function onDismissed() {
            GlobalStates.aiChatOpen = false;
        }
    }

    property var messages: []
    property bool running: false
    property string sessionId: ""
    property string selectedModel: ""
    property string effort: "medium"
    readonly property var harnesses: [
        { name: "codex", label: "Codex", icon: "codex-symbolic.svg" },
        { name: "claude", label: "Claude", icon: "claude-symbolic.svg" },
        { name: "opencode", label: "OpenCode", icon: "opencode-symbolic.svg" }
    ]
    readonly property var efforts: [
        { name: "low", label: Translation.tr("Low") },
        { name: "medium", label: Translation.tr("Medium") },
        { name: "high", label: Translation.tr("High") }
    ]

    readonly property string harness: Config.options.ai.harness
    readonly property var models: harness === "codex" ? Config.options.ai.codexModels
        : harness === "claude" ? Config.options.ai.claudeModels
        : Config.options.ai.opencodeModels
    readonly property string model: selectedModel.length > 0 ? selectedModel : (models.length > 0 ? models[0] : "")

    function shortName(name) {
        const parts = name.split("/");
        return parts[parts.length - 1];
    }

    function newChat() {
        chatProcess.running = false;
        root.running = false;
        root.messages = [];
        root.sessionId = "";
    }

    function send(text) {
        text = (text ?? "").trim();
        if (text.length === 0 || root.running)
            return;
        root.messages = root.messages.concat([ { role: "user", text: text }, { role: "assistant", text: "" } ]);
        inputField.text = "";
        chatProcess.command = [
            "bash", `${FileUtils.trimFileProtocol(Directories.scriptPath)}/ai/chat.sh`,
            root.harness, root.model, root.effort, root.sessionId,
            FileUtils.trimFileProtocol(Config.options.ai.cwd), text
        ];
        chatProcess.running = true;
    }

    function appendAssistant(chunk) {
        const copy = root.messages.slice();
        const last = copy[copy.length - 1];
        if (!last || last.role !== "assistant")
            return;
        copy[copy.length - 1] = { role: "assistant", text: last.text + chunk };
        root.messages = copy;
    }

    onHarnessChanged: {
        root.selectedModel = "";
        root.sessionId = "";
        root.messages = [];
    }

    Process {
        id: chatProcess
        stdout: SplitParser {
            onRead: line => {
                let event;
                try { event = JSON.parse(line); } catch (e) { return; }
                if (event.type === "session") {
                    if (event.id)
                        root.sessionId = event.id;
                } else if (event.type === "text") {
                    if (event.id)
                        root.sessionId = event.id;
                    root.appendAssistant(event.text ?? "");
                } else if (event.type === "tool") {
                    root.appendAssistant(`\n> ${event.text}\n`);
                } else if (event.type === "error") {
                    root.appendAssistant(`\n${Translation.tr("Error")}: ${event.text}\n`);
                }
            }
        }
        onStarted: root.running = true
        onExited: root.running = false
    }

    IpcHandler {
        target: "aiChat"

        function toggle(): void {
            GlobalStates.aiChatOpen = !GlobalStates.aiChatOpen;
        }

        function close(): void {
            GlobalStates.aiChatOpen = false;
        }

        function open(): void {
            GlobalStates.aiChatOpen = true;
        }
    }

    component IconButton: RippleButton {
        id: button
        property string iconName
        implicitWidth: 34
        implicitHeight: 34
        buttonRadius: Appearance.rounding.full
        colBackground: "transparent"
        colBackgroundHover: Appearance.colors.colLayer2Hover
        contentItem: MaterialSymbol {
            anchors.centerIn: parent
            text: button.iconName
            iconSize: 20
            color: Appearance.colors.colOnLayer0
        }
    }

    StyledRectangularShadow {
        target: background
    }
    Rectangle {
        id: background
        anchors {
            fill: parent
            margins: Appearance.sizes.hyprlandGapsOut
            leftMargin: Appearance.sizes.hyprlandGapsOut + Appearance.sizes.elevationMargin
        }
        color: Appearance.colors.colLayer0
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1
    }

    ColumnLayout {
        id: content
        anchors {
            fill: background
            margins: 10
        }
        spacing: 10
        opacity: GlobalStates.aiChatOpen ? 1 : 0
        scale: GlobalStates.aiChatOpen ? 1 : 0.96
        transformOrigin: Item.Top
        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.animation.elementMoveFast.duration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Appearance.animation.elementMoveFast.duration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                GlobalStates.aiChatOpen = false;
                event.accepted = true;
            }
        }

        RowLayout { // Title bar
            Layout.fillWidth: true
            Layout.topMargin: 5
            spacing: 4

            MaterialSymbol {
                text: "auto_awesome"
                iconSize: 18
                fill: 1
                color: Appearance.colors.colPrimary
            }
            StyledText {
                Layout.leftMargin: 2
                Layout.fillWidth: true
                text: Translation.tr("Assistant")
                font {
                    pixelSize: Appearance.font.pixelSize.normal
                    weight: Font.DemiBold
                }
            }
            IconButton {
                iconName: "add_comment"
                onClicked: root.newChat()
            }
            IconButton {
                iconName: "close"
                onClicked: GlobalStates.aiChatOpen = false
            }
        }

        Flow { // Harness: selection buttons, not a dropdown
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.harnesses

                AiChoiceButton {
                    required property var modelData
                    label: modelData.label
                    iconName: modelData.icon
                    toggled: root.harness === modelData.name
                    onClicked: Config.options.ai.harness = modelData.name
                }
            }
        }

        Flow { // Reasoning effort, codex only
            Layout.fillWidth: true
            spacing: 6
            visible: root.harness === "codex"

            Repeater {
                model: root.efforts

                AiChoiceButton {
                    required property var modelData
                    label: modelData.label
                    toggled: root.effort === modelData.name
                    onClicked: root.effort = modelData.name
                }
            }
        }

        Flow { // Models from the config, only these are offered
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.models

                AiChoiceButton {
                    required property string modelData
                    label: root.shortName(modelData)
                    toggled: root.model === modelData
                    onClicked: root.selectedModel = modelData
                }
            }
        }

        Item { // Conversation
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent
                spacing: 6
                visible: root.messages.length === 0

                MaterialSymbol {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "auto_awesome"
                    iconSize: 28
                    color: Appearance.colors.colSubtext
                }
                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Translation.tr("Ask anything")
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Translation.tr("Codex, Claude or OpenCode")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            ListView {
                id: messageList
                anchors.fill: parent
                visible: root.messages.length > 0
                clip: true
                spacing: 10
                model: root.messages
                onContentHeightChanged: if (contentHeight > height) positionViewAtEnd()

                delegate: Item {
                    id: messageItem
                    required property var modelData
                    width: ListView.view.width
                    implicitHeight: bubble.visible ? bubble.height : assistantText.implicitHeight

                    Rectangle {
                        id: bubble
                        visible: messageItem.modelData.role === "user"
                        anchors.right: parent.right
                        width: Math.min(userText.implicitWidth + 20, messageItem.width * 0.85)
                        height: userText.height + 14
                        radius: Appearance.rounding.normal
                        color: Appearance.colors.colSecondaryContainer

                        StyledText {
                            id: userText
                            anchors.centerIn: parent
                            width: parent.width - 20
                            text: messageItem.modelData.text
                            wrapMode: Text.Wrap
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnSecondaryContainer
                        }
                    }

                    StyledText {
                        id: assistantText
                        visible: messageItem.modelData.role !== "user"
                        width: parent.width
                        text: messageItem.modelData.text.length > 0 ? messageItem.modelData.text : (root.running ? "…" : "")
                        textFormat: Text.MarkdownText
                        wrapMode: Text.Wrap
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }
        }

        RowLayout { // Input
            Layout.fillWidth: true
            spacing: 6

            ToolbarTextField {
                id: inputField
                Layout.fillWidth: true
                Layout.fillHeight: false
                implicitHeight: 40
                colBackground: Appearance.colors.colLayer2
                placeholderText: root.running ? Translation.tr("Thinking…") : Translation.tr("Ask %1").arg(root.harness)
                enabled: !root.running
                onAccepted: root.send(text)
            }

            RippleButton {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 40
                implicitHeight: 40
                buttonRadius: Appearance.rounding.full
                colBackground: Appearance.colors.colLayer3
                colBackgroundHover: Appearance.colors.colLayer3Hover
                enabled: !root.running
                onClicked: root.send(inputField.text)

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: root.running ? "hourglass" : "send"
                    iconSize: 18
                    color: root.running ? Appearance.colors.colSubtext : Appearance.colors.colPrimary
                }
            }
        }
    }
}
