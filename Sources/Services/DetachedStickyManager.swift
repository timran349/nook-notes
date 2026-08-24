import AppKit
import SwiftUI

public class StickyPanel: NSPanel {
    override public var canBecomeKey: Bool { true }
    override public var canBecomeMain: Bool { true }
}

public class DetachedStickyManager: ObservableObject {
    public static let shared = DetachedStickyManager()

    private var activeWindows: [UUID: StickyPanel] = [:]

    public init() {}

    public func detachNote(_ note: Note, noteStore: NoteStore) {
        if let existing = activeWindows[note.id] {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        var target = note
        target.isDetached = true

        let defaultWidth: CGFloat = target.detachedWidth ?? 260
        let defaultHeight: CGFloat = target.detachedHeight ?? 260

        let mouseLoc = NSEvent.mouseLocation
        let originX: CGFloat = target.detachedX ?? (mouseLoc.x - defaultWidth / 2)
        let originY: CGFloat = target.detachedY ?? (mouseLoc.y - defaultHeight / 2)

        let initialRect = NSRect(x: originX, y: originY, width: defaultWidth, height: defaultHeight)

        let panel = StickyPanel(
            contentRect: initialRect,
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.minSize = NSSize(width: 200, height: 180)

        let stickyView = StandaloneStickyView(
            noteId: note.id,
            noteStore: noteStore,
            onDock: { [weak self] in
                self?.dockNote(note.id, noteStore: noteStore)
            },
            onDelete: { [weak self] in
                self?.deleteNote(note.id, noteStore: noteStore)
            }
        )

        panel.contentView = NSHostingView(rootView: stickyView)
        activeWindows[note.id] = panel

        target.detachedX = initialRect.origin.x
        target.detachedY = initialRect.origin.y
        target.detachedWidth = initialRect.size.width
        target.detachedHeight = initialRect.size.height
        noteStore.updateNote(target)

        panel.makeKeyAndOrderFront(nil)

        // Observe frame moves/resizes to save coordinates
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak noteStore] notification in
            guard let win = notification.object as? NSWindow,
                  let store = noteStore,
                  var n = store.notes.first(where: { $0.id == note.id }) else { return }
            n.detachedX = win.frame.origin.x
            n.detachedY = win.frame.origin.y
            store.updateNote(n)
        }

        NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: panel,
            queue: .main
        ) { [weak noteStore] notification in
            guard let win = notification.object as? NSWindow,
                  let store = noteStore,
                  var n = store.notes.first(where: { $0.id == note.id }) else { return }
            n.detachedWidth = win.frame.size.width
            n.detachedHeight = win.frame.size.height
            store.updateNote(n)
        }
    }

    public func dockNote(_ id: UUID, noteStore: NoteStore) {
        guard let panel = activeWindows[id] else { return }
        if var note = noteStore.notes.first(where: { $0.id == id }) {
            note.isDetached = false
            noteStore.updateNote(note)
        }
        panel.close()
        activeWindows.removeValue(forKey: id)
    }

    public func deleteNote(_ id: UUID, noteStore: NoteStore) {
        if let panel = activeWindows[id] {
            panel.close()
            activeWindows.removeValue(forKey: id)
        }
        noteStore.deleteNote(id: id)
    }

    public func syncDetachedWindows(noteStore: NoteStore) {
        for note in noteStore.notes where note.isDetached {
            detachNote(note, noteStore: noteStore)
        }
    }
}
