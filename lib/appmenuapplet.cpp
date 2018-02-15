/*
 * Copyright 2016 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "appmenuapplet.h"
#include "../plugin/appmenumodel.h"

#include <QAction>
#include <QDir>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusPendingCall>
#include <QDBusConnectionInterface>
#include <QKeyEvent>
#include <QMenu>
#include <QMouseEvent>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>
#include <QTimer>

#include <KConfig>
#include <KShell>

int AppMenuApplet::s_refs = 0;

static const QString s_viewService(QStringLiteral("org.kde.kappmenuview"));

AppMenuApplet::AppMenuApplet(QObject *parent, const QVariantList &data)
    : Plasma::Applet(parent, data)
{
    /*it registers or unregisters the service when the destroyed value of the applet change,
      and not in the dtor, because:
      when we "delete" an applet, it just hides it for about a minute setting its status
      to destroyed, in order to be able to do a clean undo: if we undo, there will be
      another destroyedchanged and destroyed will be false.
      When this happens, if we are the only appmenu applet existing, the dbus interface
      will have to be registered again*/
    connect(this, &Applet::destroyedChanged, this, [this](bool destroyed) {
        if (destroyed) {
            unregisterService();
        } else {
            registerService();
        }
    });

    // get current aurorae decoration theme if there is one set
    refreshAuroraeTheme();
}

AppMenuApplet::~AppMenuApplet() = default;

void AppMenuApplet::init()
{
}

AppMenuModel *AppMenuApplet::model() const
{
    return m_model;
}

void AppMenuApplet::refreshAuroraeTheme()
{
    const KConfig kwinConfig(QString("kwinrc"), KConfig::OpenFlag::SimpleConfig);
    const QByteArray decorationGroupName = QString("org.kde.kdecoration2").toUtf8();
    if (!kwinConfig.hasGroup(decorationGroupName)) {
        return;
    }
    const KConfigGroup decorationGroup = kwinConfig.group(decorationGroupName);
    const QString decorationLibrary = decorationGroup.readEntry(QString("library"), QString());
    if (decorationLibrary == QString("org.kde.kwin.aurorae")) {
        const QString decorationTheme = decorationGroup.readEntry(QString("theme"), QString());
        if (decorationTheme.startsWith(QString("__aurorae__"))) {
            const QString separator("__");
            const QString themeName = decorationTheme.section(separator, -1, -1);
            const QString themeType = decorationTheme.section(separator, -2, -2);
            QString themePath = QStandardPaths::locate(QStandardPaths::GenericDataLocation, QString("aurorae/themes/") + themeName, QStandardPaths::LocateDirectory);
            if (!themePath.isEmpty()) {
                m_auroraeDecorationPath = themePath;
                m_auroraeDecorationType = themeType;
                emit auroraeThemePathChanged();
                emit auroraeThemeTypeChanged();
                return;
            }
        }
    }
    m_auroraeDecorationPath = QString();
    emit auroraeThemePathChanged();
}

QString AppMenuApplet::auroraeThemePath() const
{
    return m_auroraeDecorationPath;
}

QString AppMenuApplet::auroraeThemeType() const
{
    return m_auroraeDecorationType;
}

QString AppMenuApplet::extensionForTheme(const QString &themeDirectoryPath)
{
    if (themeDirectoryPath.isEmpty()) {
        return QString();
    }
    qDebug() << "determine theme extension from path " << themeDirectoryPath;
    QDir themeDir(themeDirectoryPath);
    QStringList nameFilters(QString("close.svgz"));
    QStringList filteredFiles = themeDir.entryList(nameFilters);
    qDebug() << "filtered: " << filteredFiles;
    if (!filteredFiles.isEmpty()) {
        return QString("svgz");
    }
    return QString("svg");
}

QString AppMenuApplet::translateThemePath(const QString &themeDirectoryPath)
{
    qDebug() << "translating path " << themeDirectoryPath;
    return KShell::tildeExpand(themeDirectoryPath);
}

void AppMenuApplet::registerService()
{
    qDebug() << "registering appmenu service";
    ++s_refs;
    //if we're the first, regster the service
    if (s_refs == 1) {
        qDebug() << " -> connecting to DBus";
        QDBusConnection::sessionBus().interface()->registerService(s_viewService,
                QDBusConnectionInterface::QueueService,
                QDBusConnectionInterface::DontAllowReplacement);
    }
}

void AppMenuApplet::unregisterService()
{
    qDebug() << "unregistering from appmenu service";
    //if we were the last, unregister
    if (--s_refs == 0) {
        qDebug() << " -> disconnecting from DBus";
        QDBusConnection::sessionBus().interface()->unregisterService(s_viewService);
    }
    if (s_refs < 0) {
        s_refs = 0;
    }
}

bool AppMenuApplet::enabled() const
{
    return m_enabled;
}

void AppMenuApplet::setEnabled(bool enabled)
{
    if (enabled == m_enabled) {
        return;
    }
    if (enabled) {
        registerService();
    } else {
        unregisterService();
    }
    m_enabled = enabled;
}

void AppMenuApplet::setModel(AppMenuModel *model)
{
    if (m_model != model) {
        m_model = model;
        emit modelChanged();
    }
}

int AppMenuApplet::view() const
{
    return m_viewType;
}

void AppMenuApplet::setView(int type)
{
    if (m_viewType != type) {
        m_viewType = type;
        emit viewChanged();
    }
}

int AppMenuApplet::currentIndex() const
{
    return m_currentIndex;
}

void AppMenuApplet::setCurrentIndex(int currentIndex)
{
    if (m_currentIndex != currentIndex) {
        m_currentIndex = currentIndex;
        emit currentIndexChanged();
   }
}

QQuickItem *AppMenuApplet::buttonGrid() const
{
    return m_buttonGrid;
}

void AppMenuApplet::setButtonGrid(QQuickItem *buttonGrid)
{
    if (m_buttonGrid != buttonGrid) {
        m_buttonGrid = buttonGrid;
        emit buttonGridChanged();
    }
}

QMenu *AppMenuApplet::createMenu(int idx) const
{
    QMenu *menu = nullptr;
    QAction *action = nullptr;

    if (view() == CompactView) {
       menu = new QMenu();
       for (int i=0; i<m_model->rowCount(); i++) {
           const QModelIndex index = m_model->index(i, 0);
           const QVariant data = m_model->data(index, AppMenuModel::ActionRole);
           action = (QAction *)data.value<void *>();
           menu->addAction(action);
       }
       menu->setAttribute(Qt::WA_DeleteOnClose);
   } else if (view() == FullView) {
        const QModelIndex index = m_model->index(idx, 0);
        const QVariant data = m_model->data(index, AppMenuModel::ActionRole);
        action = (QAction *)data.value<void *>();
        if (action) {
           menu = action->menu();
        }
    }

    return menu;
}

void AppMenuApplet::onMenuAboutToHide()
{
    setCurrentIndex(-1);
}

void AppMenuApplet::trigger(QQuickItem *ctx, int idx)
{
    if (m_currentIndex == idx) {
        return;
    }

    if (!ctx || !ctx->window() || !ctx->window()->screen()) {
        return;
    }

    QMenu *actionMenu = createMenu(idx);
    if (actionMenu) {

        //this is a workaround where Qt will fail to realise a mouse has been released
        // this happens if a window which does not accept focus spawns a new window that takes focus and X grab
        // whilst the mouse is depressed
        // https://bugreports.qt.io/browse/QTBUG-59044
        // this causes the next click to go missing

        //by releasing manually we avoid that situation
        auto ungrabMouseHack = [ctx]() {
            if (ctx && ctx->window() && ctx->window()->mouseGrabberItem()) {
                // FIXME event forge thing enters press and hold move mode :/
                ctx->window()->mouseGrabberItem()->ungrabMouse();
            }
        };

        QTimer::singleShot(0, ctx, ungrabMouseHack);
        //end workaround

        const auto &geo = ctx->window()->screen()->availableVirtualGeometry();

        QPoint pos = ctx->window()->mapToGlobal(ctx->mapToScene(QPointF()).toPoint());
        if (location() == Plasma::Types::TopEdge) {
            pos.setY(pos.y() + ctx->height());
        }

        actionMenu->adjustSize();

        pos = QPoint(qBound(geo.x(), pos.x(), geo.x() + geo.width() - actionMenu->width()),
                             qBound(geo.y(), pos.y(), geo.y() + geo.height() - actionMenu->height()));

        if (view() == FullView) {
            actionMenu->installEventFilter(this);
        }

        actionMenu->winId();//create window handle
        actionMenu->windowHandle()->setTransientParent(ctx->window());

        actionMenu->popup(pos);

        if (view() == FullView) {
            // hide the old menu only after showing the new one to avoid brief flickering
            // in other windows as they briefly re-gain focus
            QMenu *oldMenu = m_currentMenu;
            m_currentMenu = actionMenu;
            if (oldMenu && oldMenu != actionMenu) {
                //! dont trigger initialization of index because there is a new menu created
                disconnect(oldMenu, &QMenu::aboutToHide, this, &AppMenuApplet::onMenuAboutToHide);
                
                oldMenu->hide();
            }
        }

        setCurrentIndex(idx);

        // FIXME TODO connect only once
        connect(actionMenu, &QMenu::aboutToHide, this, &AppMenuApplet::onMenuAboutToHide, Qt::UniqueConnection);
        return;
    }
}

// FIXME TODO doesn't work on submenu
bool AppMenuApplet::eventFilter(QObject *watched, QEvent *event)
{
    auto *menu = qobject_cast<QMenu *>(watched);
    if (!menu) {
        return false;
    }

    if (event->type() == QEvent::KeyPress) {
        auto *e = static_cast<QKeyEvent *>(event);

        // TODO right to left languages
        if (e->key() == Qt::Key_Left) {
            int desiredIndex = m_currentIndex - 1;
            emit requestActivateIndex(desiredIndex);
            return true;
        } else if (e->key() == Qt::Key_Right) {
            if (menu->activeAction() && menu->activeAction()->menu()) {
                return false;
            }

            int desiredIndex = m_currentIndex + 1;
            emit requestActivateIndex(desiredIndex);
            return true;
        }

    } else if (event->type() == QEvent::MouseMove) {
        auto *e = static_cast<QMouseEvent *>(event);

        if (!m_buttonGrid || !m_buttonGrid->window()) {
            return false;
        }

        // FIXME the panel margin breaks Fitt's law :(
        const QPointF &windowLocalPos = m_buttonGrid->window()->mapFromGlobal(e->globalPos());
        const QPointF &buttonGridLocalPos = m_buttonGrid->mapFromScene(windowLocalPos);
        auto *item = m_buttonGrid->childAt(buttonGridLocalPos.x(), buttonGridLocalPos.y());
        if (!item) {
            return false;
        }

        bool ok;
        const int buttonIndex = item->property("buttonIndex").toInt(&ok);
        if (!ok) {
            return false;
        }

        emit requestActivateIndex(buttonIndex);
    }

    return false;
}

K_EXPORT_PLASMA_APPLET_WITH_JSON(appmenu, AppMenuApplet, "metadata.json")

#include "appmenuapplet.moc"
