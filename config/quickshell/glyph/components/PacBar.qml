import QtQuick
import QtQuick.Shapes
import qs

Item {
    id: root
    property real f: 0
    property int n: 24
    property bool playing: true
    height: 14

    readonly property real step: (width - height) / (n - 1)

    Repeater {
        model: root.n
        Rectangle {
            required property int index
            readonly property real cx: root.height / 2 + index * root.step
            visible: cx > pac.x + pac.width / 2
            x: cx - width / 2
            y: (root.height - height) / 2
            width: root.height * 0.3
            height: width
            radius: width / 2
            color: Theme.fg
        }
}
    Rectangle {
        x: root.height / 2
        y: (root.height - height) / 2
        width: pac.x
        height: 2
        radius: 1
        color: Theme.accent
    }
    Shape {
        id: pac
        width: root.height
        height: root.height
        x: root.f * (root.width - root.height)
        Behavior on x { NumberAnimation { duration: 500; easing.type: Easing.Linear } }
        property real mouth: 30
        SequentialAnimation on mouth {
            running: root.playing && root.visible
            loops: Animation.Infinite
            NumberAnimation { to: 4; duration: 180 }
            NumberAnimation { to: 34; duration: 180 }
        }
        ShapePath {
            fillColor: Theme.accent
            strokeColor: "transparent"
            PathAngleArc {
                centerX: pac.width / 2; centerY: pac.height / 2
                radiusX: pac.width / 2; radiusY: pac.height / 2
                startAngle: pac.mouth; sweepAngle: 360 - 2 * pac.mouth
            }
            PathLine { x: pac.width / 2; y: pac.height / 2 }
        }
    }
}
