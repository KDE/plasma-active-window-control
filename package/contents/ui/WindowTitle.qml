import QtQuick 2.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.Label {
    id: titleItem

    property double properHeight: parent.height
    property int fontBold: plasmoid.configuration.textFontBold
    property string fontFamily: plasmoid.configuration.fontFamily
    property int fitText: plasmoid.configuration.fitText
    property bool noElide: fitText === 2 || (fitText === 1 && mainMouseArea.containsMouse)
    property int allowFontSizeChange: 3
    property int minimumPixelSize: 8
    property bool limitTextWidth: plasmoid.configuration.limitTextWidth
    property int textWidthLimit: plasmoid.configuration.textWidthLimit

    property double recommendedWidth

    onRecommendedWidthChanged: {
        if (limitTextWidth) {
            width = undefined
            if (implicitWidth > textWidthLimit) {
                width = textWidthLimit
            } else {
                width = recommendedWidth
            }
        } else {
            width = recommendedWidth
        }
    }

    verticalAlignment: Text.AlignVCenter
    text: plasmoid.configuration.noWindowText
    wrapMode: Text.Wrap
    width: recommendedWidth
    height: properHeight
    elide: noElide ? Text.ElideNone : Text.ElideRight
    font.pixelSize: fontPixelSize
    font.pointSize: -1
    font.weight: fontBold === 1 || (fontBold === 2 && menuItem.showItem) ? Font.Bold : theme.defaultFont.weight
    font.family: fontFamily || theme.defaultFont.family

    opacity: menuItem.showItem ? plasmoid.configuration.appmenuIconAndTextOpacity : 1

    onTextChanged: {
        font.pixelSize = fontPixelSize
        allowFontSizeChange = 3
        recommendedWidthChanged()
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