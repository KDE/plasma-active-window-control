import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQml.Models 2.1

Item {

    property string cfg_buttonOrder

    property alias cfg_showMinimize: showMinimize.checked
    property alias cfg_showMaximize: showMaximize.checked
    property alias cfg_showPinToAllDesktops: showPinToAllDesktops.checked

    property alias cfg_showButtonOnlyWhenMaximized: showButtonOnlyWhenMaximized.checked

    property alias cfg_buttonSize: buttonSize.value
    property int cfg_buttonsVerticalPosition
    property alias cfg_controlButtonsSpacing: controlButtonsSpacing.value

    property alias cfg_automaticButtonThemeEnabled: automaticButtonThemeEnabled.checked
    property alias cfg_customAuroraeThemePath: customAuroraeThemePath.text

    onCfg_buttonsVerticalPositionChanged: {
        switch (cfg_buttonsVerticalPosition) {
        case 0:
            buttonsVertialPositionGroup.current = topRadio;
            break;
        case 1:
            buttonsVertialPositionGroup.current = middleRadio;
            break;
        case 2:
            buttonsVertialPositionGroup.current = bottomRadio;
            break;
        default:
            buttonsVertialPositionGroup.current = topRadio;
        }
    }

    Component.onCompleted: {
        cfg_buttonsVerticalPositionChanged()
        print('intially calling sortButtonOrder()')
        sortButtonOrder()
    }

    ListModel {
        id: buttonsToSpend
        ListElement {
            name: 'close'
            iconName: 'close'
        }
        ListElement {
            name: 'minimize'
            iconName: 'minimize'
        }
        ListElement {
            name: 'maximize'
            iconName: 'maximize'
        }
        ListElement {
            name: 'alldesktops'
            iconName: 'alldesktops'
        }
    }

    function sortButtonOrder() {
        cfg_buttonOrder.split('|').forEach(function (itemId, index) {
            if (itemId === 'close') {
                print('adding ' + itemId);
                buttonOrder.model.insert(index, buttonsToSpend.get(0));
            } else if (itemId === 'minimize') {
                buttonOrder.model.insert(index, buttonsToSpend.get(1));
                print('adding ' + itemId);
            } else if (itemId === 'maximize') {
                buttonOrder.model.insert(index, buttonsToSpend.get(2));
                print('adding ' + itemId);
            } else if (itemId === 'pin' || itemId === 'alldesktops') {
                buttonOrder.model.insert(index, buttonsToSpend.get(3));
                print('adding ' + itemId);
            }
        });
    }

    ExclusiveGroup {
        id: buttonsVertialPositionGroup
    }

    GridLayout {
        columns: 2

        Label {
            text: i18n("Button order:")
            Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }

        OrderableListView {
            id: buttonOrder
            height: units.gridUnit * 2
            width: height * 4
            model: ListModel {
                // will be filled initially by sortButtonOrder() method
            }
            orientation: ListView.Horizontal
            itemWidth: width / 4
            itemHeight: itemWidth

            onModelOrderChanged: {
                var orderStr = '';
                for (var i = 0; i < model.count; i++) {
                    var item = model.get(i)
                    if (orderStr.length > 0) {
                        orderStr += '|';
                    }
                    orderStr += item.name;
                }
                cfg_buttonOrder = orderStr;
                print('written: ' + cfg_buttonOrder);
            }
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        Label {
            text: i18n("Show:")
            Layout.alignment: Qt.AlignRight
        }
        CheckBox {
            id: showMinimize
            text: i18n("Minimize button")
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 2
        }
        CheckBox {
            id: showMaximize
            text: i18n("Maximize button")
        }
        CheckBox {
            id: showPinToAllDesktops
            text: i18n("Pin to all desktops")
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        Label {
            text: i18n("Behaviour:")
            Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }

        CheckBox {
            id: showButtonOnlyWhenMaximized
            text: i18n("Show only when maximized")
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        Label {
            text: i18n("Buttons spacing:")
            Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }
        Slider {
            id: controlButtonsSpacing
            stepSize: 1
            minimumValue: 0
            maximumValue: 20
            tickmarksEnabled: true
            width: parent.width
        }

        Label {
            text: i18n("Button size:")
            Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }
        Slider {
            id: buttonSize
            stepSize: 0.1
            minimumValue: 0.1
            tickmarksEnabled: true
            width: parent.width
        }

        Label {
            text: i18n("Vertical position:")
            Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }
        RadioButton {
            id: topRadio
            exclusiveGroup: buttonsVertialPositionGroup
            text: i18n("Top")
            onCheckedChanged: if (checked) cfg_buttonsVerticalPosition = 0;
            enabled: buttonSize.value < 1
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 4
        }
        RadioButton {
            id: middleRadio
            exclusiveGroup: buttonsVertialPositionGroup
            text: i18n("Middle")
            onCheckedChanged: if (checked) cfg_buttonsVerticalPosition = 1;
            enabled: buttonSize.value < 1
        }
        RadioButton {
            id: bottomRadio
            exclusiveGroup: buttonsVertialPositionGroup
            text: i18n("Bottom")
            onCheckedChanged: if (checked) cfg_buttonsVerticalPosition = 2;
            enabled: buttonSize.value < 1
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        Label {
            text: i18n("Theme")
            Layout.columnSpan: parent.columns
            font.bold: true
        }
        CheckBox {
            id: automaticButtonThemeEnabled
            text: i18n("Automatic")
        }
        TextField {
            id: customAuroraeThemePath
            placeholderText: i18n("Absolute path to aurorae button theme folder")
            Layout.preferredWidth: 350
            onTextChanged: cfg_customAuroraeThemePath = text
            enabled: !automaticButtonThemeEnabled.checked
        }
    }

}
