import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import qs
import qs.components

// the system tray: left click — the app's action, right click — its menu, middle click — its secondary action
Pile {
    id: root
    spacing: 10
    // apps whose left click does nothing useful: it opens their menu instead (matched against the item's id)
    property var menuOnLeft: ["spotify"]

    Repeater {
        model: SystemTray.items
        Item {
            id: ic
            required property var modelData
            readonly property var win: QsWindow.window
            width: 20
            height: 20

            Image {
                id: img
                anchors.fill: parent
                source: ic.modelData.icon
                sourceSize: Qt.size(40, 40)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: false
                layer.enabled: true
            }
            MultiEffect {
                anchors.fill: parent
                source: img
                saturation: hov.hovered ? 0 : -1
                Behavior on saturation { NumberAnimation { duration: 150 } }
            }
            HoverHandler { id: hov }

            Loader {
                id: menuL
                active: false
                sourceComponent: TrayMenu {
                    trayItem: ic.modelData
                    target: ic
                    parentWin: ic.win
                    onClosed: menuL.active = false
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    const it = ic.modelData;
                    console.log("tray click:", mouse.button, it.id, "hasMenu", it.hasMenu, "onlyMenu", it.onlyMenu); // temporary
                    const menuFirst = it.hasMenu && (it.onlyMenu || root.menuOnLeft.some(n => it.id.toLowerCase().includes(n)));
                    if (mouse.button === Qt.RightButton) {
                        if (it.hasMenu) menuL.active = !menuL.active;
                        else it.secondaryActivate();
                    } else if (mouse.button === Qt.MiddleButton) it.secondaryActivate();
                    else if (menuFirst) menuL.active = !menuL.active;
                    else it.activate();
                }
            }
        }
    }
}
