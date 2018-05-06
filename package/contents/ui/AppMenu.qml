import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
    id: appmenu

    property bool mouseInWidget: appmenuOpened || appmenu.containsMouse

    property bool appmenuEnabled: plasmoid.configuration.controlPartMenuShowOnMouseIn || plasmoid.configuration.controlPartMenuShowOnMouseOut
    property bool appmenuFillHeight: plasmoid.configuration.appmenuFillHeight
    property bool appmenuFontBold: plasmoid.configuration.appmenuFontBold
    property bool appmenuEnabledAndNonEmpty: appmenuEnabled && appMenuModel !== null && appMenuModel.menuAvailable
    property bool appmenuOpened: appmenuEnabled && plasmoid.nativeInterface.currentIndex > -1
    property var appMenuModel: null

    visible: appmenuEnabledAndNonEmpty && !main.noWindowActive

    property bool showItem
    property double recommendedWidth

    opacity: showItem ? 1 : 0

    width: recommendedWidth

    hoverEnabled: true

    GridLayout {
        id: buttonGrid

        Layout.minimumWidth: implicitWidth
        Layout.minimumHeight: implicitHeight

        flow: GridLayout.LeftToRight
        rowSpacing: 0
        columnSpacing: 0

        anchors.top: parent.top
        anchors.left: parent.left

        Component.onCompleted: {
            plasmoid.nativeInterface.buttonGrid = buttonGrid
            plasmoid.nativeInterface.enabled = appmenuEnabled
        }

        Connections {
            target: plasmoid.nativeInterface
            onRequestActivateIndex: {
                var idx = Math.max(0, Math.min(buttonRepeater.count - 1, index))
                var button = buttonRepeater.itemAt(index)
                if (button) {
                    button.clicked(null)
                }
            }
        }

        Repeater {
            id: buttonRepeater
            model: null

            MouseArea {
                id: appmenuButton

                hoverEnabled: true

                readonly property int buttonIndex: index

                property bool menuOpened: plasmoid.nativeInterface.currentIndex === index

                Layout.preferredWidth: appmenuButtonBackground.width
                Layout.preferredHeight: appmenuButtonBackground.height

                Rectangle {
                    id: appmenuButtonBackground
                    border.color: 'transparent'
                    width: appmenuButtonTitle.implicitWidth + units.smallSpacing * 3
                    height: appmenuFillHeight ? appmenu.height : appmenuButtonTitle.implicitHeight + units.smallSpacing
                    color: menuOpened ? theme.highlightColor : 'transparent'
                    radius: units.smallSpacing / 2
                }

                PlasmaComponents.Label {
                    id: appmenuButtonTitle
                    anchors.top: appmenuButtonBackground.top
                    anchors.bottom: appmenuButtonBackground.bottom
                    verticalAlignment: Text.AlignVCenter
                    anchors.horizontalCenter: appmenuButtonBackground.horizontalCenter
                    font.pixelSize: main.fontPixelSize * plasmoid.configuration.appmenuButtonTextSizeScale
                    text: activeMenu.replace('&', '')
                    font.weight: appmenuFontBold ? Font.Bold : theme.defaultFont.weight
                }

                onClicked: {
                    plasmoid.nativeInterface.trigger(this, index)
                }

                onEntered: {
                    appmenuButtonBackground.border.color = theme.highlightColor
                }

                onExited: {
                    appmenuButtonBackground.border.color = 'transparent'
                }
            }
        }
    }

    function initializeAppModel() {
        if (appMenuModel !== null) {
            return
        }
        print('initializing appMenuModel...')
        try {
            appMenuModel = Qt.createQmlObject(
                'import QtQuick 2.2;\
                 import org.kde.plasma.plasmoid 2.0;\
                 import org.kde.private.activeWindowControl 1.0 as ActiveWindowControlPrivate;\
                 ActiveWindowControlPrivate.AppMenuModel {\
                     id: appMenuModel;\
                     Component.onCompleted: {\
                         plasmoid.nativeInterface.model = appMenuModel\
                     }\
                 }', main)
        } catch (e) {
            print('appMenuModel failed to initialize: ' + e)
        }
        print('initializing appmenu...DONE ' + appMenuModel)
        if (appMenuModel !== null) {
            resetAppmenuModel()
        }
    }

    function resetAppmenuModel() {
        if (appmenuEnabled) {
            initializeAppModel()
            if (appMenuModel === null) {
                return
            }
            print('setting model in QML: ' + appMenuModel)
            for (var key in appMenuModel) {
                print('  ' + key + ' -> ' + appMenuModel[key])
            }
            plasmoid.nativeInterface.model = appMenuModel
            buttonRepeater.model = appMenuModel
        } else {
            plasmoid.nativeInterface.model = null
            buttonRepeater.model = null
        }
    }

    onAppmenuEnabledChanged: {
        appmenu.resetAppmenuModel()
        if (appMenuModel !== null) {
            plasmoid.nativeInterface.enabled = appmenuEnabled
        }
    }

}