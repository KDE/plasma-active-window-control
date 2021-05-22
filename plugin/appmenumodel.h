/*
    SPDX-FileCopyrightText: 2016 Chinmoy Ranjan Pradhan <chinmoyrp65@gmail.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include <KWindowSystem>
#include <QAbstractListModel>
#include <QAbstractNativeEventFilter>
#include <QPointer>
#include <QStringList>

class QMenu;
class QAction;
class QModelIndex;
class QDBusServiceWatcher;
class KDBusMenuImporter;

class AppMenuModel : public QAbstractListModel, public QAbstractNativeEventFilter
{
    Q_OBJECT

    Q_PROPERTY(bool menuAvailable READ menuAvailable WRITE setMenuAvailable NOTIFY menuAvailableChanged)

public:
    explicit AppMenuModel(QObject *parent = 0);
    ~AppMenuModel();

    enum AppMenuRole {
        MenuRole = Qt::UserRole + 1,
        ActionRole,
    };

    QVariant data(const QModelIndex &index, int role) const Q_DECL_OVERRIDE;
    int rowCount(const QModelIndex &parent = QModelIndex()) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    void updateApplicationMenu(const QString &serviceName, const QString &menuObjectPath);

    bool menuAvailable() const;
    void setMenuAvailable(bool set);

signals:
    void requestActivateIndex(int index);

protected:
    bool nativeEventFilter(const QByteArray &eventType, void *message, long int *result) override;

private Q_SLOTS:
    void onActiveWindowChanged(WId id);
    void update();

signals:
    void menuAvailableChanged();
    void modelNeedsUpdate();

private:
    bool m_menuAvailable;

    WId m_currentWindowId = 0;

    QPointer<QMenu> m_menu;
    QStringList m_activeMenu;
    QList<QAction *> m_activeActions;

    QDBusServiceWatcher *m_serviceWatcher;
    QString m_serviceName;
    QString m_menuObjectPath;

    QPointer<KDBusMenuImporter> m_importer;
};
