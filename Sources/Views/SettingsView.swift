import SwiftUI

public struct SettingsView: View {
    @ObservedObject var noteStore: NoteStore
    @ObservedObject var launchManager = LaunchAtLoginManager.shared
    @ObservedObject var windowManager: WindowManager
    public var onClose: () -> Void

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 16, weight: .bold, design: .serif))
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

                // Reset position button if moved
                Button(action: {
                    windowManager.resetToBottomLeft()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 11, weight: .medium))
                        Text("Reset Position to Bottom-Left")
                            .font(.geist(11, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 4)

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
                    Text("Minimal macOS Sticky Utility")
                        .font(.geist(9, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
    }
}
