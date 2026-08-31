import SwiftUI

public struct SettingsView: View {
    @ObservedObject var noteStore: NoteStore
    @ObservedObject var launchManager = LaunchAtLoginManager.shared
    @ObservedObject var windowManager: WindowManager
    public var onClose: () -> Void

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.geist(15, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 2)

                Divider().opacity(0.12)

                // Visual Screen Corner Anchor Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("SCREEN CORNER ANCHOR")
                        .font(.geist(10, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.6))

                    // Desktop Screen Mockup Rectangle
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.primary.opacity(0.04))
                            .frame(height: 110)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                            )

                        VStack {
                            HStack {
                                CornerOptionBox(
                                    title: "Top-Left",
                                    cornerID: "top_left",
                                    selectedCorner: $windowManager.screenCorner
                                )
                                Spacer()
                                CornerOptionBox(
                                    title: "Top-Right",
                                    cornerID: "top_right",
                                    selectedCorner: $windowManager.screenCorner
                                )
                            }
                            Spacer()
                            HStack {
                                CornerOptionBox(
                                    title: "Bottom-Left",
                                    cornerID: "bottom_left",
                                    selectedCorner: $windowManager.screenCorner
                                )
                                Spacer()
                                CornerOptionBox(
                                    title: "Bottom-Right",
                                    cornerID: "bottom_right",
                                    selectedCorner: $windowManager.screenCorner
                                )
                            }
                        }
                        .padding(10)
                    }
                }

                // Appearance Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("APPEARANCE")
                        .font(.geist(10, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.6))

                    Picker("", selection: $noteStore.appAppearance) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Options list
                VStack(spacing: 10) {
                    Toggle(isOn: $launchManager.isEnabled) {
                        HStack {
                            Text("Launch at login")
                                .font(.geist(12, weight: .medium))
                            Spacer()
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())

                    Toggle(isOn: $noteStore.alwaysOnTop) {
                        HStack {
                            Text("Always on top")
                                .font(.geist(12, weight: .medium))
                            Spacer()
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())
                    .onChange(of: noteStore.alwaysOnTop) { newValue in
                        windowManager.window?.level = newValue ? .floating : .normal
                    }
                }

                Divider().opacity(0.12)

                // Shortcut Info
                HStack {
                    Text("Global Shortcut")
                        .font(.geist(12, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("⌘ ⇧ Space")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.primary.opacity(0.08))
                        )
                }

                Divider().opacity(0.12)

                // Reset position button
                Button(action: {
                    windowManager.resetCornerPosition()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 11, weight: .medium))
                        Text("Reset Position to Screen Corner")
                            .font(.geist(11, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 2)

                // Quit App Button
                Button(action: {
                    NSApp.terminate(nil)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "power")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Quit Nook Notes")
                            .font(.geist(12, weight: .medium))
                    }
                    .foregroundColor(.red.opacity(0.85))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.red.opacity(0.08))
                    )
                }
                .buttonStyle(PlainButtonStyle())

                // Footer
                VStack(spacing: 2) {
                    Text("Nook Notes 1.0.0")
                        .font(.geist(10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("Minimal macOS Utility")
                        .font(.geist(9, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .padding(.top, 2)
            }
            .padding(16)
        }
    }
}

// Custom visual corner button component inside mini screen rectangle
struct CornerOptionBox: View {
    let title: String
    let cornerID: String
    @Binding var selectedCorner: String

    private var isSelected: Bool {
        selectedCorner == cornerID
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                selectedCorner = cornerID
            }
        }) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isSelected ? Color.white : Color.secondary.opacity(0.4))
                    .frame(width: 6, height: 6)

                Text(title)
                    .font(.geist(11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? Color(red: 0.0, green: 0.48, blue: 1.0) : Color.primary.opacity(0.07))
            )
            .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
