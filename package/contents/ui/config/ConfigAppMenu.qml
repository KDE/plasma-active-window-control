import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {

    property alias cfg_appmenuFontBold: appmenuFontBold.checked
    property alias cfg_appmenuFillHeight: appmenuFillHeight.checked
    property alias cfg_appmenuVerticalPosition: appmenuVerticalPosition.currentIndex
    property alias cfg_appmenuSeparatorEnabled: appmenuSeparatorEnabled.checked
    property alias cfg_appmenuIconAndTextOpacity: appmenuIconAndTextOpacity.value
    property alias cfg_appmenuButtonTextSizeScale: appmenuButtonTextSizeScale.value

    GridLayout {
        columns: 2

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        CheckBox {
            id: appmenuFontBold
            text: i18n("Bold font")
            Layout.columnSpan: 2
        }

        CheckBox {
            id: appmenuFillHeight
            text: i18n("Fill height")
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('Vertical position:')
            Layout.alignment: Qt.AlignRight
        }
        ComboBox {
            id: appmenuVerticalPosition
            model: [i18n('Top'), i18n('Bottom')]
            enabled: !appmenuFillHeight.checked
        }

        CheckBox {
            id: appmenuSeparatorEnabled
            text: i18n("Show separator")
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('Icon and text opacity:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: appmenuIconAndTextOpacity
            decimals: 2
            stepSize: 0.1
            minimumValue: 0
            maximumValue: 1
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
