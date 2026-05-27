pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Searcher {
    id: root

    function transformSearch(search: string): string {
        if (search.startsWith("c ")) return search.slice(2);
        return search;
    }

    list: variants.instances
    useFuzzy: true

    Variants {
        id: variants
        model: root.items
        ClipboardModel {}
    }

    component ClipboardModel: QtObject {
        required property var modelData
        readonly property string itemId: modelData.id
        readonly property string content: modelData.content
        readonly property string raw: modelData.raw
        readonly property string name: modelData.content
    }

    property list<var> items: []

    Process {
        id: proc
        property list<string> buffer: []
        command: ["cliphist", "list"]
        stdout: SplitParser {
            onRead: line => proc.buffer.push(line)
        }
        onExited: {
            console.log("[Clipboard] cliphist list returned " + proc.buffer.length + " lines.");
            root.items = proc.buffer.map(l => {
                const parts = l.split("\t");
                return {
                    raw: l,
                    id: parts[0],
                    content: parts.slice(1).join("\t")
                };
            });
            proc.buffer = [];
        }
    }

    function reload() {
        console.log("[Clipboard] Reloading cliphist data...");
        proc.running = true;
    }
}
