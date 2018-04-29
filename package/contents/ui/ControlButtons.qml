import QtQuick 2.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: controlButtons

    property bool mouseInWidget: false
    property var controlButtonsModel

    property double controlButtonsHeight: parent.height * plasmoid.configuration.buttonSize
    property bool showItem

    opacity: showItem ? 1 : 0

    height: main.buttonsVerticalCenter ? parent.height : controlButtonsHeight
    width: controlButtonsHeight + ((model.count - 1) * (controlButtonsHeight + main.controlButtonsSpacing))

    ListView {

        orientation: ListView.Horizontal

        spacing: main.controlButtonsSpacing

        visible: true

        model: controlButtonsModel

        anchors.fill: parent

        delegate: ControlButton { }

    }
}

