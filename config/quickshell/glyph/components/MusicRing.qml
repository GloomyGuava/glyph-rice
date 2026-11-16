import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import qs
import qs.components
import qs.services

// bar button: a music note (or your own picture) inside a 270° progress ring. Click opens the player card.
Item {
    id: root
    property real size: 36
    signal clicked()

    readonly property var player: Media.player
    // no length (some browsers): empty ring
    readonly property real f: player?.lengthSupported && player.length > 0 ? Math.min(1, Media.position / player.length) : 0
    // drop a picture here: ~/.config/glyph/avatar.png (any common format)
    readonly property url pic: "file://" + Quickshell.env("HOME") + "/.config/glyph/avatar.png"

    visible: !!player
    width: size
    height: size

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath { // track: 270°, the gap at the bottom
            strokeColor: Theme.s3
            strokeWidth: 3
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: root.size / 2; centerY: root.size / 2; radiusX: root.size / 2 - 2; radiusY: root.size / 2 - 2; startAngle: 135; sweepAngle: 270 }
        }
        ShapePath { // progress
            strokeColor: root.f > 0 ? (Media.playing ? Theme.accent : Theme.grey) : "transparent"
            strokeWidth: 3
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: root.size / 2; centerY: root.size / 2; radiusX: root.size / 2 - 2; radiusY: root.size / 2 - 2; startAngle: 135; sweepAngle: 270 * root.f }
        }
    }

    Item {
        anchors.centerIn: parent
        width: root.size - 12
        height: width
        Image {
            id: img
            anchors.fill: parent
            source: root.pic
            sourceSize: Qt.size(128, 128)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: false
            layer.enabled: true
        }
        Rectangle { id: mask; anchors.fill: parent; radius: width / 2; visible: false; layer.enabled: true }
        MultiEffect {
            anchors.fill: parent
            source: img
            maskEnabled: true
            maskSource: mask
            visible: img.status === Image.Ready
        }
        Icon { anchors.centerIn: parent; visible: img.status !== Image.Ready; text: "\u{F075A}"; font.pixelSize: root.size * 0.42; color: Theme.fg }
    }

    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.clicked() }
}
