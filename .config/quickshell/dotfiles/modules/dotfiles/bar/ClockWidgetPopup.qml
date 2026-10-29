import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    property string formattedDate: Qt.locale().toString(DateTime.clock.date, "dddd, MMMM dd, yyyy")

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        spacing: 4

        StyledPopupHeaderRow {
            icon: "calendar_month"
            label: root.formattedDate
        }
    }
}
