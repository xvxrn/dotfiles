import QtQuick
import Quickshell

import qs.modules.common

LazyLoader {
    property bool when: true
    property bool extraCondition: true
    active: Config.ready && when && extraCondition
}
