pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Yoru.Config
import qs.utils

Searcher {
    id: root

    function transformSearch(search: string): string {
        return search.slice(2);
    }

    list: variants.instances
    useFuzzy: true

    Variants {
        id: variants
        model: root.items
        EmojiModel {}
    }

    component EmojiModel: QtObject {
        required property var modelData
        readonly property string emoji: modelData.emoji
        readonly property string desc: modelData.desc
        readonly property string raw: modelData.raw
        readonly property string name: modelData.desc
    }

    property list<var> items: []

    Process {
        id: proc
        property list<string> buffer: []
        command: ["sh", "-c", "sed '1,/^### DATA ###$/d' ~/.config/hypr/hyprland/scripts/fuzzel-emoji.sh"]
        stdout: SplitParser {
            onRead: line => proc.buffer.push(line)
        }
        onExited: {
            root.items = proc.buffer.map(l => {
                const parts = l.split(" ");
                return {
                    raw: l,
                    emoji: parts[0],
                    desc: parts.slice(1).join(" ")
                };
            });
            proc.buffer = [];
        }
    }

    function reload() {
        proc.running = true;
    }
}
