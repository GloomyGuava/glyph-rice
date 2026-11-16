import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.components

// a tray item's menu, drawn by us: rows, separators, check marks; a row with children opens them, the first row goes back
PopupWindow {
    id: win

    required property var trayItem
    required property Item target     // the icon it opens from
    required property var parentWin   // the bar window
    signal closed()

    readonly property bool vert: Theme.state.barAt !== "top"
    property var cur: trayItem.menu
    property var stack: []

    function pick(e) {
        if (e.hasChildren) { stack = stack.concat([cur]); cur = e; }
        else { e.triggered(); closed(); }
    }
    function back() { cur = stack[stack.length - 1]; stack = stack.slice(0, -1); }

    visible: true
    color: "transparent"
    // under the icon on a top bar (its right edge to the icon's), beside the bar on a side bar
    anchor.item: target
    anchor.rect: vert ? Qt.rect(Theme.barRight ? -36 : target.width + 36, 0, 1, 1) : Qt.rect(target.width, target.height + 14, 1, 1)
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: vert ? Edges.Top | (Theme.barRight ? Edges.Left : Edges.Right) : Edges.Bottom | Edges.Left
    implicitWidth: Math.ceil(260 * Theme.s)
    implicitHeight: Math.ceil(card.height * Theme.s)

    HyprlandFocusGrab { windows: [win, win.parentWin]; active: win.visible; onCleared: win.closed() }
    QsMenuOpener { id: op; menu: win.cur }

    Stage {
        Rectangle {
            id: card
            width: 260
            height: col.implicitHeight + 20
            radius: Theme.corner(24)
            color: Theme.s1
            border { width: 1; color: Theme.s2 }

            Column {
                id: col
                x: 10
                y: 10
                width: parent.width - 20
                spacing: 2

                Item {
                    visible: win.stack.length > 0
                    width: col.width
                    height: 34
                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.corner(12)
                        color: bh.hovered ? Theme.s2 : "transparent"
                        Text {
                            x: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "‹  back"
                            font { family: Theme.ui; pixelSize: 14 }
                            color: Theme.grey
                        }
                        HoverHandler { id: bh; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: win.back() }
                    }
                }

                Repeater {
                    model: op.children
                    Item {
                        id: row
                        required property var modelData
                        width: col.width
                        height: modelData.isSeparator ? 9 : 34

                        Rectangle { visible: row.modelData.isSeparator; anchors.centerIn: parent; width: parent.width - 16; height: 1; color: Theme.s3 }
                        Rectangle {
                            visible: !row.modelData.isSeparator
                            anchors.fill: parent
                            radius: Theme.corner(12)
                            color: rh.hovered && row.modelData.enabled ? Theme.s2 : "transparent"
                            Text {
                                x: 12
                                anchors.verticalCenter: parent.verticalCenter
                                textFormat: Text.PlainText
                                text: row.modelData.checkState === Qt.Checked ? "✓" : ""
                                font { family: Theme.ui; pixelSize: 13 }
                                color: Theme.fg
                            }
                            // other apps' strings: plain text only
                            Text {
                                anchors { left: parent.left; leftMargin: 32; right: parent.right; rightMargin: 28; verticalCenter: parent.verticalCenter }
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                                text: row.modelData.text
                                font { family: Theme.ui; pixelSize: 14 }
                                color: row.modelData.enabled ? Theme.fg : Theme.mute
                            }
                            Text {
                                visible: row.modelData.hasChildren
                                anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                text: "›"
                                font { family: Theme.ui; pixelSize: 16 }
                                color: Theme.grey
                            }
                            HoverHandler { id: rh; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: if (row.modelData.enabled) win.pick(row.modelData) }
                        }
                    }
                }
            }
        }
    }
}
