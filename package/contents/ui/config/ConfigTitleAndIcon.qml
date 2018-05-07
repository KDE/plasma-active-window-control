import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {

    property alias cfg_textType: textTypeCombo.currentIndex
    property alias cfg_fitText: fitTextCombo.currentIndex
    property alias cfg_tooltipTextType: tooltipTextTypeCombo.currentIndex
    property alias cfg_useWindowTitleReplace: useWindowTitleReplace.checked
    property alias cfg_replaceTextRegex: replaceTextRegex.text
    property alias cfg_replaceTextReplacement: replaceTextReplacement.text
    property alias cfg_noWindowText: noWindowText.text
    property string cfg_noWindowIcon: plasmoid.configuration.noWindowIcon
    property alias cfg_limitTextWidth: limitTextWidth.checked
    property alias cfg_textWidthLimit: textWidthLimit.value

    property alias cfg_textFontBold: textFontBoldCombo.currentIndex
    property string cfg_fontFamily
    property alias cfg_fontSizeScale: fontSizeScale.value

    /* copied from /usr/share/plasma/plasmoids/org.kde.plasma.digitalclock/contents/ui/configAppearance.qml */
    onCfg_fontFamilyChanged: {
        // HACK by the time we populate our model and/or the ComboBox is finished the value is still undefined
        if (cfg_fontFamily) {
            for (var i = 0, j = fontsModel.count; i < j; ++i) {
                if (fontsModel.get(i).value == cfg_fontFamily) {
                    fontFamilyComboBox.currentIndex = i
                    break
                }
            }
        }
    }

    ListModel {
        id: fontsModel
        Component.onCompleted: {
            var arr = [ {text: i18nc("Use default font", "Default"), value: ""} ]
            Qt.fontFamilies().forEach(function (font) {
                arr.push({text: font, value: font})
            })
            append(arr)
            cfg_fontFamilyChanged();
        }
    }

    GridLayout {
        columns: 2

        Label {
            text: i18n('Text')
            Layout.alignment: Qt.AlignLeft
            font.bold: true
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('Text type:')
            Layout.alignment: Qt.AlignRight
        }
        ComboBox {
            id: textTypeCombo
            model: [i18n('Window title'), i18n('Application name')]
        }

        Label {
            text: i18n('Fit text:')
            Layout.alignment: Qt.AlignRight
        }
        ComboBox {
            id: fitTextCombo
            model: [i18n('Just elide'), i18n('Fit on hover'), i18n('Always fit')]
        }

        Label {
            text: i18n('Tooltip text:')
            Layout.alignment: Qt.AlignRight
        }
        ComboBox {
            id: tooltipTextTypeCombo
            model: [i18n('No tooltip'), i18n('Window title'), i18n('Application name')]
        }

        Item {
            width: 2
            height: units.largeSpacing
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('Bold text:')
            Layout.alignment: Qt.AlignRight
        }
        ComboBox {
            id: textFontBoldCombo
            // ComboBox's sizing is just utterly broken
            Layout.minimumWidth: units.gridUnit * 10
            model: [i18n('Never'), i18n('Always'), i18n('When appmenu is displayed')]
        }

        Label {
            text: i18n('Text font:')
            Layout.alignment: Qt.AlignRight
        }
        ComboBox {
            id: fontFamilyComboBox
            // ComboBox's sizing is just utterly broken
            Layout.minimumWidth: units.gridUnit * 10
            model: fontsModel
            // doesn't autodeduce from model because we manually populate it
            textRole: "text"
            onCurrentIndexChanged: {
                var current = model.get(currentIndex)
                if (current) {
                    cfg_fontFamily = current.value
                    //appearancePage.configurationChanged()
                    console.log('change: ' + cfg_fontFamily)
                }
            }
        }

        Label {
            text: i18n("Font size scale:")
            Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }
        SpinBox {
            id: fontSizeScale
            decimals: 2
            stepSize: 0.05
            minimumValue: 0
            maximumValue: 3
        }

        CheckBox {
            id: limitTextWidth
            text: i18n('Limit text width')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: textWidthLimit
            decimals: 0
            stepSize: 10
            minimumValue: 0
            maximumValue: 10000
            enabled: limitTextWidth.checked
            suffix: i18nc('Abbreviation for pixels', 'px')
        }

        Item {
            width: 2
            height: units.largeSpacing
            Layout.columnSpan: 2
        }

        CheckBox {
            id: useWindowTitleReplace
            text: '"' + i18n('Window title') + '".replace(/'
            Layout.alignment: Qt.AlignRight
        }
        GridLayout {
            columns: 4

            TextField {
                id: replaceTextRegex
                placeholderText: '^(.*)\\s+[—–\\-:]\\s+([^—–\\-:]+)$'
                Layout.preferredWidth: 270
                onTextChanged: cfg_replaceTextRegex = text
                enabled: useWindowTitleReplace.checked
            }

            Label {
                text: '/, "'
            }

            TextField {
                id: replaceTextReplacement
                placeholderText: '$2 — $1'
                Layout.preferredWidth: 100
                onTextChanged: cfg_replaceTextReplacement = text
                enabled: useWindowTitleReplace.checked
            }

            Label {
                text: '");'
            }
        }

        Label {
            text: i18n('No window text:')
            Layout.alignment: Qt.AlignRight
        }
        GridLayout {
            columns: 2

            TextField {
                id: noWindowText
                placeholderText: 'Plasma Desktop :: %activity%'
                onTextChanged: cfg_noWindowText = text
                Layout.preferredWidth: 270
            }

            Label {
                text: i18n('Use %activity% placeholder to show current activity name.')
                Layout.preferredWidth: 150
                wrapMode: Text.Wrap
            }
        }

        Item {
            width: 2
            height: units.largeSpacing
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('Icon')
            Layout.alignment: Qt.AlignLeft
            font.bold: true
            Layout.columnSpan: 2
        }

        Label {
            text: i18n("No window icon:")
            Layout.alignment: Qt.AlignRight
        }
        IconPicker {
            currentIcon: cfg_noWindowIcon
            defaultIcon: ''
            onIconChanged: cfg_noWindowIcon = iconName
        }
    }
}
