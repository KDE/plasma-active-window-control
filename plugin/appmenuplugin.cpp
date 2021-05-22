/*
    SPDX-FileCopyrightText: 2016 Chinmoy Ranjan Pradhan <chinmoyrp65@gmail.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

#include "appmenuplugin.h"
#include "appmenumodel.h"

#include <QQmlEngine>
#include <QtQml>

void AppmenuPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.private.activeWindowControl"));
    qmlRegisterType<AppMenuModel>(uri, 1, 0, "AppMenuModel");
}
