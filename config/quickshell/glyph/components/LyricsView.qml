import QtQuick
import qs
import qs.components
import qs.services

Item {
    id: root

     ListView {
        id: lv
        visible: Lyrics.status === "ok"
        anchors.fill: parent
        clip: true
        interactive: false
        model: Lyrics.lines
        currentIndex: Math.max(0, Lyrics.index)
        // keep the current line in the middle; the view glides there instead of jumping
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: height / 2 - 15
        preferredHighlightEnd: height / 2 + 15
        highlightMoveDuration: 350
        // a new song: start at its first line, no long scroll from the old position
        onCountChanged: positionViewAtIndex(Math.max(0, currentIndex), ListView.Center)

        delegate: Text {
            required property int index
            required property var modelData
            readonly property bool now: index === lv.currentIndex
            width: lv.width
            height: 30
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: modelData.s
            font { family: Theme.ui; pixelSize: 22; weight: Font.DemiBold }
            color: now ? Theme.fg : Theme.grey
            // size, brightness and colour ease between lines too
            scale: now ? 1 : 0.7
            opacity: now ? 1 : Math.abs(index - lv.currentIndex) === 1 ? 0.6 : 0.3
            Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 250 } }
            Behavior on color { ColorAnimation { duration: 250 } }
        }
    }

    Flickable {
        visible: Lyrics.status === "plain"
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: pt.height
        boundsBehavior: Flickable.StopAtBounds
        Text {
            id: pt
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.PlainText
            text: Lyrics.plain
            font { family: Theme.ui; pixelSize: 15 }
            color: Theme.grey
        }
    }

    Lb {
        visible: ["idle", "loading", "none", "instrumental", "error", "skip"].includes(Lyrics.status)
	anchors.centerIn: parent
	text: ({ idle: "fetching…", loading: "fetching…", none: "no lyrics for this track", instrumental: "instrumental", error: "couldn't reach lrclib.net", skip: "lyrics: spotify only" })[Lyrics.status] ?? ""
    }
}
