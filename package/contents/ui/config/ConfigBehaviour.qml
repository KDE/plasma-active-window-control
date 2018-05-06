import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {

    property alias cfg_showForCurrentScreenOnly: showForCurrentScreenOnly.checked

    GridLayout {
        columns: 2

        CheckBox {
            id: toggleBorderlessMaximizedWindows
            text: i18n("Hide titlebar for maximized windows (takes effect immediately)")
            Layout.columnSpan: 2
            onCheckedChanged: {
                var preparedCmd = executableDS.cmdBorderlessWrite.replace('{borderless}', String(checked))
                executableDS.connectedSources.push(preparedCmd)
            }
        }

        CheckBox {
            id: showForCurrentScreenOnly
            text: i18n("Show active window only for plasmoid's screen")
            Layout.columnSpan: 2
        }
    }

    PlasmaCore.DataSource {
        id: executableDS
        engine: 'executable'

        property string cmdBorderlessRead: 'kreadconfig5 --file kwinrc --group Windows --key BorderlessMaximizedWindows'
        property string cmdBorderlessWrite: 'kwriteconfig5 --file kwinrc --group Windows --key BorderlessMaximizedWindows --type bool {borderless}'
        property string cmdReconfigure: 'qdbus org.kde.KWin /KWin reconfigure'

        connectedSources: []

        onNewData: {
            connectedSources.length = 0
            print('sourceName: ' + sourceName)
            if (sourceName === cmdBorderlessRead) {
                var trimmedStdout = data.stdout.trim()
                print('current value: ' + trimmedStdout)
                toggleBorderlessMaximizedWindows.checked = trimmedStdout === 'true'
            } else if (sourceName.indexOf('kwriteconfig5') === 0) {
                connectedSources.push(cmdReconfigure)
            }
        }
    }

    Component.onCompleted: {
        executableDS.connectedSources.push(executableDS.cmdBorderlessRead)
    }

}
