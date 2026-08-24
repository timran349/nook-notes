import SwiftUI

public struct NoteListView: View {
    @ObservedObject var noteStore: NoteStore
    public var onSelectNote: (Note) -> Void

    @State private var selectedTab: String = "Items"
    @State private var selectedColorFilter: NoteColor? = nil

    @State private var noteToRename: Note?
    @State private var renameText: String = ""
    @State private var showRenameAlert: Bool = false

    private var filteredNotesList: [Note] {
        var base = noteStore.filteredNotes
        if selectedTab == "Notebooks" {
            base = base.filter { $0.isDetached }
        } else if selectedTab == "Canvases" {
            base = base.filter { $0.color == .lavender || $0.color == .mint }
        }
        if let colorFilter = selectedColorFilter {
            base = base.filter { $0.color == colorFilter }
        }
        return base
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Folder-style Tab Bar matching reference image
            HStack(spacing: 3) {
                CleanFolderTabButton(
                    title: "Items",
                    iconName: "doc.text.fill",
                    isSelected: selectedTab == "Items"
                ) {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                        selectedTab = "Items"
                    }
                }

                CleanFolderTabButton(
                    title: "Notebooks",
                    iconName: "book.closed.fill",
                    isSelected: selectedTab == "Notebooks"
                ) {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                        selectedTab = "Notebooks"
                    }
                }

                CleanFolderTabButton(
                    title: "Canvases",
                    iconName: "square.grid.2x2.fill",
                    isSelected: selectedTab == "Canvases"
                ) {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                        selectedTab = "Canvases"
                    }
                }

                Spacer()

                // "+ Add" Button
                Button(action: {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                        let newNote = noteStore.createNote()
                        onSelectNote(newNote)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text("Add")
                            .font(.geist(11, weight: .semibold))
                    }
                    .foregroundColor(.primary.opacity(0.85))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primary.opacity(0.06))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 10)
            }
            .padding(.leading, 10)
            .padding(.top, 4)
            .zIndex(1)

            // Content Panel Frame connected seamlessly to active folder tab
            VStack(spacing: 10) {
                // Category Dots Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterDotChip(
                            label: "All",
                            color: nil,
                            count: noteStore.notes.count,
                            isSelected: selectedColorFilter == nil
                        ) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                selectedColorFilter = nil
                            }
                        }

                        ForEach(NoteColor.allCases, id: \.self) { c in
                            let count = noteStore.notes.filter { $0.color == c }.count
                            FilterDotChip(
                                label: c.tagLabel,
                                color: c.accentBorder,
                                count: count,
                                isSelected: selectedColorFilter == c
                            ) {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                    selectedColorFilter = selectedColorFilter == c ? nil : c
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                }

                // Cards List
                if filteredNotesList.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "note.text")
                            .font(.system(size: 28, weight: .thin))
                            .foregroundColor(.secondary.opacity(0.5))

                        Text("No matching notes")
                            .font(.geist(13, weight: .medium))
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(filteredNotesList) { note in
                                NoteRowView(
                                    note: note,
                                    isSelected: noteStore.selectedNoteId == note.id,
                                    onSelect: {
                                        noteStore.selectedNoteId = note.id
                                        onSelectNote(note)
                                    },
                                    onDelete: {
                                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                            noteStore.deleteNote(id: note.id)
                                        }
                                    },
                                    onRename: {
                                        noteToRename = note
                                        renameText = note.title
                                        showRenameAlert = true
                                    },
                                    onDetach: {
                                        DetachedStickyManager.shared.detachNote(note, noteStore: noteStore)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.75)
            )
            .padding(.horizontal, 6)
            .padding(.bottom, 6)
        }
        .alert("Rename Note", isPresented: $showRenameAlert) {
            TextField("Note Title", text: $renameText)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if var target = noteToRename {
                    target.title = renameText
                    noteStore.updateNote(target)
                }
            }
        }
    }
}

// Clean Folder Tab Button with rounded top edges matching reference image
struct CleanFolderTabButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(
                        colorScheme == .dark
                            ? (isSelected ? .white : .white.opacity(0.55))
                            : (isSelected ? Color(red: 0.22, green: 0.17, blue: 0.12) : Color(red: 0.42, green: 0.35, blue: 0.28))
                    )

                Text(title)
                    .font(.geist(12, weight: isSelected ? .bold : .medium))
                    .foregroundColor(
                        colorScheme == .dark
                            ? (isSelected ? .white : .white.opacity(0.7))
                            : (isSelected ? Color(red: 0.22, green: 0.17, blue: 0.12) : Color(red: 0.42, green: 0.35, blue: 0.28))
                    )
            }
            .padding(.horizontal, 14)
            .padding(.top, 7)
            .padding(.bottom, 6)
            .background(
                RoundedCornerShape(radius: 10, corners: [.topLeft, .topRight])
                    .fill(
                        isSelected
                            ? (colorScheme == .dark ? Color(red: 0.22, green: 0.20, blue: 0.18) : Color(red: 0.96, green: 0.94, blue: 0.89))
                            : (colorScheme == .dark ? Color(red: 0.15, green: 0.14, blue: 0.13) : Color(red: 0.88, green: 0.83, blue: 0.76))
                    )
            )
            .overlay(
                RoundedCornerShape(radius: 10, corners: [.topLeft, .topRight])
                    .stroke(
                        isSelected
                            ? Color.primary.opacity(0.18)
                            : Color.primary.opacity(0.08),
                        lineWidth: 0.75
                    )
            )
            .shadow(
                color: isSelected ? Color.black.opacity(0.06) : Color.clear,
                radius: 2,
                x: 0,
                y: -1
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Rounded Corner Shape for clean tab corners
struct RoundedCornerShape: Shape {
    var radius: CGFloat = 10
    var corners: RectCorner = [.topLeft, .topRight]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tl = corners.contains(.topLeft) ? radius : 0
        let tr = corners.contains(.topRight) ? radius : 0

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        if tl > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                radius: tl,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
        }
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                radius: tr,
                startAngle: .degrees(270),
                endAngle: .degrees(360),
                clockwise: false
            )
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Category Dot Chip matching reference image left sidebar dots
struct FilterDotChip: View {
    let label: String
    let color: Color?
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let color = color {
                    Circle()
                        .fill(color)
                        .frame(width: 7, height: 7)
                }

                Text(label)
                    .font(.geist(11, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)

                Text("\(count)")
                    .font(.geist(10, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isSelected ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.primary.opacity(0.2) : Color.clear, lineWidth: 0.75)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
