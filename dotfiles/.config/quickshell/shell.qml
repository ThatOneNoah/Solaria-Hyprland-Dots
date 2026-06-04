import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "."

ShellRoot {
    id: root

    Theme { id: theme }

    property string mainFont: "Mojangles"
    property string iconFont: "Symbols Nerd Font Mono"
    property int barWidth: 78
    property int curveWidth: 2
    property var runningClients: []
    property string runningClientsSignature: ""
    property var pinnedApps: [
        { "label": "firefox", "desktop": "firefox", "iconFile": "/usr/share/icons/hicolor/128x128/apps/firefox.png", "fallback": "󰈹", "command": "firefox" },
        { "label": "steam", "desktop": "com.valvesoftware.Steam", "iconFile": "/var/lib/flatpak/app/com.valvesoftware.Steam/x86_64/stable/active/files/share/icons/hicolor/256x256/apps/com.valvesoftware.Steam.png", "fallback": "", "command": "flatpak run com.valvesoftware.Steam" },
        { "label": "vencord", "desktop": "vesktop", "iconFile": "/usr/share/icons/hicolor/scalable/apps/vesktop.svg", "fallback": "󰙯", "command": "vesktop" },
        { "label": "spotify", "desktop": "com.spotify.Client", "iconFile": "__HOME__/.local/share/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/icons/spotify-linux-128.png", "fallback": "", "command": "flatpak run com.spotify.Client" },
        { "label": "roblox", "desktop": "org.vinegarhq.Sober", "iconFile": "__HOME__/.config/quickshell/icons/roblox.png", "fallback": "󰊖", "command": "flatpak run org.vinegarhq.Sober" }
    ]

    function clean(text, fallback) {
        var out = (text || "").trim();
        return out.length > 0 ? out : fallback;
    }

    function run(command) {
        Hyprland.dispatch("exec " + command);
    }

    function focusToplevel(toplevel) {
        if (!toplevel || !toplevel.address || toplevel.address === "0") return;

        var address = toplevel.address.toString();
        if (address.indexOf("0x") !== 0) address = "0x" + address;
        Hyprland.dispatch("focuswindow address:" + address);
    }

    function toplevelAppId(toplevel) {
        if (!toplevel) return "";

        if (!toplevel.lastIpcObject) {
            return toplevel["class"]
                || toplevel["initialClass"]
                || "";
        }

        return toplevel.lastIpcObject["class"]
            || toplevel.lastIpcObject["initialClass"]
            || "";
    }

    function lookupDesktopEntry(key) {
        var name = (key || "").trim();
        if (name.length === 0) return null;

        var entry = DesktopEntries.byId(name)
            || DesktopEntries.byId(name + ".desktop");

        if (!entry && name.slice(-8) === ".desktop") {
            entry = DesktopEntries.byId(name.slice(0, -8));
        }

        return entry
            || DesktopEntries.heuristicLookup(name)
            || DesktopEntries.heuristicLookup(name.toLowerCase());
    }

    function toplevelDesktopEntry(toplevel) {
        if (!toplevel) return null;

        return root.lookupDesktopEntry(root.toplevelAppId(toplevel))
            || root.lookupDesktopEntry(toplevel.title || "");
    }

    function iconSource(icon) {
        var name = (icon || "").trim();
        if (name.length === 0) return "";
        if (name.indexOf("file:") === 0) return name;
        if (name.indexOf("/") === 0) return "file://" + name;

        return Quickshell.iconPath(name, true) || "";
    }

    function pushUnique(list, value) {
        if (!value || value.length === 0) return;
        if (list.indexOf(value) === -1) list.push(value);
    }

    function pushIconFile(list, path) {
        if (!path || path.length === 0) return;
        root.pushUnique(list, root.iconSource(path));
    }

    function pushIconThemeName(list, name) {
        if (!name || name.length === 0 || root.isGenericIconName(name)) return;

        var iconPath = Quickshell.iconPath(name, true) || "";
        if (iconPath.length > 0) root.pushIconFile(list, iconPath);
    }

    function isGenericIconName(name) {
        var key = (name || "").toLowerCase();
        return key === "application-x-executable"
            || key === "application-x-generic"
            || key === "application-default-icon"
            || key === "applications-other"
            || key === "image-missing"
            || key === "system-run"
            || key === "exec";
    }

    function iconNameVariants(name) {
        var out = [];
        var clean = (name || "").trim();
        if (clean.length === 0 || clean.indexOf("/") === 0) return out;

        if (clean.slice(-8) === ".desktop") clean = clean.slice(0, -8);
        root.pushUnique(out, clean);
        root.pushUnique(out, clean.toLowerCase());
        root.pushUnique(out, clean.replace(/ /g, "-"));

        var parts = clean.split(".");
        if (parts.length > 1) root.pushUnique(out, parts[parts.length - 1]);

        return out;
    }

    function pushHicolorIconCandidates(list, name) {
        if (!name || root.isGenericIconName(name)) return;

        var roots = [
            "/usr/share/icons/hicolor",
            "__HOME__/.local/share/icons/hicolor",
            "/var/lib/flatpak/exports/share/icons/hicolor",
            "__HOME__/.local/share/flatpak/exports/share/icons/hicolor"
        ];
        var dirs = [
            "512x512/apps",
            "256x256/apps",
            "256x256@2/apps",
            "128x128/apps",
            "64x64/apps",
            "48x48/apps",
            "32x32/apps",
            "24x24/apps",
            "22x22/apps",
            "16x16/apps",
            "scalable/apps"
        ];
        var exts = [".png", ".svg", ".svgz", ".xpm"];

        for (var r = 0; r < roots.length; r++) {
            for (var d = 0; d < dirs.length; d++) {
                for (var e = 0; e < exts.length; e++) {
                    root.pushIconFile(list, roots[r] + "/" + dirs[d] + "/" + name + exts[e]);
                }
            }
        }

        root.pushIconFile(list, "/usr/share/pixmaps/" + name + ".png");
        root.pushIconFile(list, "/usr/share/pixmaps/" + name + ".svg");
        root.pushIconFile(list, "/usr/share/pixmaps/" + name + ".xpm");
    }

    function pushFlatpakIconCandidates(list, appId) {
        if (!appId || appId.length === 0) return;

        var roots = [
            "/var/lib/flatpak/app",
            "__HOME__/.local/share/flatpak/app"
        ];
        var sizes = [
            "256x256",
            "128x128",
            "128x128@2",
            "64x64",
            "64x64@2",
            "48x48",
            "32x32",
            "24x24",
            "16x16"
        ];

        for (var r = 0; r < roots.length; r++) {
            var active = roots[r] + "/" + appId + "/x86_64/stable/active";
            for (var s = 0; s < sizes.length; s++) {
                root.pushIconFile(list, active + "/files/share/app-info/icons/flatpak/" + sizes[s] + "/" + appId + ".png");
                root.pushIconFile(list, active + "/files/share/icons/hicolor/" + sizes[s] + "/apps/" + appId + ".png");
                root.pushIconFile(list, active + "/export/share/icons/hicolor/" + sizes[s] + "/apps/" + appId + ".png");
            }
            root.pushIconFile(list, active + "/files/share/icons/hicolor/scalable/apps/" + appId + ".svg");
            root.pushIconFile(list, active + "/export/share/icons/hicolor/scalable/apps/" + appId + ".svg");
        }
    }

    function desktopIconSource(entry, fallbackIcon) {
        return root.iconSource(entry && entry.icon ? entry.icon : fallbackIcon);
    }

    function isRobloxApp(appId, title) {
        var key = ((appId || "") + " " + (title || "")).toLowerCase();
        return key.indexOf("roblox") !== -1
            || key.indexOf("sober") !== -1
            || key.indexOf("vinegar") !== -1;
    }

    function appIconCandidates(toplevel, desktopEntry) {
        var out = [];
        var appId = root.toplevelAppId(toplevel);
        var data = toplevel && toplevel.lastIpcObject ? toplevel.lastIpcObject : (toplevel || {});
        var title = toplevel ? toplevel.title : "";
        var key = (appId + " " + title).toLowerCase();

        if (root.isRobloxApp(appId, title)) {
            root.pushIconFile(out, "__HOME__/.config/quickshell/icons/roblox.png");
            return out;
        }

        if (key.indexOf("firefox") !== -1) root.pushIconFile(out, "/usr/share/icons/hicolor/128x128/apps/firefox.png");
        if (root.appGroupKey(toplevel) === "steam") root.pushIconFile(out, "/var/lib/flatpak/app/com.valvesoftware.Steam/x86_64/stable/active/files/share/icons/hicolor/256x256/apps/com.valvesoftware.Steam.png");
        if (key.indexOf("spotify") !== -1) root.pushIconFile(out, "__HOME__/.local/share/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/icons/spotify-linux-128.png");
        if (key.indexOf("vesktop") !== -1 || key.indexOf("vencord") !== -1 || key.indexOf("discord") !== -1) root.pushIconFile(out, "/usr/share/icons/hicolor/scalable/apps/vesktop.svg");
        if (key.indexOf("ghostty") !== -1 || key.indexOf("terminal") !== -1) root.pushIconFile(out, "/usr/share/icons/hicolor/128x128/apps/com.mitchellh.ghostty.png");
        if (key.indexOf("dolphin") !== -1 || key.indexOf("file") !== -1) root.pushIconFile(out, "/usr/share/icons/hicolor/scalable/apps/org.kde.dolphin.svg");

        var names = [];
        if (desktopEntry && desktopEntry.icon) root.pushUnique(names, desktopEntry.icon);
        if (desktopEntry && desktopEntry.id) root.pushUnique(names, desktopEntry.id);
        if (desktopEntry && desktopEntry.startupClass) root.pushUnique(names, desktopEntry.startupClass);
        root.pushUnique(names, appId);
        root.pushUnique(names, data["initialClass"] || "");
        if (appId.length === 0 && title.length > 0 && title.length < 32) root.pushUnique(names, title);

        for (var n = 0; n < names.length; n++) {
            if (names[n].indexOf("/") === 0) {
                root.pushIconFile(out, names[n]);
                continue;
            }

            var variants = root.iconNameVariants(names[n]);
            for (var v = 0; v < variants.length; v++) {
                root.pushFlatpakIconCandidates(out, variants[v]);
                root.pushHicolorIconCandidates(out, variants[v]);
                root.pushIconThemeName(out, variants[v]);
            }
        }

        return out;
    }

    function appGroupKey(toplevel) {
        var appId = root.toplevelAppId(toplevel);
        var title = toplevel ? toplevel.title : "";
        var key = (appId + " " + title).toLowerCase();

        if (root.isRobloxApp(appId, title)) return "roblox";
        if (key.indexOf("steam") !== -1 || key.indexOf("steamwebhelper") !== -1) return "steam";
        if (key.indexOf("firefox") !== -1) return "firefox";
        if (key.indexOf("spotify") !== -1) return "spotify";
        if (key.indexOf("vesktop") !== -1 || key.indexOf("vencord") !== -1 || key.indexOf("discord") !== -1) return "vencord";

        if (appId.length > 0) return appId.toLowerCase();
        return title.toLowerCase();
    }

    function isVisibleAppToplevel(toplevel) {
        if (!toplevel || !toplevel.address || toplevel.address === "0") return false;

        var data = toplevel.lastIpcObject || toplevel;
        var appId = root.toplevelAppId(toplevel);
        var workspace = data["workspace"] || {};
        var workspaceName = (workspace["name"] || "").toString();

        if (data["mapped"] === false || data["hidden"] === true) return false;
        if (workspaceName.indexOf("special:") === 0) return false;
        if (appId.length === 0) return false;

        return true;
    }

    function isBetterRepresentative(candidate, current) {
        if (!current) return true;

        var candidateFocus = candidate["focusHistoryID"];
        var currentFocus = current["focusHistoryID"];
        if (candidateFocus === undefined || candidateFocus < 0) return false;
        if (currentFocus === undefined || currentFocus < 0) return true;

        return candidateFocus < currentFocus;
    }

    function updateRunningClients(text) {
        var parsed = [];
        try {
            parsed = JSON.parse(text || "[]");
        } catch (error) {
            return;
        }

        var grouped = [];
        var indexes = {};

        for (var i = 0; i < parsed.length; i++) {
            var client = parsed[i];
            if (!root.isVisibleAppToplevel(client)) continue;

            var group = root.appGroupKey(client);
            if (indexes[group] === undefined) {
                indexes[group] = grouped.length;
                grouped.push(client);
            } else if (root.isBetterRepresentative(client, grouped[indexes[group]])) {
                grouped[indexes[group]] = client;
            }
        }

        var signature = "";
        for (var c = 0; c < grouped.length; c++) {
            signature += grouped[c].address + ":"
                + root.toplevelAppId(grouped[c]) + ":"
                + grouped[c].title + ":"
                + grouped[c].focusHistoryID + "|";
        }

        if (signature !== root.runningClientsSignature) {
            root.runningClientsSignature = signature;
            root.runningClients = grouped;
        }
    }

    function refreshStatus() {
        wifiProc.exec(wifiProc.command);
        powerProc.exec(powerProc.command);
        bluetoothProc.exec(bluetoothProc.command);
        volumeProc.exec(volumeProc.command);
    }

    function appIcon(appId, title) {
        var key = ((appId || "") + " " + (title || "")).toLowerCase();
        if (key.indexOf("firefox") !== -1) return "󰈹";
        if (key.indexOf("steam") !== -1) return "";
        if (key.indexOf("spotify") !== -1) return "";
        if (key.indexOf("vesktop") !== -1 || key.indexOf("vencord") !== -1 || key.indexOf("discord") !== -1) return "󰙯";
        if (key.indexOf("ghostty") !== -1 || key.indexOf("terminal") !== -1) return "";
        if (key.indexOf("dolphin") !== -1 || key.indexOf("file") !== -1) return "󰉋";
        return "󰣆";
    }

    function appLabel(appId, title) {
        var key = (appId || title || "app").toLowerCase();
        if (key.indexOf("vesktop") !== -1 || key.indexOf("discord") !== -1) return "vencord";
        if (key.indexOf("firefox") !== -1) return "firefox";
        if (key.indexOf("spotify") !== -1) return "spotify";
        if (key.indexOf("steam") !== -1) return "steam";
        if (key.indexOf("ghostty") !== -1) return "ghostty";
        return key.split(".").pop().slice(0, 8);
    }

    Process {
        id: wifiProc
        command: ["__HOME__/.config/quickshell/scripts/wifi-status.sh"]
        stdout: StdioCollector { id: wifiOut }
    }

    Process {
        id: powerProc
        command: ["__HOME__/.config/quickshell/scripts/power-profile.sh"]
        stdout: StdioCollector { id: powerOut }
    }

    Process {
        id: bluetoothProc
        command: ["__HOME__/.config/quickshell/scripts/bluetooth-status.sh"]
        stdout: StdioCollector { id: bluetoothOut }
    }

    Process {
        id: volumeProc
        command: ["__HOME__/.config/quickshell/scripts/volume-status.sh"]
        stdout: StdioCollector { id: volumeOut }
    }

    Process {
        id: cyclePowerProc
        command: ["__HOME__/.config/quickshell/scripts/cycle-power-profile.sh"]
        onExited: powerProc.exec(powerProc.command)
    }

    Process {
        id: volumeToggleProc
        command: ["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle || pactl set-sink-mute @DEFAULT_SINK@ toggle"]
        onExited: volumeProc.exec(volumeProc.command)
    }

    Process {
        id: volumeUpProc
        command: ["sh", "-c", "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ || pactl set-sink-volume @DEFAULT_SINK@ +5%"]
        onExited: volumeProc.exec(volumeProc.command)
    }

    Process {
        id: volumeDownProc
        command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- || pactl set-sink-volume @DEFAULT_SINK@ -5%"]
        onExited: volumeProc.exec(volumeProc.command)
    }

    Process {
        id: ewwOpenProc
        command: ["__HOME__/.config/eww/scripts/control_hub.sh", "open"]
    }

    Process {
        id: ewwCloseProc
        command: ["__HOME__/.config/eww/scripts/control_hub.sh", "close"]
    }

    Process {
        id: clientsProc
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector { id: clientsOut }
        onExited: root.updateRunningClients(clientsOut.text)
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refreshStatus()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clientsProc.exec(clientsProc.command)
    }

    Component.onCompleted: {
        root.refreshStatus();
        clientsProc.exec(clientsProc.command);
    }

    PanelWindow {
        id: sidePanel
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        implicitWidth: root.barWidth + root.curveWidth
        exclusiveZone: root.barWidth
        color: "transparent"
        aboveWindows: true
        focusable: false

        Rectangle {
            id: rail
            width: root.barWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: theme.bgBar
            border.color: theme.borderSoft
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Rectangle {
                    id: launcher
                    Layout.preferredWidth: 62
                    Layout.preferredHeight: 50
                    radius: 8
                    color: launcherMouse.containsMouse ? theme.bgActiveSoft : theme.bgPanelHigh
                    border.color: launcherMouse.containsMouse ? theme.bgActive : theme.borderSoft
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: root.iconFont
                        font.pixelSize: 24
                        color: launcherMouse.containsMouse ? theme.bgActive : theme.fg
                    }

                    MouseArea {
                        id: launcherMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.run("__HOME__/.local/bin/rofi-launch")
                    }

                    Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 160; easing.type: Easing.OutCubic } }
                }

                Rectangle {
                    Layout.preferredWidth: 62
                    Layout.preferredHeight: 168
                    radius: 8
                    color: theme.bgBarAlt
                    border.color: theme.borderSoft
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 7

                        Repeater {
                            model: 5

                            Rectangle {
                                id: wsBtn
                                property int wsId: index + 1
                                property bool active: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
                                width: 44
                                height: 24
                                radius: 8
                                color: active ? theme.bgActive : (wsMouse.containsMouse ? theme.bgHover : "transparent")
                                border.color: active ? theme.bgActive : theme.borderSoft
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: wsBtn.wsId.toString()
                                    font.family: root.mainFont
                                    font.pixelSize: 11
                                    color: wsBtn.active ? theme.fgOnAccent : theme.fg
                                }

                                MouseArea {
                                    id: wsMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Hyprland.dispatch("workspace " + wsBtn.wsId)
                                }

                                Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.OutCubic } }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 62
                    Layout.preferredHeight: 293
                    radius: 8
                    color: theme.bgBarAlt
                    border.color: theme.borderSoft
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Repeater {
                            model: root.pinnedApps

                            Rectangle {
                                id: pinnedApp
                                property var desktopEntry: root.lookupDesktopEntry(modelData.desktop || modelData.label)
                                property string iconFile: modelData.iconFile
                                    ? root.iconSource(modelData.iconFile)
                                    : root.desktopIconSource(desktopEntry, modelData.fallback || "")
                                width: 50
                                height: 52
                                radius: 8
                                color: pinMouse.containsMouse ? theme.bgHover : "transparent"
                                border.color: pinMouse.containsMouse ? theme.bgActive : "transparent"
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 1

                                    Item {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 24
                                        height: 24

                                        IconImage {
                                            anchors.fill: parent
                                            source: pinnedApp.iconFile
                                            visible: pinnedApp.iconFile !== ""
                                            asynchronous: true
                                            mipmap: true
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: pinnedApp.iconFile === ""
                                            text: modelData.fallback || "󰣆"
                                            font.family: root.iconFont
                                            font.pixelSize: 19
                                            color: pinMouse.containsMouse ? theme.bgActive : theme.fg
                                        }
                                    }

                                    Text {
                                        width: 46
                                        horizontalAlignment: Text.AlignHCenter
                                        text: modelData.label
                                        elide: Text.ElideRight
                                        font.family: root.mainFont
                                        font.pixelSize: 8
                                        color: theme.fgMuted
                                    }
                                }

                                MouseArea {
                                    id: pinMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.run(modelData.command)
                                }

                                Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 62
                    Layout.fillHeight: true
                    Layout.minimumHeight: 72
                    radius: 8
                    color: theme.bgBarAlt
                    border.color: theme.borderSoft
                    border.width: 1
                    clip: true

                    Column {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 7
                        spacing: 5

                        Repeater {
                            model: root.runningClients

                            Rectangle {
                                id: runningApp
                                property bool hasApp: true
                                property bool active: modelData && modelData.focusHistoryID === 0
                                property var desktopEntry: root.toplevelDesktopEntry(modelData)
                                property var iconFiles: root.appIconCandidates(modelData, desktopEntry)
                                property int iconIndex: 0
                                property string iconFile: iconIndex < iconFiles.length ? iconFiles[iconIndex] : ""
                                onIconFilesChanged: iconIndex = 0
                                visible: hasApp
                                width: 50
                                height: hasApp ? 42 : 0
                                radius: 8
                                color: runningApp.active ? theme.bgActiveSoft : (runningMouse.containsMouse ? theme.bgHover : "transparent")
                                border.color: runningApp.active ? theme.bgActive : "transparent"
                                border.width: 1

                                Item {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24

                                    IconImage {
                                        anchors.fill: parent
                                        source: runningApp.iconFile
                                        visible: runningApp.iconFile !== ""
                                        asynchronous: true
                                        mipmap: true
                                        onStatusChanged: {
                                            if (status === Image.Error && runningApp.iconIndex < runningApp.iconFiles.length) {
                                                runningApp.iconIndex += 1;
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: runningApp.iconFile === ""
                                        text: root.appIcon(root.toplevelAppId(modelData), modelData ? modelData.title : "")
                                        font.family: root.iconFont
                                        font.pixelSize: 18
                                        color: runningApp.active ? theme.bgActive : theme.fg
                                    }
                                }

                                MouseArea {
                                    id: runningMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.focusToplevel(modelData)
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 62
                    Layout.preferredHeight: 177
                    radius: 8
                    color: theme.bgBarAlt
                    border.color: theme.borderSoft
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Rectangle {
                            width: 50
                            height: 36
                            radius: 8
                            color: wifiMouse.containsMouse ? theme.bgHover : theme.bgPanelHigh

                            Text {
                                anchors.centerIn: parent
                                width: 46
                                horizontalAlignment: Text.AlignHCenter
                                text: root.clean(wifiOut.text, "󰖪")
                                elide: Text.ElideRight
                                font.family: root.iconFont
                                font.pixelSize: 11
                                color: theme.fg
                            }

                            MouseArea {
                                id: wifiMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.run("sh -c 'nm-connection-editor || ghostty -e nmtui'")
                            }
                        }

                        Rectangle {
                            width: 50
                            height: 36
                            radius: 8
                            color: powerMouse.containsMouse ? theme.bgHover : theme.bgPanelHigh

                            Text {
                                anchors.centerIn: parent
                                width: 46
                                horizontalAlignment: Text.AlignHCenter
                                text: root.clean(powerOut.text, "󰾅")
                                elide: Text.ElideRight
                                font.family: root.iconFont
                                font.pixelSize: 11
                                color: theme.fg
                            }

                            MouseArea {
                                id: powerMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: cyclePowerProc.exec(cyclePowerProc.command)
                            }
                        }

                        Rectangle {
                            width: 50
                            height: 36
                            radius: 8
                            color: btMouse.containsMouse ? theme.bgHover : theme.bgPanelHigh

                            Text {
                                anchors.centerIn: parent
                                width: 46
                                horizontalAlignment: Text.AlignHCenter
                                text: root.clean(bluetoothOut.text, "󰂲")
                                elide: Text.ElideRight
                                font.family: root.iconFont
                                font.pixelSize: 11
                                color: theme.fg
                            }

                            MouseArea {
                                id: btMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.run("sh -c 'blueman-manager || ghostty -e bluetoothctl'")
                            }
                        }

                        Rectangle {
                            width: 50
                            height: 36
                            radius: 8
                            color: volumeMouse.containsMouse ? theme.bgHover : theme.bgPanelHigh

                            Text {
                                anchors.centerIn: parent
                                width: 46
                                horizontalAlignment: Text.AlignHCenter
                                text: root.clean(volumeOut.text, "󰝟 0%")
                                elide: Text.ElideRight
                                font.family: root.iconFont
                                font.pixelSize: 11
                                color: theme.fg
                            }

                            MouseArea {
                                id: volumeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: volumeToggleProc.exec(volumeToggleProc.command)
                                onWheel: wheel => {
                                    if (wheel.angleDelta.y > 0) {
                                        volumeUpProc.exec(volumeUpProc.command);
                                    } else if (wheel.angleDelta.y < 0) {
                                        volumeDownProc.exec(volumeDownProc.command);
                                    }
                                    wheel.accepted = true;
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: clockBox
                    Layout.preferredWidth: 62
                    Layout.preferredHeight: 58
                    radius: 8
                    color: theme.bgPanelHigh
                    border.color: theme.borderSoft
                    border.width: 1

                    property string nowText: Qt.formatTime(new Date(), "hh:mm")
                    property string apText: Qt.formatTime(new Date(), "AP")

                    Column {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            text: clockBox.nowText
                            font.family: root.mainFont
                            font.pixelSize: 13
                            color: theme.fg
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: clockBox.apText
                            font.family: root.mainFont
                            font.pixelSize: 9
                            color: theme.fgMuted
                        }
                    }

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: {
                            clockBox.nowText = Qt.formatTime(new Date(), "hh:mm");
                            clockBox.apText = Qt.formatTime(new Date(), "AP");
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 62
                    Layout.preferredHeight: 42
                    radius: 8
                    color: shutdownMouse.containsMouse ? theme.dangerSoft : theme.bgPanelHigh
                    border.color: shutdownMouse.containsMouse ? theme.danger : theme.borderSoft
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "⏻"
                        font.family: root.mainFont
                        font.pixelSize: 16
                        color: shutdownMouse.containsMouse ? theme.danger : theme.fg
                    }

                    MouseArea {
                        id: shutdownMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.run("sh -c 'wlogout || nwg-bar'")
                    }

                    Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.OutCubic } }
                }
            }
        }

        Rectangle {
            id: railAccent
            anchors.left: rail.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.curveWidth
            color: theme.bgActive
            opacity: 0.64
        }
    }

    PanelWindow {
        id: topTab
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 28
        exclusiveZone: 0
        color: "transparent"
        aboveWindows: true
        focusable: false

        Rectangle {
            id: tab
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
            width: tabMouse.containsMouse ? 230 : 190
            height: tabMouse.containsMouse ? 14 : 8
            radius: 7
            color: theme.bgActive
            opacity: tabMouse.containsMouse ? 0.96 : 0.78
            border.color: theme.fgOnAccent
            border.width: tabMouse.containsMouse ? 1 : 0

            MouseArea {
                id: tabMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onEntered: ewwOpenProc.exec(ewwOpenProc.command)
                onClicked: {
                    if (mouse.button === Qt.RightButton) ewwCloseProc.exec(ewwCloseProc.command);
                    else ewwOpenProc.exec(ewwOpenProc.command);
                }
            }

            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }
    }

    PanelWindow {
        id: topAccent
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 2
        exclusiveZone: 0
        color: "transparent"
        focusable: false

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: root.barWidth
            color: theme.bgActive
            opacity: 0.64
        }
    }

    PanelWindow {
        id: rightAccent
        anchors.top: true
        anchors.right: true
        anchors.bottom: true
        implicitWidth: 2
        exclusiveZone: 0
        color: "transparent"
        focusable: false

        Rectangle {
            anchors.fill: parent
            color: theme.bgActive
            opacity: 0.64
        }
    }

    PanelWindow {
        id: bottomAccent
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 2
        exclusiveZone: 0
        color: "transparent"
        focusable: false

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: root.barWidth
            color: theme.bgActive
            opacity: 0.64
        }
    }
}
