import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {

    property alias cfg_appmenuFontBold: appmenuFontBold.checked
    property int cfg_appmenuVerticalPosition
    property alias cfg_appmenuSeparatorEnabled: appmenuSeparatorEnabled.checked
    property alias cfg_appmenuButtonTextSizeScale: appmenuButtonTextSizeScale.value

    onCfg_appmenuVerticalPositionChanged: {
        switch (cfg_appmenuVerticalPosition) {
        case 0:
            appmenuVertialPositionGroup.current = topRadio;
            break;
        case 1:
            appmenuVertialPositionGroup.current = fillHeightRadio;
            break;
        case 2:
            appmenuVertialPositionGroup.current = bottomRadio;
            break;
        default:
            appmenuVertialPositionGroup.current = topRadio;
        }
    }

    Component.onCompleted: {
        cfg_appmenuVerticalPositionChanged()
    }

    ExclusiveGroup {
        id: appmenuVertialPositionGroup
    }

    GridLayout {
        columns: 2

        Item {
            width: 2
            height: units.largeSpacing
            Layout.columnSpan: 2
        }

        Item {
            width: 2
            height: 2
            Layout.rowSpan: 2
        }

        CheckBox {
            id: appmenuFontBold
            text: i18n("Bold font")
        }

        CheckBox {
            id: appmenuSeparatorEnabled
            text: i18n("Show separator")
        }

        Label {
            text: i18n('Vertical position:')
            Layout.alignment: Qt.AlignRight
        }
        RadioButton {
            id: topRadio
            exclusiveGroup: appmenuVertialPositionGroup
            text: i18n("Top")
            onCheckedChanged: if (checked) cfg_appmenuVerticalPosition = 0;
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 2
        }
        RadioButton {
            id: fillHeightRadio
            exclusiveGroup: appmenuVertialPositionGroup
            text: i18n("Fill height")
            onCheckedChanged: if (checked) cfg_appmenuVerticalPosition = 1;
        }
        RadioButton {
            id: bottomRadio
            exclusiveGroup: appmenuVertialPositionGroup
            text: i18n("Bottom")
            onCheckedChanged: if (checked) cfg_appmenuVerticalPosition = 2;
        }

        Label {
            text: i18n('Menu button text size scale:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: appmenuButtonTextSizeScale
            decimals: 2
            stepSize: 0.1
            minimumValue: 0.5
            maximumValue: 5
        }
    }

}
