#!/usr/bin/bash

itemTitles=("Buttons" "Icon" "Title" "Menu")

settingsLines=""
for name in ${itemTitles[@]}; do
    settingsLines="$settingsLines\n    property alias cfg_controlPart${name}Position: controlPart${name}Position.currentIndex"
    settingsLines="$settingsLines\n    property alias cfg_controlPart${name}ShowOnMouseIn: controlPart${name}ShowOnMouseIn.checked"
    settingsLines="$settingsLines\n    property alias cfg_controlPart${name}ShowOnMouseOut: controlPart${name}ShowOnMouseOut.checked"
    settingsLines="$settingsLines\n    property alias cfg_controlPart${name}HorizontalAlignment: controlPart${name}HorizontalAlignment.currentIndex\n"
done

echo -e "$settingsLines"

controlLines=""
for name in ${itemTitles[@]}; do
    controlLines="$controlLines
        Item {
            width: 2
            height: units.smallSpacing
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('${name}')
            font.bold: true
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('Position:')
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }

        ComboBox {
            id: controlPart${name}Position
            model: [i18n('Occupy'), i18n('Floating layer'), i18n('Absolute')]
        }

        CheckBox {
            id: controlPart${name}ShowOnMouseIn
            text: i18n('Show on mouse in')
            Layout.columnSpan: 2
        }

        CheckBox {
            id: controlPart${name}ShowOnMouseOut
            text: i18n('Show on mouse out')
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('Horizontal alignment:')
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }

        ComboBox {
            id: controlPart${name}HorizontalAlignment
            model: [i18n('Left'), i18n('Right')]
        }

"
done

echo -e "$controlLines"
