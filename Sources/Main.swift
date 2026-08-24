import AppKit
import SwiftUI

@main
struct NookNotesApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set app as accessory (utility mode)
        NSApp.setActivationPolicy(.accessory)

        // Create main SwiftUI view
        let mainView = MainView()
        let hostingView = NSHostingView(rootView: mainView)
        hostingView.autoresizingMask = [.width, .height]

        // Configure floating NSPanel window manager
        WindowManager.shared.configureWindow(contentView: hostingView)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

