pragma ComponentBehavior: Bound
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.modules.dotfiles.overlay.crosshair
import qs.modules.dotfiles.overlay.volumeMixer
import qs.modules.dotfiles.overlay.floatingImage
import qs.modules.dotfiles.overlay.fpsLimiter
import qs.modules.dotfiles.overlay.recorder
import qs.modules.dotfiles.overlay.resources

DelegateChooser {
    id: root
    role: "identifier"

    DelegateChoice { roleValue: "crosshair"; Crosshair {} }
    DelegateChoice { roleValue: "floatingImage"; FloatingImage {} }
    DelegateChoice { roleValue: "fpsLimiter"; FpsLimiter {} }
    DelegateChoice { roleValue: "recorder"; Recorder {} }
    DelegateChoice { roleValue: "resources"; Resources {} }
    DelegateChoice { roleValue: "volumeMixer"; VolumeMixer {} }
}
