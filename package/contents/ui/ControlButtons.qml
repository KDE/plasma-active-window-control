import QtQuick 2.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: controlButtons

    property bool mouseInWidget: false

    property double controlButtonsHeight: parent.height * plasmoid.configuration.buttonSize
    property bool showItem

    property bool automaticButtonThemeEnabled: plasmoid.configuration.automaticButtonThemeEnabled
    property string manualAuroraeThemePath: plasmoid.configuration.customAuroraeThemePath
    property string manualAuroraeThemePathResolved: ''
    property string manualAuroraeThemeExtension: 'svg'

    property bool showMinimize: plasmoid.configuration.showMinimize
    property bool showMaximize: plasmoid.configuration.showMaximize
    property bool showPinToAllDesktops: plasmoid.configuration.showPinToAllDesktops

    property string buttonOrder: plasmoid.configuration.buttonOrder

    property bool canShowButtonsAccordingMaximized: plasmoid.configuration.showButtonOnlyWhenMaximized ? main.currentWindowMaximized : true

    property int buttonsVerticalPosition: plasmoid.configuration.buttonsVerticalPosition;
    property double controlButtonsSpacing: plasmoid.configuration.controlButtonsSpacing;

    opacity: (showItem && canShowButtonsAccordingMaximized) ? 1 : 0

    // we want to trigger a button even if mouse is in the plasmoid area edge
    height: buttonsVerticalPosition === 1 ? parent.height : controlButtonsHeight
    width: controlButtonsHeight + ((controlButtonsModel.count - 1) * (controlButtonsHeight + controlButtonsSpacing))

    onButtonsVerticalPositionChanged: {
        anchors.top = undefined
        anchors.verticalCenter = undefined
        anchors.bottom = undefined
        if (buttonsVerticalPosition === 0) {
            anchors.top = parent.top
        } else if (buttonsVerticalPosition === 1) {
            anchors.verticalCenter = parent.verticalCenter
        } else if (buttonsVerticalPosition === 2) {
            anchors.bottom = parent.bottom
        }
    }

    onManualAuroraeThemePathChanged: {
        manualAuroraeThemeExtension = plasmoid.nativeInterface.extensionForTheme(manualAuroraeThemePath);
        manualAuroraeThemePathResolved = plasmoid.nativeInterface.translateThemePath(manualAuroraeThemePath);
        print('manualAuroraeThemePath=' + manualAuroraeThemePath)
        print('manualAuroraeThemePathResolved=' + manualAuroraeThemePathResolved)
        print('manualAuroraeThemeExtension=' + manualAuroraeThemeExtension)
    }

    onShowMaximizeChanged: initializeControlButtonsModel()
    onShowMinimizeChanged: initializeControlButtonsModel()
    onShowPinToAllDesktopsChanged: initializeControlButtonsModel()
    onButtonOrderChanged: initializeControlButtonsModel()

    function addButton(preparedArray, buttonName) {
        if (buttonName === 'close') {
            preparedArray.push({
                iconName: 'close',
                windowOperation: 'close'
            });
        } else if (buttonName === 'maximize' && showMaximize) {
            preparedArray.push({
                iconName: 'maximize',
                windowOperation: 'toggleMaximized'
            });
        } else if (buttonName === 'minimize' && showMinimize) {
            preparedArray.push({
                iconName: 'minimize',
                windowOperation: 'toggleMinimized'
            });
        } else if ((buttonName === 'pin' || buttonName === 'alldesktops') && showPinToAllDesktops) {
            preparedArray.push({
                iconName: 'alldesktops',
                windowOperation: 'togglePinToAllDesktops'
            });
        }
    }

    function initializeControlButtonsModel() {

        var preparedArray = []
        buttonOrder.split('|').forEach(function (buttonName) {
            addButton(preparedArray, buttonName);
        });

        controlButtonsModel.clear()

        preparedArray.forEach(function (item) {
            print('adding item to buttons: ' + item.iconName);
            controlButtonsModel.append(item);
        });
    }

    function performActiveWindowAction(windowOperation) {
        if (!mouseInWidget) {
            return;
        }
        if (windowOperation === 'close') {
            main.toggleClose()
        } else if (windowOperation === 'toggleMaximized') {
            main.toggleMaximized()
        } else if (windowOperation === 'toggleMinimized') {
            main.toggleMinimized()
        } else if (windowOperation === 'togglePinToAllDesktops') {
            main.togglePinToAllDesktops()
        }
    }

    ListModel {
        id: controlButtonsModel
    }

    ListView {

        orientation: ListView.Horizontal

        spacing: controlButtonsSpacing

        visible: true

        model: controlButtonsModel

        anchors.fill: parent

        delegate: ControlButton { }

    }

    Component.onCompleted: {
        initializeControlButtonsModel()
    }
}

