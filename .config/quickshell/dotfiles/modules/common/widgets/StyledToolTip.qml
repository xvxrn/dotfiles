import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Tooltips are disabled shell-wide: this desktop shows no hover text.
ToolTip {
    id: root
    // Kept so existing call sites keep loading; both are intentionally unused.
    property bool extraVisibleCondition: true
    property bool alternativeVisibleCondition: false

    visible: false
    background: null
}
