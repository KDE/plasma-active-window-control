import QtQuick 2.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.Label {
    id: titleItem

//     property double iconMargin: (plasmoid.configuration.showWindowIcon ? iconItem.width : 0)
//     property double properWidth: parent.width - iconMargin - iconAndTextSpacing
    property double properHeight: parent.height
    property bool noElide: fitText === 2 || (fitText === 1 && mouseHover)
    property int allowFontSizeChange: 3
    property int minimumPixelSize: 8
//     property bool limitTextWidth: plasmoid.configuration.limitTextWidth
//     property int textWidthLimit: plasmoid.configuration.textWidthLimit
//     property double computedWidth: (limitTextWidth ? (implicitWidth > textWidthLimit ? textWidthLimit : implicitWidth) : properWidth)// - activeWindowListView.buttonsBetweenAddition

    verticalAlignment: Text.AlignVCenter
    text: plasmoid.configuration.noWindowText
    wrapMode: Text.Wrap
//     width: computedWidth
    height: properHeight
    elide: noElide ? Text.ElideNone : Text.ElideRight
    visible: plasmoid.configuration.showWindowTitle
    font.pixelSize: fontPixelSize
    font.pointSize: -1
    font.weight: fontBold || (appmenuBoldTitleWhenMenuDisplayed && appmenu.visible) ? Font.Bold : theme.defaultFont.weight
    font.family: fontFamily || theme.defaultFont.family

    onTextChanged: {
        font.pixelSize = fontPixelSize
        allowFontSizeChange = 3
    }

    onNoElideChanged: {
        font.pixelSize = fontPixelSize
        allowFontSizeChange = 3
    }

    onPaintedHeightChanged: {
        if (allowFontSizeChange > 0 && noElide && paintedHeight > properHeight) {
            var newPixelSize = (properHeight / paintedHeight) * fontPixelSize
            font.pixelSize = newPixelSize < minimumPixelSize ? minimumPixelSize : newPixelSize
        }
        allowFontSizeChange--
    }
}