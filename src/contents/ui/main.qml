/*******************************************************************************
 *   Copyright (C) 2008 by Thomas Gillespie <tomjamesgillespie@googlemail.com> *
 *   Copyright (C) 2010 by Enrico Ros <enrico.ros@gmail.com>                   *
 *   Copyright (C) 2017 by Eike Hein <hein@kde.org>                            *
 *                                                                             *
 *   This program is free software; you can redistribute it and/or modify      *
 *   it under the terms of the GNU General Public License as published by      *
 *   the Free Software Foundation; either version 2 of the License, or         *
 *   (at your option) any later version.                                       *
 *                                                                             *
 *   This program is distributed in the hope that it will be useful,           *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 *   GNU General Public License for more details.                              *
 *                                                                             *
 *   You should have received a copy of the GNU General Public License         *
 *   along with this program; if not, write to the                             *
 *   Free Software Foundation, Inc.,                                           *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .            *
 ******************************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: main

    Plasmoid.backgroundHints: "NoBackground";

    Plasmoid.fullRepresentation: ((plasmoid.location != PlasmaCore.Types.Desktop
        && plasmoid.location != PlasmaCore.Types.Floating) ? errorComponent : null)

    Layout.minimumWidth: units.gridUnit * 10
    Layout.minimumHeight: units.gridUnit * 10

    onXChanged: ball.bouncing = false
    onYChanged: ball.bouncing = false
    onWidthChanged: ball.bouncing = false
    onHeightChanged: ball.bouncing = false
    onVisibleChanged: ball.bouncing = false

    Component {
        id: errorComponent

        PlasmaExtras.Heading {
            id: desktopHint

            Layout.minimumWidth: implicitWidth + (2 * units.gridUnit)
            Layout.minimumHeight: implicitHeight + (2 * units.gridUnit)

            level: 3

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            textFormat: Text.PlainText
            wrapMode: Text.WordWrap
            elide: Text.ElideMiddle

            text: i18n("Bouncy Ball only works on the desktop, sorry!")
        }
    }

    Timer {
        id: physicsTick

        interval: 20
        repeat: true

        onTriggered: ball.bounce()
    }

    Rectangle {
        id: ballSocket

        width: Math.min(main.width, main.height)
        height: width

        anchors.centerIn: parent

        border.width: 2 * units.devicePixelRatio
        border.color: theme.foregroundColor

        color: theme.backgroundColor

        opacity: 0.5

        radius: width / 2
    }

    PlasmaExtras.Heading {
        id: returnHint

        anchors.fill: ballSocket
        anchors.margins: units.gridUnit

        visible: plasmoid.configuration.showHelpTexts && ball.bouncing

        level: 3

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        elide: Text.ElideMiddle

        text: i18n("Click to\n return ball!")
    }

    MouseArea {
        anchors.fill: parent

        enabled: ball.bouncing

        onClicked: ball.bouncing = false
    }

    PlasmaCore.SvgItem {
        id: ball

        width: Math.min(main.width, main.height) - (2 * ballSocket.border.width) - (5 * units.devicePixelRatio)
        height: width

        property bool bouncing: false
        property bool everBounced: false

        property var gravity: plasmoid.configuration.gravity * units.devicePixelRatio
        property var friction: plasmoid.configuration.friction
        property var restitution: plasmoid.configuration.restitution
        property var velocity: Qt.vector2d(0, 0)
        property var angularVelocity: 0
        property var angle: 0
        property var time: null

        rotation: (360 * angle / 6.28)

        onBouncingChanged: {
            if (bouncing) {
                everBounced = true;
            } else {
                angle = 0;
            }
        }

        svg: PlasmaCore.Svg {
            imagePath: Qt.resolvedUrl("../images/bball.svgz")
        }

        function bounce() {
            if (!bouncing || ballMouseArea.containsPress) {
                return;
            }

            var dT = Math.min((new Date().getTime() - time) / 1000.0, 0.5);
            time = new Date().getTime();

            velocity = Qt.vector2d(velocity.x, velocity.y + (plasmoid.availableScreenRect.height * gravity * dT));
            velocity = Qt.vector2d(velocity.x * (1.0 - 2 * friction * dT), velocity.y * (1.0 - 2 * friction * dT));

            var newX = x + ((velocity.x * dT) / units.devicePixelRatio);
            var newY = y + ((velocity.y * dT) / units.devicePixelRatio);

            var collision = false;
            var bottom = false;

            if ((newY + height) >= (plasmoid.availableScreenRect.y + plasmoid.availableScreenRect.height) && velocity.y > 0) {
                newY = (plasmoid.availableScreenRect.height.y + plasmoid.availableScreenRect.height) - height;
                velocity = Qt.vector2d(velocity.x, velocity.y * -restitution);
                angularVelocity = velocity.x / (width / 2);
                collision = true;
                bottom = true;
            }

            if (newY <= plasmoid.availableScreenRect.y && velocity.y < 0) {
                newY = plasmoid.availableScreenRect.y;
                velocity = Qt.vector2d(velocity.x, velocity.y * -restitution);
                angularVelocity = -velocity.x / (width / 2);
                collision = true;
            }

            if ((newX + width) >= (plasmoid.availableScreenRect.x + plasmoid.availableScreenRect.width) && velocity.x > 0) {
                newX = (plasmoid.availableScreenRect.x + plasmoid.availableScreenRect.width) - width - 0.1;
                velocity = Qt.vector2d(velocity.x * -restitution, velocity.y);
                angularVelocity = -velocity.y / (width / 2);

                if (bottom) {
                    velocity = Qt.vector2d(0, velocity.y);
                }

                collision = true;
            }

            if (newX <= plasmoid.availableScreenRect.x && velocity.x < 0) {
                newX = plasmoid.availableScreenRect.x = 0.1;
                velocity = Qt.vector2d(velocity.x * -restitution, velocity.y);
                angularVelocity = velocity.y / (width / 2);

               if (bottom) {
                    velocity = Qt.vector2d(0, velocity.y);
                }

                collision = true;
            }

            angularVelocity = angularVelocity * (0.9999 - 2 * friction * dT);

            if (velocity.length() < 10.0 && Math.abs(angularVelocity) < 0.1) {
                physicsTick.stop();

                newY = (plasmoid.availableScreenRect.height.y + plasmoid.availableScreenRect.height) - height;
            }

            x = newX;
            y = newY;
            angle += angularVelocity * dT;
        }

        states: [
            State {
                name: "resting"
                when: !ball.bouncing

                ParentChange {
                    target: ball
                    parent: main
                }

                AnchorChanges {
                    target: ball
                    anchors.horizontalCenter: main.horizontalCenter
                    anchors.verticalCenter: main.verticalCenter
                }

                PropertyChanges {
                    target: ball
                    z: undefined
                }
            },
            State {
                name: "bouncing"
                when: ball.bouncing

                ParentChange {
                    target: ball
                    parent: main.parent.parent.parent.parent.parent.parent.parent // HACK: Desktop containment
                }

                AnchorChanges {
                    target: ball
                    anchors.horizontalCenter: undefined
                    anchors.verticalCenter: undefined
                }

                PropertyChanges {
                    target: ball
                    z: 999
                }
            }
        ]

        PlasmaExtras.Heading {
            id: dragHint

            anchors.fill: parent
            anchors.margins: units.gridUnit

            visible: plasmoid.configuration.showHelpTexts && !ball.everBounced && !ball.bouncing && ballMouseArea.containsMouse

            level: 3

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            textFormat: Text.PlainText
            wrapMode: Text.WordWrap
            elide: Text.ElideMiddle

            text: i18n("Drag me to\n start bouncing!")
        }

        MouseArea {
            id: ballMouseArea

            anchors.fill: parent

            property int pressX
            property int pressY

            drag.target: ball

            hoverEnabled: true

            onPressed: {
                if (!ball.bouncing) {
                    ball.bouncing = true;
                }

                var globalPos = ballMouseArea.mapToGlobal(mouse.x, mouse.y);
                pressX = globalPos.x;
                pressY = globalPos.y;

                ball.velocity = Qt.vector2d(0, 0);
                ball.angularVelocity = 0;
                ball.time = new Date().getTime();

                physicsTick.stop();
            }

            onReleased: {
                var globalPos = ballMouseArea.mapToGlobal(mouse.x, mouse.y);
                ball.velocity = Qt.vector2d((pressX - globalPos.x) / 0.020,
                                            (pressY - globalPos.y) / 0.020);

                physicsTick.start();
            }

            onDoubleClicked: {
                ball.bouncing = false;
            }
        }
    }
}
