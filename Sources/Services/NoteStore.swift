import Foundation
import Combine
import SwiftUI

public class NoteStore: ObservableObject {
    @Published public var notes: [Note] = [] {
        didSet {
            scheduleSave()
        }
    }

    @Published public var selectedNoteId: UUID?
    @Published public var searchQuery: String = ""
    @Published public var isSearching: Bool = false
    @Published public var appAppearance: String = "system" { // "system", "light", "dark"
        didSet {
            UserDefaults.standard.set(appAppearance, forKey: "nook_appearance")
            updateAppAppearance()
        }
    }
    @Published public var alwaysOnTop: Bool = true {
        didSet {
            UserDefaults.standard.set(alwaysOnTop, forKey: "nook_always_on_top")
        }
    }

    private let fileURL: URL
    private var saveCancellable: AnyCancellable?
    private let saveSubject = PassthroughSubject<Void, Never>()

    public init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let nookFolder = appSupport.appendingPathComponent("NookNotes", isDirectory: true)

        try? FileManager.default.createDirectory(at: nookFolder, withIntermediateDirectories: true)
        self.fileURL = nookFolder.appendingPathComponent("notes.json")

        self.appAppearance = UserDefaults.standard.string(forKey: "nook_appearance") ?? "system"
        if UserDefaults.standard.object(forKey: "nook_always_on_top") != nil {
            self.alwaysOnTop = UserDefaults.standard.bool(forKey: "nook_always_on_top")
        }

        loadNotes()
        setupDebouncedSave()
        updateAppAppearance()
    }

    // MARK: - Actions

    @discardableResult
    public func createNote(title: String = "", content: String = "") -> Note {
        let newNote = Note(title: title, content: content)
        notes.insert(newNote, at: 0)
        selectedNoteId = newNote.id
        return newNote
    }

    public func updateNote(_ updatedNote: Note) {
        if let index = notes.firstIndex(where: { $0.id == updatedNote.id }) {
            var noteToUpdate = updatedNote
            noteToUpdate.updatedAt = Date()
            notes[index] = noteToUpdate

            // Keep notes sorted by updatedAt descending
            notes.sort { $0.updatedAt > $1.updatedAt }
        }
    }

    public func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        if selectedNoteId == id {
            selectedNoteId = notes.first?.id
        }
    }

    public var selectedNote: Note? {
        get {
            guard let id = selectedNoteId else { return nil }
            return notes.first(where: { $0.id == id })
        }
        set {
            if let newValue = newValue {
                updateNote(newValue)
            }
        }
    }

    public var filteredNotes: [Note] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            return notes.sorted { $0.updatedAt > $1.updatedAt }
        }
        return notes.filter {
            $0.title.lowercased().contains(query) ||
            $0.content.lowercased().contains(query)
        }.sorted { $0.updatedAt > $1.updatedAt }
    }

    public var groupedNotes: [(category: DateCategory, notes: [Note])] {
        let filtered = filteredNotes
        let grouped = Dictionary(grouping: filtered, by: { $0.dateCategory })

        return DateCategory.allCases.compactMap { category in
            if let notesForCategory = grouped[category], !notesForCategory.isEmpty {
                return (category: category, notes: notesForCategory)
            }
            return nil
        }
    }

    // MARK: - Persistence & Debouncing

    private func setupDebouncedSave() {
        saveCancellable = saveSubject
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.saveNotesImmediately()
            }
    }

    private func scheduleSave() {
        saveSubject.send()
    }

    private func saveNotesImmediately() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to save notes: \(error)")
        }
    }

    private func loadNotes() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Seed welcome note on first launch
            let welcomeNote = Note(
                title: "Welcome to Nook Notes",
                content: "Nook Notes is your quiet, always-available macOS scratchpad.\n\n• Cmd + N creates a new note instantly\n• Cmd + F toggles search\n• Cmd + Shift + Space opens Nook from anywhere\n• Esc closes Nook or returns to your note list\n\nDraft thoughts, task lists, and quick code snippets effortlessly.",
                createdAt: Date(),
                updatedAt: Date()
            )
            self.notes = [welcomeNote]
            self.selectedNoteId = welcomeNote.id
            saveNotesImmediately()
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let loaded = try JSONDecoder().decode([Note].self, from: data)
            self.notes = loaded.sorted { $0.updatedAt > $1.updatedAt }
            self.selectedNoteId = self.notes.first?.id
        } catch {
            print("Failed to load notes: \(error)")
            self.notes = []
        }
    }

    private func updateAppAppearance() {
        DispatchQueue.main.async {
            switch self.appAppearance {
            case "light":
                NSApp.appearance = NSAppearance(named: .aqua)
            case "dark":
                NSApp.appearance = NSAppearance(named: .darkAqua)
            default:
                NSApp.appearance = nil // System default
            }
        }
    }
}
