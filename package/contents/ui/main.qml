/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.activities 0.1 as Activities

Item {
    id: main

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)

    property double horizontalScreenWidthPercent: plasmoid.configuration.horizontalScreenWidthPercent
//     property double buttonSize: plasmoid.configuration.buttonSize
    property bool autoFillWidth: plasmoid.configuration.autoFillWidth
    property double widthForHorizontalPanel: (Screen.width * horizontalScreenWidthPercent + plasmoid.configuration.widthFineTuning) - ((!buttonsItem.visible && buttonsStandalone && plasmoid.configuration.buttonsDynamicWidth) ? buttonsItem.width : 0)
    anchors.fill: parent
    Layout.fillWidth: plasmoid.configuration.autoFillWidth
    Layout.preferredWidth: autoFillWidth ? -1 : (vertical ? parent.width : (widthForHorizontalPanel > 0 ? widthForHorizontalPanel : 0.0001))
    Layout.minimumWidth: Layout.preferredWidth
    Layout.maximumWidth: Layout.preferredWidth
    Layout.preferredHeight: parent === null ? 0 : vertical ? Math.min(theme.defaultFont.pointSize * 4, parent.width) : parent.height
    Layout.minimumHeight: Layout.preferredHeight
    Layout.maximumHeight: Layout.preferredHeight

    property int textType: plasmoid.configuration.textType
    property int fitText: plasmoid.configuration.fitText
    property int tooltipTextType: plasmoid.configuration.tooltipTextType
    property string tooltipText: ''

    property bool windowIconOnTheRight: plasmoid.configuration.windowIconOnTheRight
    property double iconAndTextSpacing: plasmoid.configuration.iconAndTextSpacing
    property bool slidingIconAndText: plasmoid.configuration.slidingIconAndText
    property double fontPixelSize: theme.defaultFont.pixelSize * plasmoid.configuration.fontSizeScale
    property bool fontBold: plasmoid.configuration.boldFontWeight
    property string fontFamily: plasmoid.configuration.fontFamily

    property bool noWindowActive: true
    property bool currentWindowMaximized: false
    property bool canShowButtonsAccordingMaximized: showButtonOnlyWhenMaximized ? currentWindowMaximized : true

    property int controlButtonsSpacing: plasmoid.configuration.controlButtonsSpacing

    property int bp: plasmoid.configuration.buttonsPosition;
    property bool buttonsVerticalCenter: plasmoid.configuration.buttonsVerticalCenter
    property bool showControlButtons: plasmoid.configuration.showControlButtons
    property bool showButtonOnlyWhenMaximized: plasmoid.configuration.showButtonOnlyWhenMaximized
    property bool showMinimize: showControlButtons && plasmoid.configuration.showMinimize
    property bool showMaximize: showControlButtons && plasmoid.configuration.showMaximize
    property bool showPinToAllDesktops: showControlButtons && plasmoid.configuration.showPinToAllDesktops
    property string buttonOrder: plasmoid.configuration.buttonOrder
    property bool doubleClickMaximizes: plasmoid.configuration.doubleClickMaximizes
    property int leftClickAction: plasmoid.configuration.leftClickAction
    property string chosenLeftClickSource: leftClickAction === 1 ? shortcutDS.presentWindows : leftClickAction === 2 ? shortcutDS.presentWindowsAll : leftClickAction === 3 ? shortcutDS.presentWindowsClass : ''
    property bool middleClickClose: plasmoid.configuration.middleClickAction === 1
    property bool middleClickFullscreen: plasmoid.configuration.middleClickAction === 2
    property bool wheelUpMaximizes: plasmoid.configuration.wheelUpMaximizes
    property bool wheelDownMinimizes: plasmoid.configuration.wheelDownAction === 1
    property bool wheelDownUnmaximizes: plasmoid.configuration.wheelDownAction === 2

    property bool buttonsStandalone: showControlButtons && plasmoid.configuration.buttonsStandalone
    property bool buttonsBetweenIconAndText: buttonsStandalone && plasmoid.configuration.buttonsBetweenIconAndText
    property bool doNotHideControlButtons: showControlButtons && plasmoid.configuration.doNotHideControlButtons

    property bool textColorLight: ((theme.textColor.r + theme.textColor.g + theme.textColor.b) / 3) > 0.5

    property bool mouseHover: false
    property bool isActiveWindowPinned: false
    property bool isActiveWindowMaximized: false

    property bool appmenuNextToIconAndText: plasmoid.configuration.appmenuNextToIconAndText
    property double appmenuSideMargin: plasmoid.configuration.appmenuOuterSideMargin
    property bool appmenuSwitchSidesWithIconAndText: plasmoid.configuration.appmenuSwitchSidesWithIconAndText
    property bool appmenuBoldTitleWhenMenuDisplayed: plasmoid.configuration.appmenuBoldTitleWhenMenuDisplayed

    property var activeTaskLocal: null
    property int activityActionCount: 0

    property bool automaticButtonThemeEnabled: plasmoid.configuration.automaticButtonThemeEnabled
    property string manualAuroraeThemePath: plasmoid.configuration.customAuroraeThemePath
    property string manualAuroraeThemePathResolved: ''
    property string manualAuroraeThemeExtension: 'svg'

    property var itemPartOrder: []

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    Plasmoid.status: {
        if (menuItem.appmenuOpened) {
            return PlasmaCore.Types.NeedsAttentionStatus;
        } else if (!menuItem.appmenuOpened && menuItem.appmenuEnabledAndNonEmpty){
            return PlasmaCore.Types.ActiveStatus;
        } else {
            return PlasmaCore.Types.PassiveStatus;
        }
    }

    //
    // MODEL
    //
    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        filterByScreen: plasmoid.configuration.showForCurrentScreenOnly

        onActiveTaskChanged: {
            updateActiveWindowInfo()
        }
        onDataChanged: {
            updateActiveWindowInfo()
        }
        onCountChanged: {
            updateActiveWindowInfo()
        }
    }

    TaskManager.ActivityInfo {
        id: activityInfo

        onCurrentActivityChanged: {
            if (noWindowActive) {
                updateActiveWindowInfo();
            }
            reAddActivityActions()
        }
        onNumberOfRunningActivitiesChanged: {
            reAddActivityActions()
        }
    }

    Activities.ActivityModel {
        id: activityModel
    }

    function activeTask() {
        return activeTaskLocal
    }

    function activeTaskExists() {
        return activeTaskLocal.display !== undefined
    }

    onTooltipTextTypeChanged: updateTooltip()

    function updateTooltip() {
        if (tooltipTextType === 1) {
            tooltipText = replaceTitle(activeTask().display || '')
        } else if (tooltipTextType === 2) {
            tooltipText = activeTask().AppName || ''
        } else {
            tooltipText = ''
        }
    }

    function composeNoWindowText() {
        return plasmoid.configuration.noWindowText.replace('%activity%', activityInfo.activityName(activityInfo.currentActivity))
    }

    function updateActiveWindowInfo() {

        var activeTaskIndex = tasksModel.activeTask

        // fallback for Plasma 5.8
        var abstractTasksModel = TaskManager.AbstractTasksModel || {}
        var isActive = abstractTasksModel.IsActive || 271
        var appName = abstractTasksModel.AppName || 258
        var isMaximized = abstractTasksModel.IsMaximized || 276
        var virtualDesktop = abstractTasksModel.VirtualDesktop || 286

        activeTaskLocal = {}
        if (tasksModel.data(activeTaskIndex, isActive)) {
            activeTaskLocal = {
                display: tasksModel.data(activeTaskIndex, Qt.DisplayRole),
                decoration: tasksModel.data(activeTaskIndex, Qt.DecorationRole),
                AppName: tasksModel.data(activeTaskIndex, appName),
                IsMaximized: tasksModel.data(activeTaskIndex, isMaximized),
                VirtualDesktop: tasksModel.data(activeTaskIndex, virtualDesktop)
            }
        }

        var actTask = activeTask()
        noWindowActive = !activeTaskExists()
        currentWindowMaximized = !noWindowActive && actTask.IsMaximized === true
        isActiveWindowPinned = actTask.VirtualDesktop === -1;
        if (noWindowActive) {
            titleItem.text = composeNoWindowText()
            iconItem.source = plasmoid.configuration.noWindowIcon
        } else {
            titleItem.text = (textType === 1 ? actTask.AppName : null) || replaceTitle(actTask.display)
            iconItem.source = actTask.decoration
        }
        updateTooltip()
    }

    function toggleMaximized() {
        tasksModel.requestToggleMaximized(tasksModel.activeTask);
    }

    function toggleMinimized() {
        tasksModel.requestToggleMinimized(tasksModel.activeTask);
    }

    function toggleClose() {
        tasksModel.requestClose(tasksModel.activeTask);
    }

    function toggleFullscreen() {
        tasksModel.requestToggleFullScreen(tasksModel.activeTask);
    }

    function togglePinToAllDesktops() {
        tasksModel.requestVirtualDesktop(tasksModel.activeTask, 0);
    }

    function setMaximized(maximized) {
        if ((maximized && !activeTask().IsMaximized)
            || (!maximized && activeTask().IsMaximized)) {
            print('toggle maximized')
            toggleMaximized()
        }
    }

    function setMinimized() {
        if (!activeTask().IsMinimized) {
            toggleMinimized()
        }
    }

    //
    // ACTIVE WINDOW INFO
    //
//     Item {
//         id: activeWindowListView
// 
//         anchors.top: parent.top
//         anchors.bottom: parent.bottom
// 
//         property double appmenuOffsetLeft: (bp === 0 || bp === 2) ? appmenu.appmenuOffsetWidth : 0
//         property double appmenuOffsetRight: (bp === 1 || bp === 3) ? appmenu.appmenuOffsetWidth : 0
//         property double controlButtonsAreaWidth: noWindowActive ? 0 : buttonsItem.width
//         property bool buttonsVisible: buttonsStandalone && (!slidingIconAndText || buttonsItem.mouseInWidget || doNotHideControlButtons) && (canShowButtonsAccordingMaximized || !slidingIconAndText)
//         property double buttonsBetweenAddition: buttonsVisible && buttonsBetweenIconAndText ? controlButtonsAreaWidth + iconAndTextSpacing : 0
// 
//         anchors.left: parent.left
//         anchors.leftMargin: buttonsVisible && (bp === 0 || bp === 2) && !buttonsBetweenIconAndText ? controlButtonsAreaWidth + iconAndTextSpacing + appmenuOffsetLeft : 0 + appmenuOffsetLeft
//         anchors.right: parent.right
//         anchors.rightMargin: buttonsVisible && (bp === 1 || bp === 3) && !buttonsBetweenIconAndText ? controlButtonsAreaWidth + iconAndTextSpacing + appmenuOffsetRight : 0 + appmenuOffsetRight
// 
//         Behavior on anchors.leftMargin {
//             NumberAnimation {
//                 duration: 150
//                 easing.type: Easing.Linear
//             }
//         }
//         Behavior on anchors.rightMargin {
//             NumberAnimation {
//                 duration: 150
//                 easing.type: Easing.Linear
//             }
//         }
// 
//         width: parent.width - anchors.leftMargin - anchors.rightMargin
// 
//         opacity: appmenu.visible && !appmenuNextToIconAndText ? plasmoid.configuration.appmenuIconAndTextOpacity : 1
// 
//         Item {
//             width: parent.width
//             height: main.height
// 
//             WindowIcon {
//                 id: iconItem
// 
//                 anchors.left: parent.left
//                 anchors.leftMargin: windowIconOnTheRight ? parent.width - iconItem.width : 0
//             }
// 
//             WindowTitle {
//                 id: titleItem
// 
//                 property double iconMarginForAnchor: noWindowActive && plasmoid.configuration.noWindowIcon === '' ? 0 : iconMargin
// 
//                 anchors.left: parent.left
//                 anchors.leftMargin: windowIconOnTheRight ? 0 : iconMarginForAnchor + iconAndTextSpacing + activeWindowListView.buttonsBetweenAddition
//                 anchors.top: parent.top
//                 anchors.bottom: parent.bottom
//             }
// 
//         }
//     }

    function getConfigName(itemName) {
        return itemName.substring(0, 1).toUpperCase() + itemName.substring(1)
    }

    function getPosition(itemName) {
        var configName = getConfigName(itemName)
        print('getPosition: ' + configName)
        print('POS: ' + plasmoid.configuration['controlPart' + configName + 'Position'])
        return plasmoid.configuration['controlPart' + configName + 'Position']
    }
    
    function isRelevant(itemName) {
        var configName = getConfigName(itemName)
        print('isRelevant: ' + configName)
        print('1IR: ' + plasmoid.configuration['controlPart' + configName + 'ShowOnMouseIn'])
        print('2IR: ' + plasmoid.configuration['controlPart' + configName + 'ShowOnMouseOut'])
        var result = plasmoid.configuration['controlPart' + configName + 'ShowOnMouseIn'] || plasmoid.configuration['controlPart' + configName + 'ShowOnMouseOut']
        print('res: ' + result)
        return result
    }

    function getItem(itemName) {
        if (itemName === 'icon') {
            return iconItem
        }
        if (itemName === 'title') {
            return titleItem
        }
        if (itemName === 'menu') {
            return menuItem
        }
        if (itemName === 'buttons') {
            return buttonsItem
        }
        return null
    }

    function getItemWidth(itemName) {
        return getItem().width
    }

    function anchorsLeftMargin(itemName) {
        var itemPosition = getPosition(itemName)
        print('position of ' + itemName + ' is ' + itemPosition)
        if (itemPosition === 2) {
            return 0
        }
        var anchorSize = 0
        itemPartOrder.some(function (iName, index) {
            print('iterating: ' + iName)
            if (iName === itemName) {
                return true
            }
            if (getPosition(iName) === itemPosition && isRelevant(iName)) {
                var currentItemWidth = getItemWidth(iName)
                print('width of ' + iName + ' is ' + currentItemWidth)
                anchorSize += currentItemWidth
                anchorSize += plasmoid.configuration.controlPartSpacing
            }
        });
        print('leftMargin of ' + itemName + ' is ' + anchorSize)
        return anchorSize
    }

    function refreshItemMargin() {
        iconItem.anchors.leftMargin = anchorsLeftMargin('icon')
        titleItem.anchors.leftMargin = anchorsLeftMargin('title')
        menuItem.anchors.leftMargin = anchorsLeftMargin('menu')
        buttonsItem.anchors.leftMargin = anchorsLeftMargin('buttons')
    }

    function replaceTitle(title) {
        if (!plasmoid.configuration.useWindowTitleReplace) {
            return title
        }
        return title.replace(new RegExp(plasmoid.configuration.replaceTextRegex), plasmoid.configuration.replaceTextReplacement);
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onEntered: {
            mouseHover = true
            buttonsItem.mouseInWidget = showControlButtons && !noWindowActive
        }

        onExited: {
            mouseHover = false
            buttonsItem.mouseInWidget = false
        }

        onWheel: {
            if (wheel.angleDelta.y > 0) {
                if (wheelUpMaximizes) {
                    setMaximized(true)
                }
            } else {
                if (wheelDownMinimizes) {
                    setMinimized()
                } else if (wheelDownUnmaximizes) {
                    setMaximized(false)
                }
            }
        }

        onDoubleClicked: {
            if (doubleClickMaximizes && mouse.button == Qt.LeftButton) {
                toggleMaximized()
            }
        }

        onClicked: {
            if (chosenLeftClickSource !== '' && !doubleClickMaximizes && mouse.button == Qt.LeftButton) {
                shortcutDS.connectedSources.push(chosenLeftClickSource)
                buttonsItem.mouseInWidget = false
                return
            }
            if (mouse.button == Qt.MiddleButton) {
                if (middleClickFullscreen) {
                    toggleFullscreen()
                } else if (middleClickClose) {
                    toggleClose()
                }
            }
        }

        PlasmaCore.ToolTipArea {

            anchors.fill: parent

            active: tooltipTextType > 0 && tooltipText !== ''
            interactive: true
            location: plasmoid.location

            mainItem: Row {

                spacing: 0

                Layout.minimumWidth: fullText.width + units.largeSpacing
                Layout.minimumHeight: childrenRect.height
                Layout.maximumWidth: Layout.minimumWidth
                Layout.maximumHeight: Layout.minimumHeight

                Item {
                    width: units.largeSpacing / 2
                    height: 2
                }

                PlasmaComponents.Label {
                    id: fullText
                    text: tooltipText
                }
            }
        }
    }
    
    ListModel {
        id: controlButtonsModel
    }
    
    WindowIcon {
        id: iconItem

        x: anchorsLeftMargin('icon')

        visible: ((mouseHover && plasmoid.configuration.controlPartIconShowOnMouseIn)
                    || (!mouseHover && plasmoid.configuration.controlPartIconShowOnMouseOut))

        onWidthChanged: refreshItemMargin()
    }

    WindowTitle {
        id: titleItem

        x: anchorsLeftMargin('title')
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        visible: ((mouseHover && plasmoid.configuration.controlPartTitleShowOnMouseIn)
                    || (!mouseHover && plasmoid.configuration.controlPartTitleShowOnMouseOut))
    }

    AppMenu {
        id: menuItem

        x: anchorsLeftMargin('menu')

        visible: ((mouseHover && plasmoid.configuration.controlPartMenuShowOnMouseIn)
                    || (!mouseHover && plasmoid.configuration.controlPartMenuShowOnMouseOut))
    }

    ControlButtons {
        id: buttonsItem

        x: anchorsLeftMargin('buttons')

        visible: true

        controlButtonsModel: controlButtonsModel

        showItem: ((mouseInWidget && plasmoid.configuration.controlPartButtonsShowOnMouseIn)
            || (!mouseInWidget && plasmoid.configuration.controlPartButtonsShowOnMouseOut))

    }

    property bool mouseInWidget: mouseHover || buttonsItem.mouseInWidget || menuItem.mouseInWidget

    onMouseHoverChanged: {
        print('mouse hover changed: ' + mouseHover);
    }

    onMouseInWidgetChanged: {
        print('mouseInWidget: ' + mouseInWidget);
    }

    onManualAuroraeThemePathChanged: {
        manualAuroraeThemeExtension = plasmoid.nativeInterface.extensionForTheme(manualAuroraeThemePath);
        manualAuroraeThemePathResolved = plasmoid.nativeInterface.translateThemePath(manualAuroraeThemePath);
        print('manualAuroraeThemePath=' + manualAuroraeThemePath)
        print('manualAuroraeThemePathResolved=' + manualAuroraeThemePathResolved)
        print('manualAuroraeThemeExtension=' + manualAuroraeThemeExtension)
    }

    function addButton(preparedArray, buttonName) {
        if (buttonName === 'close') {
            preparedArray.push({
                iconName: 'close',
                windowOperation: 'close'
            });
        } else if (buttonName === 'maximize' && showMaximize) {
            preparedArray.push({
                iconName: 'maximize',
                windowOperation: 'toggleMaximized'
            });
        } else if (buttonName === 'minimize' && showMinimize) {
            preparedArray.push({
                iconName: 'minimize',
                windowOperation: 'toggleMinimized'
            });
        } else if ((buttonName === 'pin' || buttonName === 'alldesktops') && showPinToAllDesktops) {
            preparedArray.push({
                iconName: 'alldesktops',
                windowOperation: 'togglePinToAllDesktops'
            });
        }
    }

    function initializeControlButtonsModel() {

        var preparedArray = []
        buttonOrder.split('|').forEach(function (buttonName) {
            addButton(preparedArray, buttonName);
        });

        controlButtonsModel.clear()

        preparedArray.forEach(function (item) {
            print('adding item to buttons: ' + item.iconName);
            controlButtonsModel.append(item);
        });
    }

    function performActiveWindowAction(windowOperation) {
        if (bp === 4) {
            return;
        }
        if (windowOperation === 'close') {
            toggleClose()
        } else if (windowOperation === 'toggleMaximized') {
            toggleMaximized()
        } else if (windowOperation === 'toggleMinimized') {
            toggleMinimized()
        } else if (windowOperation === 'togglePinToAllDesktops') {
            togglePinToAllDesktops()
        }
    }

    function action_close() {
        toggleClose()
    }

    function action_maximise() {
        toggleMaximized()
    }

    function action_minimise() {
        toggleMinimized()
    }

    function action_pinToAllDesktops() {
        togglePinToAllDesktops()
    }

    function action_reloadTheme() {
        plasmoid.nativeInterface.refreshAuroraeTheme();
    }

    function actionTriggered(actionName) {
        if (actionName.indexOf("switchToActivity_") == 0) {
            var activityIndex = actionName.replace("switchToActivity_", "")
            var activityId = activityInfo.runningActivities()[activityIndex]
            activityModel.setCurrentActivity(activityId, function() {});
        }
    }

    function reAddActivityActions() {
        plasmoid.removeAction("separator1")
        for (var i = 0; i < activityActionCount; i++) {
            plasmoid.removeAction('switchToActivity_' + i)
        }
        plasmoid.removeAction("separator2")

        var runningActivities = activityInfo.runningActivities()
        activityActionCount = runningActivities.length
        if (activityActionCount === 0) {
            return
        }
        plasmoid.setActionSeparator("separator1")
        activityInfo.runningActivities().forEach(function (activityId, index) {
            if (activityId === activityInfo.currentActivity) {
                return;
            }
            var activityName = activityInfo.activityName(activityId)
            plasmoid.setAction('switchToActivity_' + index, i18n('Switch to activity: %1', activityName), 'preferences-activities')
        })
        plasmoid.setActionSeparator("separator2")
    }

    property string controlPartOrder: plasmoid.configuration.controlPartOrder

    onControlPartOrderChanged: refreshControlPartOrder()

    function refreshControlPartOrder() {
        itemPartOrder.length = 0
        plasmoid.configuration.controlPartOrder.split('|').forEach(function (itemName, index) {
            print('itemOrder: ' + itemName)
            itemPartOrder.push(itemName)
            print('itemZ: ' + index)
            getItem(itemName).z = index
        });
        print('itemPartOrder initialized: ' + itemPartOrder)
    }

    Component.onCompleted: {
        refreshControlPartOrder()
        refreshItemMargin()
        initializeControlButtonsModel()
        updateActiveWindowInfo()
        plasmoid.setAction('close', i18n('Close'), 'window-close');
        plasmoid.setAction('maximise', i18n('Toggle Maximise'), 'arrow-up-double');
        plasmoid.setAction('minimise', i18n('Minimise'), 'draw-arrow-down');
        plasmoid.setAction('pinToAllDesktops', i18n('Toggle Pin To All Desktops'), 'window-pin');
        plasmoid.setActionSeparator("separator0")
        plasmoid.setAction('reloadTheme', i18n('Reload Theme'), 'system-reboot');
        reAddActivityActions()
    }

    onShowMaximizeChanged: initializeControlButtonsModel()
    onShowMinimizeChanged: initializeControlButtonsModel()
    onShowPinToAllDesktopsChanged: initializeControlButtonsModel()
    onBpChanged: initializeControlButtonsModel()
    onButtonOrderChanged: initializeControlButtonsModel()

    PlasmaCore.DataSource {
        id: shortcutDS
        engine: 'executable'

        property string presentWindows: 'qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Expose"'
        property string presentWindowsAll: 'qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "ExposeAll"'
        property string presentWindowsClass: 'qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "ExposeClass"'

        connectedSources: []

        onNewData: {
            connectedSources.length = 0
        }
    }

}
