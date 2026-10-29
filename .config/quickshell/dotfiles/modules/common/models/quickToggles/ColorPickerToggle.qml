import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.tr("Color picker")
    hasStatusText: false
    toggled: false
    icon: "colorize"

    mainAction: () => {
        GlobalStates.sidebarRightOpen = false;
        // Closing the sidebar destroys this component, so the delay has to live in the detached
        // process. It also stops the picker from sampling the panel itself.
        // -a copies the picked colour; no -n, the notification is unwanted.
        Quickshell.execDetached(["bash", "-c", "sleep 0.35; hyprpicker -a"]);
    }

    tooltipText: Translation.tr("Color picker")
}
