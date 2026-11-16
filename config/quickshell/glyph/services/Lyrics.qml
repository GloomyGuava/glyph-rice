pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// lyrics from lrclib.net; fetched only while the music card is open with lyrics on (the card sets `active`)
Singleton {
    id: root

    property bool active: false
    readonly property var player: Media.player
    readonly property string key: player ? `${player.trackArtist}\n${player.trackTitle}\n${player.trackAlbum}\n${Math.round(player.length)}` : ""

    property string status: "idle"   // idle | loading | ok | plain | none | instrumental | error
    property var lines: []           // [{ t: seconds, s: "text" }]
    property string plain: ""
    property string loadedKey: ""
    property string fetchKey: ""

    // lyrics are looked up only for these players (matched against the MPRIS name and desktop entry, lowercase)
    readonly property var only: ["spotify"]
    readonly property bool allowed: {
        const id = ((player?.identity ?? "") + " " + (player?.desktopEntry ?? "")).toLowerCase();
        return only.some(n => id.includes(n));
    }
    onAllowedChanged: {
        if (!allowed) { proc.running = false; lines = []; plain = ""; loadedKey = ""; status = "skip"; }
        deb.restart();
    }

    // the line being sung: the last one whose time has come (a little look-ahead, the position is polled twice a second)
    readonly property int index: {
        const p = Media.position + 0.3, ls = lines;
        let lo = 0, hi = ls.length - 1, r = -1;
        while (lo <= hi) {
            const m = (lo + hi) >> 1;
            if (ls[m].t <= p) { r = m; lo = m + 1; } else hi = m - 1;
        }
        return r;
    }

    onActiveChanged: { if (!active) proc.running = false; deb.restart(); }
    onKeyChanged: {
        if (key !== loadedKey) { lines = []; plain = ""; status = allowed ? "idle" : "skip"; }
        deb.restart();
    }
    Timer { id: deb; interval: 400; onTriggered: root.fetch() }

    function parse(synced) {
        const out = [];
        for (const l of synced.split("\n")) {
            const m = /^\[(\d+):(\d+(?:\.\d+)?)\]\s*(.*)$/.exec(l);
            if (m) out.push({ t: +m[1] * 60 + +m[2], s: m[3] || "·" });
        }
        return out;
    }

    function fetch() {
        if (!active || !allowed || !player?.trackTitle || key === loadedKey) return;
	proc.running = false;
        fetchKey = key;
        status = "loading";
        ask("get");
    }

    function ask(mode) {
        const p = player;
        proc.mode = mode;
        proc.args = mode === "get"
            ? ["--data-urlencode", "track_name=" + p.trackTitle, "--data-urlencode", "artist_name=" + p.trackArtist,
               "--data-urlencode", "album_name=" + p.trackAlbum, "--data-urlencode", "duration=" + Math.round(p.length),
               "https://lrclib.net/api/get"]
            : ["--data-urlencode", "track_name=" + p.trackTitle, "--data-urlencode", "artist_name=" + p.trackArtist,
               "https://lrclib.net/api/search"];
        proc.running = true;
    }

    function use(o) {
        loadedKey = fetchKey;
        if (!o) { status = "none"; return; }
        if (o.instrumental) { status = "instrumental"; return; }
        if (o.syncedLyrics) {
            lines = parse(o.syncedLyrics);
            if (lines.length) { status = "ok"; return; }
        }
        if (o.plainLyrics) { plain = o.plainLyrics; status = "plain"; return; }
        status = "none";
    }

    function done(mode, text) {
        if (fetchKey !== key) return; // the track changed meanwhile
        let o = null;
        try { o = JSON.parse(text); } catch (e) { status = "error"; return; }
        if (mode === "get") {
            if (o && o.id) use(o);
            else ask("search");
            return;
        }
        const list = Array.isArray(o) ? o : [], len = player?.length ?? 0;
        use(list.find(x => x.syncedLyrics && (!len || Math.abs((x.duration ?? 0) - len) <= 3)) ?? list.find(x => x.plainLyrics) ?? null);
    }

    Process {
        id: proc
        property string mode: "get"
        property var args: []
        command: ["curl", "-sG", "--max-time", "8", "-A", "glyph-shell"].concat(args)
        stdout: StdioCollector { onStreamFinished: root.done(proc.mode, text) }
    }
}
