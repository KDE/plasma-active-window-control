import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQml.Models 2.1

Item {

    property string cfg_controlPartOrder
    property alias cfg_controlPartSpacing: controlPartSpacing.value

    // GENERATED config (start)
    property alias cfg_controlPartButtonsPosition: controlPartButtonsPosition.currentIndex
    property alias cfg_controlPartButtonsShowOnMouseIn: controlPartButtonsShowOnMouseIn.checked
    property alias cfg_controlPartButtonsShowOnMouseOut: controlPartButtonsShowOnMouseOut.checked
    property alias cfg_controlPartButtonsHorizontalAlignment: controlPartButtonsHorizontalAlignment.currentIndex

    property alias cfg_controlPartIconPosition: controlPartIconPosition.currentIndex
    property alias cfg_controlPartIconShowOnMouseIn: controlPartIconShowOnMouseIn.checked
    property alias cfg_controlPartIconShowOnMouseOut: controlPartIconShowOnMouseOut.checked
    property alias cfg_controlPartIconHorizontalAlignment: controlPartIconHorizontalAlignment.currentIndex

    property alias cfg_controlPartTitlePosition: controlPartTitlePosition.currentIndex
    property alias cfg_controlPartTitleShowOnMouseIn: controlPartTitleShowOnMouseIn.checked
    property alias cfg_controlPartTitleShowOnMouseOut: controlPartTitleShowOnMouseOut.checked
    property alias cfg_controlPartTitleHorizontalAlignment: controlPartTitleHorizontalAlignment.currentIndex

    property alias cfg_controlPartMenuPosition: controlPartMenuPosition.currentIndex
    property alias cfg_controlPartMenuShowOnMouseIn: controlPartMenuShowOnMouseIn.checked
    property alias cfg_controlPartMenuShowOnMouseOut: controlPartMenuShowOnMouseOut.checked
    property alias cfg_controlPartMenuHorizontalAlignment: controlPartMenuHorizontalAlignment.currentIndex
    // GENERATED config (end)

    property alias cfg_controlPartMouseAreaRestrictedToWidget: controlPartMouseAreaRestrictedToWidget.checked

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

    GridLayout {
        columns: 3

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

        // GENERATED controls (start)
        GridLayout {
            columns: 2

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
                text: i18n('Position:')
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            ComboBox {
                id: controlPartButtonsPosition
                model: [i18n('Occupy'), i18n('Floating layer'), i18n('Absolute')]
            }

            CheckBox {
                id: controlPartButtonsShowOnMouseIn
                text: i18n('Show on mouse in')
                Layout.columnSpan: 2
            }

            CheckBox {
                id: controlPartButtonsShowOnMouseOut
                text: i18n('Show on mouse out')
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Horizontal alignment:')
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            ComboBox {
                id: controlPartButtonsHorizontalAlignment
                model: [i18n('Left'), i18n('Right')]
            }


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
                text: i18n('Position:')
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            ComboBox {
                id: controlPartIconPosition
                model: [i18n('Occupy'), i18n('Floating layer'), i18n('Absolute')]
            }

            CheckBox {
                id: controlPartIconShowOnMouseIn
                text: i18n('Show on mouse in')
                Layout.columnSpan: 2
            }

            CheckBox {
                id: controlPartIconShowOnMouseOut
                text: i18n('Show on mouse out')
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Horizontal alignment:')
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            ComboBox {
                id: controlPartIconHorizontalAlignment
                model: [i18n('Left'), i18n('Right')]
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
                text: i18n('Position:')
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            ComboBox {
                id: controlPartTitlePosition
                model: [i18n('Occupy'), i18n('Floating layer'), i18n('Absolute')]
            }

            CheckBox {
                id: controlPartTitleShowOnMouseIn
                text: i18n('Show on mouse in')
                Layout.columnSpan: 2
            }

            CheckBox {
                id: controlPartTitleShowOnMouseOut
                text: i18n('Show on mouse out')
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Horizontal alignment:')
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            ComboBox {
                id: controlPartTitleHorizontalAlignment
                model: [i18n('Left'), i18n('Right')]
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
                text: i18n('Position:')
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            ComboBox {
                id: controlPartMenuPosition
                model: [i18n('Occupy'), i18n('Floating layer'), i18n('Absolute')]
            }

            CheckBox {
                id: controlPartMenuShowOnMouseIn
                text: i18n('Show on mouse in')
                Layout.columnSpan: 2
            }

            CheckBox {
                id: controlPartMenuShowOnMouseOut
                text: i18n('Show on mouse out')
                Layout.columnSpan: 2
            }

            Label {
                text: i18n('Horizontal alignment:')
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            ComboBox {
                id: controlPartMenuHorizontalAlignment
                model: [i18n('Left'), i18n('Right')]
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
            Layout.columnSpan: 2
        }

    }

    Component.onCompleted: {
        sortPartOrder()
    }

}