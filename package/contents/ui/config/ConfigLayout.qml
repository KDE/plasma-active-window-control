import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import QtQuick.Dialogs 1.2
import "../code/profiles.js" as Profiles

Item {
    id: configLayout

    property string cfg_controlPartOrder
    property alias cfg_controlPartSpacing: controlPartSpacing.value
    property alias cfg_useUpWidthItem: useUpWidthItem.currentIndex

    // GENERATED config (start)
    property alias cfg_controlPartIconShowOnMouseIn: controlPartIconShowOnMouseIn.checked
    property alias cfg_controlPartIconShowOnMouseOut: controlPartIconShowOnMouseOut.checked
    property alias cfg_controlPartIconPosition: controlPartIconPosition.currentIndex
    property alias cfg_controlPartIconHorizontalAlignment: controlPartIconHorizontalAlignment.currentIndex

    property alias cfg_controlPartTitleShowOnMouseIn: controlPartTitleShowOnMouseIn.checked
    property alias cfg_controlPartTitleShowOnMouseOut: controlPartTitleShowOnMouseOut.checked
    property alias cfg_controlPartTitlePosition: controlPartTitlePosition.currentIndex
    property alias cfg_controlPartTitleHorizontalAlignment: controlPartTitleHorizontalAlignment.currentIndex

    property alias cfg_controlPartButtonsShowOnMouseIn: controlPartButtonsShowOnMouseIn.checked
    property alias cfg_controlPartButtonsShowOnMouseOut: controlPartButtonsShowOnMouseOut.checked
    property alias cfg_controlPartButtonsPosition: controlPartButtonsPosition.currentIndex
    property alias cfg_controlPartButtonsHorizontalAlignment: controlPartButtonsHorizontalAlignment.currentIndex

    property alias cfg_controlPartMenuShowOnMouseIn: controlPartMenuShowOnMouseIn.checked
    property alias cfg_controlPartMenuShowOnMouseOut: controlPartMenuShowOnMouseOut.checked
    property alias cfg_controlPartMenuPosition: controlPartMenuPosition.currentIndex
    property alias cfg_controlPartMenuHorizontalAlignment: controlPartMenuHorizontalAlignment.currentIndex
    // GENERATED config (end)

    property alias cfg_controlPartMouseAreaRestrictedToWidget: controlPartMouseAreaRestrictedToWidget.checked

    property alias cfg_autoFillWidth: autoFillWidth.checked
    property alias cfg_horizontalScreenWidthPercent: horizontalScreenWidthPercent.value
    property alias cfg_widthFineTuning: widthFineTuning.value

    // properties from other config pages
    // we need them here to be able to apply profiles from this config page
    property bool cfg_textFontBold
    property string cfg_buttonOrder
    property bool cfg_showMaximize
    property bool cfg_showMinimize
    property bool cfg_showPinToAllDesktops
    property bool cfg_showButtonOnlyWhenMaximized
    property double cfg_controlButtonsSpacing
    property double cfg_buttonSize
    property int cfg_buttonsVerticalPosition
    property bool cfg_appmenuFontBold
    property bool cfg_appmenuSeparatorEnabled
    property int cfg_appmenuVerticalPosition

    ListModel {
        id: partsToSpend
        ListElement {
            name: 'icon'
            text: 'Icon'
        }
        ListElement {
            name: 'title'
            text: 'Title'
        }
        ListElement {
            name: 'buttons'
            text: 'Buttons'
        }
        ListElement {
            name: 'menu'
            text: 'Menu'
        }
    }

    function sortPartOrder() {
        buttonOrder.model.clear()
        cfg_controlPartOrder.split('|').forEach(function (itemId, index) {
            var partIndex = -1
            print('adding ' + itemId);
            if (itemId === 'icon') {
                partIndex = 0
            } else if (itemId === 'title') {
                partIndex = 1
            } else if (itemId === 'buttons') {
                partIndex = 2
            } else if (itemId === 'menu') {
                partIndex = 3
            }
            if (partIndex >= 0) {
                buttonOrder.model.append(partsToSpend.get(partIndex));
            }
        });
        print('model count: ' + buttonOrder.model.count)
    }

    function applyJsonProfile(jsonConfig) {
        for (var key in jsonConfig) {
            var configPropName = 'cfg_' + key
            if (configPropName in configLayout) {
                configLayout[configPropName] = jsonConfig[key]
            }
        }
    }

    onCfg_controlPartOrderChanged: sortPartOrder()

    GridLayout {
        columns: 3

        Label {
            text: i18n('Plasmoid version: ') + '1.8.0-git'
            Layout.alignment: Qt.AlignRight
            Layout.columnSpan: 3
        }

        Label {
            text: i18n('Configuration profiles:')
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        }
        Row {
            Layout.columnSpan: 2
            ComboBox {
                id: profilesCombo
                model: []
                onCurrentIndexChanged: {
                    if (currentIndex < 1) {
                        return
                    }
                    var item = Profiles.ITEMS[currentIndex - 1]
                    print('setting profile: ' + item.title)
                    applyJsonProfile(item.configuration)
                }
            }
            Button {
                iconName: 'exchange-positions'
                text: i18n('Load / Download')
                height: profilesCombo.height
                onClicked: {
                    var resultJson = {}
                    for (var key in configLayout) {
                        if (key.indexOf('cfg_') === 0) {
                            var propName = key.substring(4)
                            resultJson[propName] = configLayout[key]
                        }
                    }
                    var resultString = JSON.stringify(resultJson, null, 4)

                    applyCustomProfile.open()
                    customProfileTextarea.text = resultString
                    customProfileTextarea.focus = true
                }
            }
        }

        Item {
            width: 2
            height: units.largeSpacing
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Item order:")
        }

        OrderableListView {
            id: buttonOrder
            Layout.columnSpan: 2
            itemHeight: units.gridUnit * 2
            itemWidth: units.gridUnit * 4
            height: itemHeight
            width: itemWidth * 4
            model: ListModel {
                // will be filled initially by sortButtonOrder() method
            }
            orientation: ListView.Horizontal

            onModelOrderChanged: {
                var orderStr = '';
                for (var i = 0; i < model.count; i++) {
                    var item = model.get(i)
                    if (orderStr.length > 0) {
                        orderStr += '|';
                    }
                    orderStr += item.name;
                }
                cfg_controlPartOrder = orderStr;
                print('written: ' + cfg_controlPartOrder);
            }
        }

        Label {
            text: i18n("Item spacing:")
        }
        SpinBox {
            id: controlPartSpacing
            decimals: 1
            stepSize: 0.5
            minimumValue: 0.5
            maximumValue: 300
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('Item to use up remaining width:')
        }
        ComboBox {
            id: useUpWidthItem
            model: [i18n('Title'), i18n('Menu'), i18n('None')]
            Layout.columnSpan: 2
        }

        // GENERATED controls (start)
        GridLayout {
            columns: 2

            Item {
                width: 2
                height: units.largeSpacing
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Icon')
                font.bold: true
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Show:')
                Layout.alignment: Qt.AlignRight
            }
            CheckBox {
                id: controlPartIconShowOnMouseIn
                text: i18n('On mouse in')
            }
            Item {
                width: 2
                height: 2
            }
            CheckBox {
                id: controlPartIconShowOnMouseOut
                text: i18n('On mouse out')
            }

            Label {
                text: i18n('Position:')
                Layout.alignment: Qt.AlignRight
                enabled: controlPartIconPosition.enabled
            }
            ComboBox {
                id: controlPartIconPosition
                model: [i18n('Occupy'), i18n('Floating layer'), i18n('Absolute')]
                enabled: controlPartIconShowOnMouseIn.checked || controlPartIconShowOnMouseOut.checked
            }

            Label {
                text: i18n('Align:')
                Layout.alignment: Qt.AlignRight
                enabled: controlPartIconPosition.enabled
            }
            ComboBox {
                id: controlPartIconHorizontalAlignment
                model: [i18n('Left'), i18n('Right')]
                enabled: controlPartIconPosition.enabled
            }


            Item {
                width: 2
                height: units.largeSpacing
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Buttons')
                font.bold: true
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Show:')
                Layout.alignment: Qt.AlignRight
            }
            CheckBox {
                id: controlPartButtonsShowOnMouseIn
                text: i18n('On mouse in')
            }
            Item {
                width: 2
                height: 2
            }
            CheckBox {
                id: controlPartButtonsShowOnMouseOut
                text: i18n('On mouse out')
            }

            Label {
                text: i18n('Position:')
                Layout.alignment: Qt.AlignRight
                enabled: controlPartButtonsPosition.enabled
            }
            ComboBox {
                id: controlPartButtonsPosition
                model: [i18n('Occupy'), i18n('Floating layer'), i18n('Absolute')]
                enabled: controlPartButtonsShowOnMouseIn.checked || controlPartButtonsShowOnMouseOut.checked
            }

            Label {
                text: i18n('Align:')
                Layout.alignment: Qt.AlignRight
                enabled: controlPartButtonsPosition.enabled
            }
            ComboBox {
                id: controlPartButtonsHorizontalAlignment
                model: [i18n('Left'), i18n('Right')]
                enabled: controlPartButtonsPosition.enabled
            }
        }

        Item {
            width: units.largeSpacing
            height: units.largeSpacing
        }

        GridLayout {
            columns: 2

            Item {
                width: 2
                height: units.largeSpacing
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Title')
                font.bold: true
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Show:')
                Layout.alignment: Qt.AlignRight
            }
            CheckBox {
                id: controlPartTitleShowOnMouseIn
                text: i18n('On mouse in')
            }
            Item {
                width: 2
                height: 2
            }
            CheckBox {
                id: controlPartTitleShowOnMouseOut
                text: i18n('On mouse out')
            }

            Label {
                text: i18n('Position:')
                Layout.alignment: Qt.AlignRight
                enabled: controlPartTitlePosition.enabled
            }
            ComboBox {
                id: controlPartTitlePosition
                model: [i18n('Occupy'), i18n('Floating layer'), i18n('Absolute')]
                enabled: controlPartTitleShowOnMouseIn.checked || controlPartTitleShowOnMouseOut.checked
            }

            Label {
                text: i18n('Align:')
                Layout.alignment: Qt.AlignRight
                enabled: controlPartTitlePosition.enabled
            }
            ComboBox {
                id: controlPartTitleHorizontalAlignment
                model: [i18n('Left'), i18n('Right')]
                enabled: controlPartTitlePosition.enabled
            }


            Item {
                width: 2
                height: units.largeSpacing
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Menu')
                font.bold: true
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Show:')
                Layout.alignment: Qt.AlignRight
            }
            CheckBox {
                id: controlPartMenuShowOnMouseIn
                text: i18n('On mouse in')
            }
            Item {
                width: 2
                height: 2
            }
            CheckBox {
                id: controlPartMenuShowOnMouseOut
                text: i18n('On mouse out')
            }

            Label {
                text: i18n('Position:')
                Layout.alignment: Qt.AlignRight
                enabled: controlPartMenuPosition.enabled
            }
            ComboBox {
                id: controlPartMenuPosition
                model: [i18n('Occupy'), i18n('Floating layer'), i18n('Absolute')]
                enabled: controlPartMenuShowOnMouseIn.checked || controlPartMenuShowOnMouseOut.checked
            }

            Label {
                text: i18n('Align:')
                Layout.alignment: Qt.AlignRight
                enabled: controlPartMenuPosition.enabled
            }
            ComboBox {
                id: controlPartMenuHorizontalAlignment
                model: [i18n('Left'), i18n('Right')]
                enabled: controlPartMenuPosition.enabled
            }
        }
        // GENERATED controls (end)

        Item {
            width: units.largeSpacing
            height: units.largeSpacing
            Layout.columnSpan: 3
        }

        CheckBox {
            id: controlPartMouseAreaRestrictedToWidget
            text: i18n('Restrict mouse area to widget')
            Layout.columnSpan: 3
        }

        Item {
            width: units.largeSpacing
            height: units.largeSpacing
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Width in horizontal panel:")
            font.bold: true
            Layout.alignment: Qt.AlignLeft
            Layout.columnSpan: 3
        }

        CheckBox {
            id: autoFillWidth
            text: i18n("Fill width")
            Layout.columnSpan: 3
        }

        GridLayout {
            columns: 2
            Layout.columnSpan: 3
            enabled: !autoFillWidth.checked

            Slider {
                id: horizontalScreenWidthPercent
                stepSize: 0.001
                minimumValue: 0.001
                maximumValue: 1
                Layout.preferredWidth: configLayout.width
                Layout.columnSpan: 2
            }

            Label {
                text: i18n("Fine tuning:")
                Layout.alignment: Qt.AlignRight
            }
            SpinBox {
                id: widthFineTuning
                decimals: 1
                stepSize: 0.5
                minimumValue: -100
                maximumValue: 100
            }
        }

    }

    Dialog {
        id: applyCustomProfile
        title: i18n('Apply Custom Profile from JSON String')

        width: 500
        height: 300

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted: {
            profilesCombo.currentIndex = 0

            var jsonString = customProfileTextarea.text
            console.log('profileJsonString: ' + jsonString)

            var jsonConfig = JSON.parse(jsonString)
            applyJsonProfile(jsonConfig)

            close()
        }

        TextArea {
            id: customProfileTextarea
            anchors.fill: parent
        }
    }

    Component.onCompleted: {
        sortPartOrder()
        var profileNames = [i18n('Custom')]
        Profiles.ITEMS.forEach(function (item) {
            print('profile: ' + item.title)
            profileNames.push(item.title)
        })
        profilesCombo.model = profileNames
    }

}
