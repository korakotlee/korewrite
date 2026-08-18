import AppKit
import Foundation

/// Represents a serialized snapshot of a single pasteboard item with its associated types and data.
public struct PasteboardItemSnapshot: Equatable, Sendable {
    public let entries: [String: Data]

    public init(entries: [String: Data]) {
        self.entries = entries
    }
}

/// Protocol defining clipboard operations, snapshots, and restorations.
public protocol ClipboardManaging: Sendable {
    func snapshot() -> [PasteboardItemSnapshot]
    func copyText(_ text: String)
    func restoreSnapshot(_ snapshot: [PasteboardItemSnapshot])
}

/// Default implementation of ClipboardManaging using macOS NSPasteboard.
public final class ClipboardManager: ClipboardManaging, @unchecked Sendable {
    private let pasteboard: NSPasteboard

    public init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }

    /// Captures a complete snapshot of all items currently on the pasteboard.
    public func snapshot() -> [PasteboardItemSnapshot] {
        guard let items = pasteboard.pasteboardItems, !items.isEmpty else {
            return []
        }

        var itemSnapshots: [PasteboardItemSnapshot] = []

        for item in items {
            var entries: [String: Data] = [:]
            for type in item.types {
                if let data = item.data(forType: type) {
                    entries[type.rawValue] = data
                }
            }
            if !entries.isEmpty {
                itemSnapshots.append(PasteboardItemSnapshot(entries: entries))
            }
        }

        return itemSnapshots
    }

    /// Clears the pasteboard and sets the provided string.
    public func copyText(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    /// Restores a previous pasteboard snapshot.
    public func restoreSnapshot(_ snapshot: [PasteboardItemSnapshot]) {
        pasteboard.clearContents()

        guard !snapshot.isEmpty else { return }

        var newItems: [NSPasteboardItem] = []
        for itemSnapshot in snapshot {
            let item = NSPasteboardItem()
            for (typeRaw, data) in itemSnapshot.entries {
                let pType = NSPasteboard.PasteboardType(typeRaw)
                item.setData(data, forType: pType)
            }
            newItems.append(item)
        }

        if !newItems.isEmpty {
            pasteboard.writeObjects(newItems)
        }
    }

    /// Performs text replacement: copies text, executes paste action, then restores snapshot after delay.
    public func replaceWithTextAndRestore(
        _ text: String,
        delay: TimeInterval = 0.25,
        performPaste: @escaping () -> Void,
        onComplete: (@Sendable () -> Void)? = nil
    ) {
        let savedSnapshot = snapshot()
        copyText(text)

        performPaste()

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.restoreSnapshot(savedSnapshot)
            onComplete?()
        }
    }
}
