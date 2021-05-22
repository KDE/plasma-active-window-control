/*
    SPDX-FileCopyrightText: 2015 Martin Kotelnik <clearmartin@seznam.cz>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

MouseArea {
    id: controlButton

    height: controlButtonsArea.height
    width: controlButtonsArea.controlButtonsHeight

    property bool mouseInside: false
    property bool iconActive: (iconName !== 'alldesktops' && iconName !== 'maximize') || (iconName === 'alldesktops' && main.isActiveWindowPinned) || (iconName === 'maximize' && main.currentWindowMaximized)

    property string themeName: textColorLight ? 'breeze-dark' : 'default'
    property string customAuroraeThemePath: main.automaticButtonThemeEnabled ? plasmoid.nativeInterface.auroraeThemePath : manualAuroraeThemePathResolved
    property string customAuroraeImageExt: main.automaticButtonThemeEnabled ? plasmoid.nativeInterface.auroraeThemeType : manualAuroraeThemeExtension
    property bool usingAuroraeTheme: customAuroraeThemePath ? true : false
    property string buttonImagePath: customAuroraeThemePath ? customAuroraeThemePath + '/' + iconName + '.' + customAuroraeImageExt : Qt.resolvedUrl('../icons/' + themeName + '/' + iconName + '.svg')
    property string svgElementId: usingAuroraeTheme
                                    ? (iconActive && iconName === 'alldesktops') ? (mouseInside ? 'pressed-center' : 'pressed-center') : (mouseInside ? 'hover-center' : 'active-center')
                                    : iconActive ? (mouseInside ? 'active-hover' : 'active-idle') : (mouseInside ? 'inactive-hover' : 'inactive-idle')

    PlasmaCore.Svg {
        id: buttonSvg
        imagePath: buttonImagePath
    }

    // icon
    PlasmaCore.SvgItem {
        id: svgItem
        width: parent.width
        height: width
        svg: buttonSvg
        elementId: svgElementId
        anchors.verticalCenter: parent.verticalCenter
    }

    hoverEnabled: true

    onEntered: {
        mouseInside = true
    }

    onExited: {
        mouseInside = false
    }

    // trigger active window action
    onClicked: {
        controlButtonsArea.mouseInWidget = true
        main.performActiveWindowAction(windowOperation)
    }
}
