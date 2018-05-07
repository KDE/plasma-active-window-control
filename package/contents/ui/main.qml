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
    property bool autoFillWidth: plasmoid.configuration.autoFillWidth
    property double widthForHorizontalPanel: (Screen.width * horizontalScreenWidthPercent + plasmoid.configuration.widthFineTuning)

    property int useUpWidthItem: plasmoid.configuration.useUpWidthItem

    property int textType: plasmoid.configuration.textType
    property int tooltipTextType: plasmoid.configuration.tooltipTextType
    property string tooltipText: ''

    property double fontPixelSize: theme.defaultFont.pixelSize * plasmoid.configuration.fontSizeScale

    property bool noWindowActive: true
    property bool currentWindowMaximized: false

    property bool doubleClickMaximizes: plasmoid.configuration.doubleClickMaximizes
    property int leftClickAction: plasmoid.configuration.leftClickAction
    property string chosenLeftClickSource: leftClickAction === 1 ? shortcutDS.presentWindows : leftClickAction === 2 ? shortcutDS.presentWindowsAll : leftClickAction === 3 ? shortcutDS.presentWindowsClass : ''
    property bool middleClickClose: plasmoid.configuration.middleClickAction === 1
    property bool middleClickFullscreen: plasmoid.configuration.middleClickAction === 2
    property bool wheelUpMaximizes: plasmoid.configuration.wheelUpMaximizes
    property bool wheelDownMinimizes: plasmoid.configuration.wheelDownAction === 1
    property bool wheelDownUnmaximizes: plasmoid.configuration.wheelDownAction === 2

    property bool textColorLight: ((theme.textColor.r + theme.textColor.g + theme.textColor.b) / 3) > 0.5

    property bool isActiveWindowPinned: false
    property bool isActiveWindowMaximized: false

    property bool controlPartMouseAreaRestrictedToWidget: plasmoid.configuration.controlPartMouseAreaRestrictedToWidget

    property var activeTaskLocal: null
    property int activityActionCount: 0

    property var itemPartOrder: []

    property bool mouseInWidget: mainMouseArea.containsMouse || buttonsItem.mouseInWidget || menuItem.mouseInWidget

    anchors.fill: parent

    Layout.fillWidth: autoFillWidth
    Layout.preferredWidth: autoFillWidth ? -1 : (vertical ? parent.width : (widthForHorizontalPanel > 0 ? widthForHorizontalPanel : 0.0001))
    Layout.minimumWidth: Layout.preferredWidth
    Layout.maximumWidth: Layout.preferredWidth
    Layout.preferredHeight: parent === null ? 0 : vertical ? Math.min(theme.defaultFont.pointSize * 4, parent.width) : parent.height
    Layout.minimumHeight: Layout.preferredHeight
    Layout.maximumHeight: Layout.preferredHeight

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

    function updateTooltip() {
        if (tooltipTextType === 1) {
            tooltipText = replaceTitle(activeTask().display || '')
        } else if (tooltipTextType === 2) {
            tooltipText = activeTask().AppName || ''
        } else {
            tooltipText = ''
        }
    }

    onTooltipTextTypeChanged: updateTooltip()

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

    function getConfigName(itemName) {
        return itemName.substring(0, 1).toUpperCase() + itemName.substring(1)
    }

    /*
     * Position can be:
     *   0 ... occupy
     *   1 ... floating layer (second occupy)
     *   2 ... absolute
     */
    function getPosition(itemName) {
        var configName = getConfigName(itemName)
        print('getPosition: ' + configName)
        print('POS: ' + plasmoid.configuration['controlPart' + configName + 'Position'])
        return plasmoid.configuration['controlPart' + configName + 'Position']
    }

    /*
     * Alignment can be:
     *   0 ... left
     *   1 ... right
     */
    function getAlignment(itemName) {
        var configName = getConfigName(itemName)
        print('getAlignment: ' + configName)
        print('ALI: ' + plasmoid.configuration['controlPart' + configName + 'HorizontalAlignment'])
        return plasmoid.configuration['controlPart' + configName + 'HorizontalAlignment']
    }

    function isRelevant(itemName) {
        var configName = getConfigName(itemName)
        var mouseInConfigName = 'controlPart' + configName + 'ShowOnMouseIn'
        var mouseOutConfigName = 'controlPart' + configName + 'ShowOnMouseOut'
        return plasmoid.configuration[mouseInConfigName] || plasmoid.configuration[mouseOutConfigName]
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
        if (itemName === 'title' && !titleItem.useUpPossibleWidth) {
            return getItem(itemName).implicitWidth
        }
        return getItem(itemName).width
    }

    function getLeftMargin(itemName) {
        var itemPosition = getPosition(itemName)
        var itemAlignment = getAlignment(itemName)
        print('position of ' + itemName + ' is ' + itemPosition)
        if (itemPosition === 2) {
            return 0
        }
        var anchorSize = 0
        var itemPartOrderArray = itemAlignment === 0 ? itemPartOrder : itemPartOrder.slice().reverse()
        itemPartOrderArray.some(function (iName, index) {
            print('iterating: ' + iName)
            if (iName === itemName) {
                return true
            }
            if (getPosition(iName) === itemPosition && getAlignment(iName) === itemAlignment && isRelevant(iName)) {
                var currentItemWidth = getItemWidth(iName)
                print('width of ' + iName + ' is ' + currentItemWidth)
                anchorSize += currentItemWidth
                anchorSize += plasmoid.configuration.controlPartSpacing
            }
        });
        if (itemAlignment === 1) {
            var computedWidth = autoFillWidth ? main.width : widthForHorizontalPanel
            anchorSize = computedWidth - anchorSize - getItemWidth(itemName)
        }
        print('leftMargin of ' + itemName + ' is ' + anchorSize)
        return anchorSize
    }

    function getMaxWidth(itemName) {
        var itemPosition = getPosition(itemName)
        print('getMaxWidth(): position of ' + itemName + ' is ' + itemPosition)
        if (itemPosition === 2) {
            return 0
        }
        var computedWidth = autoFillWidth ? main.width : widthForHorizontalPanel
        itemPartOrder.forEach(function (iName, index) {
            print('iterating: ' + iName)
            if (iName === itemName) {
                return;
            }
            if (getPosition(iName) === itemPosition && isRelevant(iName)) {
                var currentItemWidth = getItemWidth(iName)
                print('width of ' + iName + ' is ' + currentItemWidth)
                computedWidth -= currentItemWidth
                computedWidth -= plasmoid.configuration.controlPartSpacing
            }
        });
        print('computedWidth of ' + itemName + ' is ' + computedWidth)
        return computedWidth
    }

    function refreshItemPosition() {
        if (titleItem.useUpPossibleWidth) {
            titleItem.recommendedMaxWidth = getMaxWidth('title')
            menuItem.recommendedMaxWidth = getMaxWidth('menu')
        } else {
            titleItem.recommendedMaxWidth = getMaxWidth('title')
            menuItem.recommendedMaxWidth = getMaxWidth('menu')
        }

        iconItem.x = getLeftMargin('icon')
        titleItem.x = getLeftMargin('title')
        menuItem.x = getLeftMargin('menu')
        buttonsItem.x = getLeftMargin('buttons')

        textSeparator.x = getLeftMargin('menu') - (plasmoid.configuration.controlPartSpacing / 2)
    }

    function replaceTitle(title) {
        if (!plasmoid.configuration.useWindowTitleReplace) {
            return title
        }
        return title.replace(new RegExp(plasmoid.configuration.replaceTextRegex), plasmoid.configuration.replaceTextReplacement);
    }

    onWidthChanged: {
        if (autoFillWidth) {
            refreshItemPosition();
        }
    }
    onWidthForHorizontalPanelChanged: refreshItemPosition()

    MouseArea {
        id: mainMouseArea

        anchors.fill: parent

        hoverEnabled: true

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

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

        visible: ((mouseInWidget && plasmoid.configuration.controlPartIconShowOnMouseIn)
                    || (!mouseInWidget && plasmoid.configuration.controlPartIconShowOnMouseOut))

        onWidthChanged: refreshItemPosition()
    }

    WindowTitle {
        id: titleItem

        visible: ((mouseInWidget && plasmoid.configuration.controlPartTitleShowOnMouseIn)
                    || (!mouseInWidget && plasmoid.configuration.controlPartTitleShowOnMouseOut))

        onImplicitWidthChanged: {
            if (!titleItem.useUpPossibleWidth) {
                refreshItemPosition()
            }
        }

        onUseUpPossibleWidthChanged: refreshItemPosition()
    }

    AppMenu {
        id: menuItem

        property bool mouseIn: controlPartMouseAreaRestrictedToWidget ? menuItem.mouseInWidget : main.mouseInWidget

        height: main.height

        showItem: !noWindowActive && ((mouseIn && plasmoid.configuration.controlPartMenuShowOnMouseIn)
                    || (!mouseIn && plasmoid.configuration.controlPartMenuShowOnMouseOut))
    }

    ControlButtons {
        id: buttonsItem

        property bool mouseIn: controlPartMouseAreaRestrictedToWidget ? buttonsItem.mouseInWidget : main.mouseInWidget

        showItem: !noWindowActive && ((mouseIn && plasmoid.configuration.controlPartButtonsShowOnMouseIn)
            || (!mouseIn && plasmoid.configuration.controlPartButtonsShowOnMouseOut))

        onWidthChanged: refreshItemPosition()
    }

    Rectangle {
        id: textSeparator
        x: 0
        anchors.verticalCenter: main.verticalCenter
        height: 0.8 * parent.height
        width: 1
        visible: plasmoid.configuration.appmenuSeparatorEnabled && menuItem.showItem
        color: theme.textColor
        opacity: 0.4
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
    onUseUpWidthItemChanged: refreshControlPartOrder()

    function refreshControlPartOrder() {
        itemPartOrder.length = 0
        plasmoid.configuration.controlPartOrder.split('|').forEach(function (itemName, index) {
            print('itemOrder: ' + itemName)
            itemPartOrder.push(itemName)
            print('itemZ: ' + index)
            getItem(itemName).z = index
        });
        print('itemPartOrder initialized: ' + itemPartOrder)
        refreshItemPosition()
    }

    Component.onCompleted: {
        refreshControlPartOrder()
        refreshItemPosition()
        updateActiveWindowInfo()
        // actions
        plasmoid.setAction('close', i18n('Close'), 'window-close');
        plasmoid.setAction('maximise', i18n('Toggle Maximise'), 'arrow-up-double');
        plasmoid.setAction('minimise', i18n('Minimise'), 'draw-arrow-down');
        plasmoid.setAction('pinToAllDesktops', i18n('Toggle Pin To All Desktops'), 'window-pin');
        plasmoid.setActionSeparator("separator0")
        plasmoid.setAction('reloadTheme', i18n('Reload Theme'), 'system-reboot');
        reAddActivityActions()
    }

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
