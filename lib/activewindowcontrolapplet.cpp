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

#include "activewindowcontrolapplet.h"
#include "../plugin/appmenumodel.h"

#include <QAction>
#include <QKeyEvent>
#include <QMenu>
#include <QMouseEvent>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>
#include <QDBusConnection>

ActiveWindowControlApplet::ActiveWindowControlApplet(QObject *parent, const QVariantList &data)
    : Plasma::Applet(parent, data)
{
}

ActiveWindowControlApplet::~ActiveWindowControlApplet() = default;

void ActiveWindowControlApplet::init()
{
    // TODO Wayland PlasmaShellSurface stuff
    QDBusConnection::sessionBus().connect(QStringLiteral("org.kde.kappmenu"),
                                          QStringLiteral("/KAppMenu"),
                                          QStringLiteral("org.kde.kappmenu"),
                                          QStringLiteral("reconfigured"),
                                          this, SLOT(updateAppletEnabled()));
    updateAppletEnabled();
}

AppMenuModel *ActiveWindowControlApplet::model() const
{
    return m_model;
}

void ActiveWindowControlApplet::setModel(AppMenuModel *model)
{
    if (m_model != model) {
        m_model = model;
        emit modelChanged();
    }
}

int ActiveWindowControlApplet::view() const
{
    return m_viewType;
}

void ActiveWindowControlApplet::setView(int type)
{
    if (m_viewType != type) {
        m_viewType = type;
        emit viewChanged();
    }
}

int ActiveWindowControlApplet::currentIndex() const
{
    return m_currentIndex;
}

void ActiveWindowControlApplet::setCurrentIndex(int currentIndex)
{
    if (m_currentIndex != currentIndex) {
        m_currentIndex = currentIndex;
        emit currentIndexChanged();
   }
}

QQuickItem *ActiveWindowControlApplet::buttonGrid() const
{
    return m_buttonGrid;
}

void ActiveWindowControlApplet::setButtonGrid(QQuickItem *buttonGrid)
{
    if (m_buttonGrid != buttonGrid) {
        m_buttonGrid = buttonGrid;
        emit buttonGridChanged();
    }
}

bool ActiveWindowControlApplet::appletEnabled() const
{
    return m_appletEnabled;
}

void ActiveWindowControlApplet::updateAppletEnabled()
{
    KConfigGroup config(KSharedConfig::openConfig(QStringLiteral("kdeglobals")), QStringLiteral("Appmenu Style"));
    const QString &menuStyle = config.readEntry(QStringLiteral("Style"));

    const bool enabled = (menuStyle == QLatin1String("Widget"));

    if (m_appletEnabled != enabled) {
        m_appletEnabled = enabled;
        emit appletEnabledChanged();
    }
}

QMenu *ActiveWindowControlApplet::createMenu(int idx) const
{
    QMenu *menu = nullptr;
    QAction *action = nullptr;

    if (!m_model) {
        qDebug() << "model not available";
        return menu;
    }

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

void ActiveWindowControlApplet::onMenuAboutToHide()
{
    setCurrentIndex(-1);
}

void ActiveWindowControlApplet::trigger(QQuickItem *ctx, int idx)
{
    if (m_currentIndex == idx) {
        return;
    }

    QMenu *actionMenu = createMenu(idx);
    if (actionMenu) {

        if (ctx && ctx->window() && ctx->window()->mouseGrabberItem()) {
            // FIXME event forge thing enters press and hold move mode :/
            ctx->window()->mouseGrabberItem()->ungrabMouse();
        }

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

        actionMenu->popup(pos);

        if (view() == FullView) {
            // hide the old menu only after showing the new one to avoid brief flickering
            // in other windows as they briefly re-gain focus
            QMenu *oldMenu = m_currentMenu;
            m_currentMenu = actionMenu;
            if (oldMenu && oldMenu != actionMenu) {
                oldMenu->hide();
            }
        }

        setCurrentIndex(idx);

        // FIXME TODO connect only once
        connect(actionMenu, &QMenu::aboutToHide, this, &ActiveWindowControlApplet::onMenuAboutToHide, Qt::UniqueConnection);
        return;
    }
}

// FIXME TODO doesn't work on submenu
bool ActiveWindowControlApplet::eventFilter(QObject *watched, QEvent *event)
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

K_EXPORT_PLASMA_APPLET_WITH_JSON(activewindowcontrol, ActiveWindowControlApplet, "metadata.json")

#include "activewindowcontrolapplet.moc"
