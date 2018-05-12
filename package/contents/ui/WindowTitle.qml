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
    property string textFontFamily: plasmoid.configuration.textFontFamily
    property int fitText: plasmoid.configuration.fitText
    property bool noElide: fitText === 2 || (fitText === 1 && mainMouseArea.containsMouse)
    property int allowFontSizeChange: 3
    property int minimumPixelSize: 8
    property bool limitTextWidth: plasmoid.configuration.limitTextWidth
    property int textWidthLimit: plasmoid.configuration.textWidthLimit

    property double recommendedMaxWidth
    property bool useUpPossibleWidth: main.useUpWidthItem === 0
    property bool doNotRestrictWidth: useUpPossibleWidth && autoFillWidth

    signal contentChanged()

    onRecommendedMaxWidthChanged: {
        var maxWidth = limitTextWidth ? Math.min(textWidthLimit, recommendedMaxWidth) : recommendedMaxWidth
        width = undefined
        if (useUpPossibleWidth || (implicitWidth > maxWidth)) {
            width = maxWidth
        }
        print('title: width set to ' + width)
    }

    onUseUpPossibleWidthChanged: recommendedMaxWidthChanged()

    onDoNotRestrictWidthChanged: {
        if (doNotRestrictWidth) {
            width = undefined
        } else {
            recommendedMaxWidthChanged()
        }
    }

    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: plasmoid.configuration.controlPartTitleHorizontalAlignment === 0 ? Text.AlignLeft : Text.AlignRight
    text: plasmoid.configuration.noWindowText
    wrapMode: Text.Wrap
    height: properHeight
    elide: noElide ? Text.ElideNone : Text.ElideRight
    font.pixelSize: fontPixelSize
    font.pointSize: -1
    font.weight: fontBold === 1 || (fontBold === 2 && menuItem.showItem) ? Font.Bold : theme.defaultFont.weight
    font.family: textFontFamily || theme.defaultFont.family

    onTextChanged: {
        font.pixelSize = fontPixelSize
        allowFontSizeChange = 3
        recommendedMaxWidthChanged()
        contentChanged()
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