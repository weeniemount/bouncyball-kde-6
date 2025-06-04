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


import QtQuick
import QtQuick.Layouts
import QtMultimedia

import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3

PlasmoidItem {
    id: main

    property var units: Kirigami.Units
    property var theme: Kirigami.Theme
    property rect screenGeometry: Qt.rect(0, 0, Screen.width, Screen.height)

    fullRepresentation: ((Plasmoid.location !== PlasmaCore.Types.Desktop
    && Plasmoid.location !== PlasmaCore.Types.Floating) ? errorComponent : null)

    Layout.minimumWidth: units.gridUnit * 10
    Layout.minimumHeight: units.gridUnit * 10

    onXChanged: ball.bouncing = false
    onYChanged: ball.bouncing = false
    onWidthChanged: ball.bouncing = false
    onHeightChanged: ball.bouncing = false
    onVisibleChanged: ball.bouncing = false

    property int collisionSounds: 0
    readonly property string collisionSoundUrl: Qt.resolvedUrl("../sounds/bounce.ogg")
    readonly property rect availableScreenRect: {
        if (ball.bouncing) {
            return Qt.rect(0, 0, Screen.width, Screen.height)
        }
        return Qt.rect(x, y, width, height)
    }

    Component {
        id: errorComponent

        Kirigami.Heading {
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

    Component {
        id: collisionSoundComponent

        MediaPlayer {
            id: collisionSound

            source: collisionSoundUrl

            autoPlay: true
        }
    }

    Timer {
        id: physicsTick

        property bool even: false

        interval: Plasmoid.configuration.tickLength
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            print("Timer triggered, ball.bouncing:", ball.bouncing)
            ball.bounce()
        }
    }

    Rectangle {
        id: ballSocket

        width: Math.min(main.width, main.height)
        height: width

        anchors.centerIn: parent

        border.width: 2
        border.color: theme.textColor

        color: theme.backgroundColor

        opacity: 1

        radius: width / 2
    }

    Kirigami.Heading {
        id: returnHint

        anchors.fill: ballSocket
        anchors.margins: units.gridUnit

        visible: Plasmoid.configuration.showHelpTexts && ball.bouncing

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

    KSvg.SvgItem {
        id: ball

        width: Math.min(main.width, main.height) - (2 * ballSocket.border.width) - 5
        height: width

        property bool bouncing: false
        property bool everBounced: false
        property point velocity: Qt.point(0, 0)
        property real gravity: Plasmoid.configuration.gravity
        property real friction: Plasmoid.configuration.friction
        property real restitution: Plasmoid.configuration.restitution
        property var time
        property real angularVelocity: 0
        property real angle: 0

        rotation: (360 * angle / 6.28)

        Component.onCompleted: {
            print("Ball component loaded")
        }

        onXChanged: !ballMouseArea.containsPress || ballMouseArea.grabGlobalMousePos()
        onYChanged: !ballMouseArea.containsPress || ballMouseArea.grabGlobalMousePos()

        onBouncingChanged: {
            console.log("Bouncing changed:", bouncing)
            if (bouncing) {
                everBounced = true
                physicsTick.start()
            } else {
                physicsTick.stop()
                angle = 0
            }
        }

        imagePath: Qt.resolvedUrl("../images/bball.svgz")

        function bounce() {
            if (ballMouseArea.containsPress) {
                ballMouseArea.snapshotMousePos()
                return
            }

            if (!time) {
                time = new Date().getTime()
            }

            var dT = Math.min((new Date().getTime() - time) / 1000.0, 0.5)
            time = new Date().getTime()

            if (Plasmoid.configuration.autoBounce && Math.random() < 1.0/35) {
                var strength = Plasmoid.configuration.autoBounceStrength
                velocity = Qt.point(
                    velocity.x + (((Math.random() * 1000) - 500) * strength * 0.5),
                                    velocity.y + (((Math.random() * 1000) - 500) * strength * 0.5)
                )
            }

            velocity = Qt.point(
                velocity.x,
                velocity.y + (main.availableScreenRect.height * gravity * dT)
            )
            velocity = Qt.point(
                velocity.x * (1.0 - 2 * friction * dT),
                                velocity.y * (1.0 - 2 * friction * dT)
            )

            var newX = ball.x + (velocity.x * dT)
            var newY = ball.y + (velocity.y * dT)

            var collision = false
            var bottom = false

            if ((newY + height) >= (main.availableScreenRect.y + main.availableScreenRect.height) && velocity.y > 0) {
                newY = (main.availableScreenRect.y + main.availableScreenRect.height) - height
                velocity = Qt.point(velocity.x, velocity.y * -restitution)
                angularVelocity = velocity.x / (ball.width / 2)
                collision = true
                bottom = true
            }

            if (newY <= main.availableScreenRect.y && velocity.y < 0) {
                newY = main.availableScreenRect.y
                velocity = Qt.point(velocity.x, velocity.y * -restitution)
                angularVelocity = -velocity.x / (ball.width / 2)
                collision = true
            }

            if ((newX + width) >= (main.availableScreenRect.x + main.availableScreenRect.width) && velocity.x > 0) {
                newX = (main.availableScreenRect.x + main.availableScreenRect.width) - width - 0.1
                velocity = Qt.point(velocity.x * -restitution, velocity.y)
                angularVelocity = -velocity.y / (ball.width / 2)

                if (bottom) {
                    velocity = Qt.point(0, velocity.y)
                }

                collision = true
            }

            if (newX <= main.availableScreenRect.x && velocity.x < 0) {
                newX = main.availableScreenRect.x + 0.1
                velocity = Qt.point(velocity.x * -restitution, velocity.y)
                angularVelocity = velocity.y / (width / 2)

                if (bottom) {
                    velocity = Qt.point(0, velocity.y)
                }

                collision = true
            }

            angularVelocity = angularVelocity * (0.9999 - 2 * friction * dT)

            if (!Plasmoid.configuration.autoBounce
                && Math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y) < 10
                && Math.abs(angularVelocity) < 0.1) {
                physicsTick.stop()
                return
                }

                if (Plasmoid.configuration.playSound) {
                    if (collision
                        && main.collisionSounds <= Plasmoid.configuration.maxConcurrentSounds
                        && (velocity.x || velocity.y)
                        && Math.abs(angularVelocity)
                        && Math.round(newY) != Math.round(y)) {
                        collisionSoundComponent.createObject(main)
                        }
                }

                x = newX
                y = newY
                angle += angularVelocity * dT
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
                    z: 0
                }
            },
            State {
                name: "bouncing"
                when: ball.bouncing

                ParentChange {
                    target: ball
                    parent: main.parent?.parent?.parent?.parent?.parent?.parent?.parent || null
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

        Kirigami.Heading {
            id: dragHint

            anchors.fill: parent
            anchors.margins: units.gridUnit

            visible: Plasmoid.configuration.showHelpTexts && !ball.everBounced && !ball.bouncing && ballMouseArea.containsMouse

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

            property int dragOffsetX: 0
            property int dragOffsetY: 0
            property int globalMouseX: 0
            property int globalMouseY: 0
            property int mouseAtLastTickX: 0
            property int mouseAtLastTickY: 0

            drag.target: ball
            drag.minimumX: 0
            drag.maximumX: main.availableScreenRect.width - ball.width
            drag.minimumY: 0
            drag.maximumY: main.availableScreenRect.height - ball.height

            hoverEnabled: true

            onPressed: function(event) {
                if (!ball.bouncing) {
                    ball.bouncing = true
                }

                ball.angularVelocity = 0
                ball.time = null

                snapshotMousePos()
                physicsTick.start()
            }

            onReleased: function(event) {
                ball.bouncing = true

                var globalPos = ballMouseArea.mapToGlobal(event.x, event.y)
                var step = physicsTick.interval / 2 / 1000
                ball.velocity = Qt.point(
                    (globalPos.x - mouseAtLastTickX) / step,
                                         (globalPos.y - mouseAtLastTickY) / step
                )
                ball.bounce()
                physicsTick.start()
            }

            onPositionChanged: function(event) {
                dragOffsetX = event.x
                dragOffsetY = event.y
            }

            onDoubleClicked: function(event) {
                ball.bouncing = false
            }

            function grabGlobalMousePos() {
                if (!ball || !ball.parent) return
                    var globalPos = ball.parent.mapToGlobal(ball.x || 0, ball.y || 0)
                    globalMouseX = globalPos.x + dragOffsetX
                    globalMouseY = globalPos.y + dragOffsetY
            }

            function snapshotMousePos() {
                mouseAtLastTickX = globalMouseX
                mouseAtLastTickY = globalMouseY
            }
        }
    }
}
