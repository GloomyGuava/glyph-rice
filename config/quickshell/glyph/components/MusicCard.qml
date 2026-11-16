import QtQuick
import qs
import qs.components
import qs.services

Item {
    id: root
    property bool active: true
    readonly property var player: Media.player
    readonly property bool lyr: Theme.state.lyrics
    implicitHeight: 210 + (lyr ? 160 : 0)

    Binding { target: Lyrics; property: "active"; value: root.active && root.lyr }

    Item {
        id: top
        width: parent.width
        height: 210

        Item {
            id: art
            x: 26
            anchors.verticalCenter: parent.verticalCenter
            width: 150
            height: 150
            property real turn: 0
            Timer { running: root.active && Media.playing; interval: 33; repeat: true; onTriggered: art.turn = (art.turn + 360 / 14 / 30) % 360 }
            Art { anchors.fill: parent; rotation: art.turn; url: root.player?.trackArtUrl ?? ""; step: 6 }
        }
        Column {
            anchors { left: art.right; leftMargin: 26; right: parent.right; rightMargin: 26; verticalCenter: parent.verticalCenter }
            Lb { text: `now playing · ${root.player?.identity ?? "silence"}`; width: parent.width; elide: Text.ElideRight }
            Text {
                width: parent.width
                topPadding: 10
                elide: Text.ElideRight
                textFormat: Text.PlainText
                text: root.player?.trackTitle || "Nothing on"
                font { family: Theme.ui; pixelSize: 26; weight: Font.DemiBold }
                color: Theme.fg
            }
            Text {
                width: parent.width
                elide: Text.ElideRight
                textFormat: Text.PlainText
                text: root.player?.trackArtist ?? ""
                font { family: Theme.ui; pixelSize: 15 }
                color: Theme.grey
            }
            Item { width: 1; height: 16 }
            PacBar { width: parent.width; playing: Media.playing; f: root.player?.lengthSupported && root.player.length > 0 ? Media.position / root.player.length : 0 }
            Item { width: 1; height: 14 }
            Controls { size: 22; play: 52 }
        }

        Rectangle {
            id: lbtn
            anchors { right: parent.right; rightMargin: 26; bottom: parent.bottom; bottomMargin: 24 }
            width: 36
            height: 36
            radius: Theme.corner(10)
            color: root.lyr ? Theme.fg : lh.hovered ? Theme.s3 : Theme.s2
            Behavior on color { ColorAnimation { duration: Theme.t } }
            Text {
                anchors.centerIn: parent
                text: "Aa"
                font { family: Theme.ui; pixelSize: 16; weight: Font.DemiBold }
                color: root.lyr ? Theme.ink : Theme.grey
            }
            HoverHandler { id: lh; cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: Theme.state.lyrics = !Theme.state.lyrics }
        }
    }

    LyricsView {
        visible: root.lyr
        x: 26
        y: 204
        width: parent.width - 52
        height: 148
    }
}
