import QtQuick
import qs
import qs.components
import qs.services

Item {
    id: root
    property bool active: true
    readonly property var player: Media.player

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
}
