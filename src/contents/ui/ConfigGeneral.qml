/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

Item {
    id: configGeneral

    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_gravity: gravity.value
    property alias cfg_friction: friction.value
    property alias cfg_restitution: restitution.value
    property alias cfg_showHelpTexts: showHelpTexts.checked

    ColumnLayout {
        GroupBox {
            Layout.fillWidth: true

            title: i18n("Physics")

            flat: true

            ColumnLayout {
                Row {
                    Label {
                        id: gravityLabel

                        width: Math.max(gravityLabel.implicitWidth, frictionLabel.implicitWidth, restitutionLabel.implicitWidth) // HACK: Poor man's table layout.

                        text: i18n("Gravity: ")
                    }

                    SpinBox {
                        id: gravity

                        decimals: 2
                    }
                }

                Row {
                    Label {
                        id: frictionLabel

                        width: gravityLabel.width

                        text: i18n("Friction: ")
                    }

                    SpinBox {
                        id: friction

                        decimals: 2
                    }
                }

                Row {
                    Label {
                        id: restitutionLabel

                        width: gravityLabel.width

                        text: i18n("Restitution: ")
                    }

                    SpinBox {
                        id: restitution

                        decimals: 2
                    }
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Options")

            flat: true

            CheckBox {
                id: showHelpTexts

                text: i18n("Show help texts")
            }
        }
    }
}
