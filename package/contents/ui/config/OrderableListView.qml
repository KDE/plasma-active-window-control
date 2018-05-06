import QtQuick 2.6
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: mainContent

    property var model
    property int orientation
    property double itemWidth
    property double itemHeight
    property bool interactive

    width: itemWidth * (orientation == ListView.Vertical ? 1 : model.count)
    height: itemHeight * (orientation == ListView.Horizontal ? 1 : model.count)

    SystemPalette {
        id: palette
    }

    // theme + svg
    property bool textColorLight: ((palette.text.r + palette.text.g + palette.text.b) / 3) > 0.5
    property string themeName: textColorLight ? 'breeze-dark' : 'default'

    signal modelOrderChanged()

    ListView {
        id: listView
        anchors.fill: parent
        model: mainContent.model
        orientation: mainContent.orientation
        delegate: OrderableItem {

            listViewParent: listView.parent

            Item {
                height: itemHeight
                width: itemWidth

                PlasmaCore.Svg {
                    id: buttonSvg
                    imagePath: Qt.resolvedUrl('../../icons/' + themeName + '/' + model.iconName + '.svg')
                }

                // item border
                Rectangle {
                    border.width: 1
                    border.color: theme.textColor
                    radius: units.gridUnit / 4
                    color: 'transparent'
                    opacity: 0.5
                    anchors.fill: parent
                }

                // icon
                PlasmaCore.SvgItem {
                    id: svgItem
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: width
                    svg: buttonSvg
                    elementId: 'active-idle'
                    visible: !!model.iconName
                }

                // text
                Label {
                    text: model.text || ''
                    anchors.fill: parent
                    anchors.leftMargin: svgItem.visible ? svgItem.width + units.smallSpacing : 0
                    visible: !!model.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            onMoveItemRequested: {
                mainContent.model.move(from, to, 1);
                mainContent.modelOrderChanged()
            }
        }
    }
}

