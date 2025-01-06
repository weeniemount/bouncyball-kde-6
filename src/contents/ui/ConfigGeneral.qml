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
    property alias cfg_tickLength: tickLength.value

    property alias cfg_playSound: playSound.checked
    property alias cfg_soundVolume: soundVolume.value
    property alias cfg_maxConcurrentSounds: maxConcurrentSounds.value

    property alias cfg_autoBounce: autoBounce.checked
    property alias cfg_autoBounceStrength: autoBounceStrength.value

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

                        // HACK: Poor man's table layout.
                        width: Math.max(gravityLabel.implicitWidth,
                            frictionLabel.implicitWidth,
                            restitutionLabel.implicitWidth,
                            tickLengthLabel.implicitWidth,
                            soundVolumeLabel.implicitWidth,
                            maxConcurrentSoundsLabel.implicitWidth,
                            autoBounceStrengthLabel.implicitWidth)

                        text: i18n("Gravity: ")
                    }

                    SpinBox {
                        id: gravity

                        decimals: 2

                        stepSize: 0.1
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

                        stepSize: 0.1
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

                        stepSize: 0.1
                    }
                }

                Row {
                    Label {
                        id: tickLengthLabel

                        width: gravityLabel.width

                        text: i18n("Tick length: ")
                    }

                    SpinBox {
                        id: tickLength

                        suffix: i18n(" ms")

                        minimumValue: 16
                        maximumValue: 50
                        stepSize: 1
                    }
                }
            }
        }

        GroupBox {
            id: playSound

            Layout.fillWidth: true

            title: i18n("Sound")

            checkable: true

            flat: true

            ColumnLayout {
                Row {
                    Label {
                        id: soundVolumeLabel

                        width: gravityLabel.width

                        text: i18n("Volume: ")
                    }

                    Slider {
                        id: soundVolume

                        minimumValue: 0.0
                        maximumValue: 1.0
                        stepSize: 0.1

                        tickmarksEnabled: true
                    }
                }

                Row {
                    Label {
                        id: maxConcurrentSoundsLabel

                        width: gravityLabel.width

                        text: i18n("Max concurrent sounds: ")
                    }

                    SpinBox {
                        id: maxConcurrentSounds

                        stepSize: 1
                        minimumValue: 1
                        maximumValue: 5
                    }
                }
            }
        }

        GroupBox {
            id: autoBounce

            Layout.fillWidth: true

            title: i18n("Auto-bounce")

            checkable: true

            flat: true

            Row {
                Label {
                    id: autoBounceStrengthLabel

                    width: gravityLabel.width

                    text: i18n("Strength: ")
                }

                Slider {
                    id: autoBounceStrength

                    minimumValue: 0
                    maximumValue: 100
                    stepSize: 10

                    tickmarksEnabled: true
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Miscellaneous")

            flat: true

            CheckBox {
                id: showHelpTexts

                text: i18n("Show help texts")
            }
        }
    }
}
