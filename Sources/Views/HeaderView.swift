import SwiftUI
import AppKit

public struct HeaderView: View {
    @ObservedObject var noteStore: NoteStore
    @ObservedObject var windowManager: WindowManager
    public var isEditing: Bool
    public var onBack: () -> Void

    public init(
        noteStore: NoteStore,
        windowManager: WindowManager,
        isEditing: Bool,
        onBack: @escaping () -> Void
    ) {
        self.noteStore = noteStore
        self.windowManager = windowManager
        self.isEditing = isEditing
        self.onBack = onBack
    }

    public var body: some View {
        HStack(alignment: .center) {
            if isEditing {
                Button(action: onBack) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .bold))
                        Text("Notes")
                            .font(.geist(13, weight: .semibold))
                    }
                    .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Branding Header at top left: "Nook Notes"
                Text("Nook Notes")
                    .font(.geist(16, weight: .bold))
                    .foregroundColor(.primary)
            }

            Spacer()

            // Header actions: Settings & Collapse
            HStack(spacing: 12) {
                if isEditing {
                    Button(action: {
                        if let selectedId = noteStore.selectedNoteId {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                noteStore.deleteNote(id: selectedId)
                                onBack()
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete Note")
                }

                Button(action: {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                        windowManager.isSettingsPresented.toggle()
                    }
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                        .foregroundColor(windowManager.isSettingsPresented ? .accentColor : .secondary.opacity(0.8))
                        .rotationEffect(.degrees(windowManager.isSettingsPresented ? 45 : 0))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Settings")

                Button(action: {
                    windowManager.collapsePanel()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Collapse (Esc)")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }
}
