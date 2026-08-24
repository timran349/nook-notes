import AppKit
import SwiftUI
import Combine

public class NookWindow: NSPanel {
    override public var canBecomeKey: Bool { true }
    override public var canBecomeMain: Bool { true }
}

public class WindowManager: ObservableObject {
    public static let shared = WindowManager()

    @Published public var isExpanded: Bool = false
    @Published public var isHovered: Bool = false
    @Published public var isSettingsPresented: Bool = false

    public private(set) var window: NookWindow?
    private var globalMouseMonitor: Any?
    private var localMouseMonitor: Any?
    private var clickOutsideMonitor: Any?

    // Window dimensions
    public let collapsedWidth: CGFloat = 110
    public let collapsedHeight: CGFloat = 50

    public let expandedWidth: CGFloat = 350
    public let expandedHeight: CGFloat = 480

    public init() {}

    public func configureWindow(contentView: NSView) {
        let panel = NookWindow(
            contentRect: NSRect(x: 0, y: 0, width: collapsedWidth, height: collapsedHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.contentView = contentView

        self.window = panel

        updateWindowPosition(animated: false)
        panel.orderFrontRegardless()

        setupMouseTracking()
        setupClickOutsideTracking()
    }

    public func togglePanel() {
        if isExpanded {
            collapsePanel()
        } else {
            expandPanel()
        }
    }

    public func expandPanel() {
        guard !isExpanded else { return }
        isExpanded = true

        updateWindowPosition(animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    public func collapsePanel() {
        guard isExpanded else { return }
        isExpanded = false
        isSettingsPresented = false
        isHovered = false

        updateWindowPosition(animated: true)
    }

    public func updateWindowPosition(animated: Bool = false) {
        guard let window = window else { return }

        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? NSScreen.main ?? NSScreen.screens[0]

        let screenFrame = targetScreen.visibleFrame

        let width = isExpanded ? expandedWidth : collapsedWidth
        let height = isExpanded ? expandedHeight : collapsedHeight

        let targetRect = NSRect(
            x: screenFrame.origin.x,
            y: screenFrame.origin.y,
            width: width,
            height: height
        )

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = isExpanded ? 0.18 : 0.14
                context.timingFunction = CAMediaTimingFunction(name: isExpanded ? .easeOut : .easeIn)
                window.animator().setFrame(targetRect, display: true)
            }
        } else {
            window.setFrame(targetRect, display: true)
        }
    }

    private func setupMouseTracking() {
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in
            guard let self = self, !self.isExpanded, let window = self.window else { return }
            let mouseLoc = NSEvent.mouseLocation
            let windowFrame = window.frame

            let hoverZone = NSRect(
                x: windowFrame.origin.x,
                y: windowFrame.origin.y,
                width: self.collapsedWidth + 25,
                height: self.collapsedHeight + 25
            )

            let hovering = NSMouseInRect(mouseLoc, hoverZone, false)
            if self.isHovered != hovering {
                DispatchQueue.main.async {
                    self.isHovered = hovering
                }
            }
        }

        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            guard let self = self, !self.isExpanded, let window = self.window else { return event }
            let mouseLoc = NSEvent.mouseLocation
            let windowFrame = window.frame

            let hoverZone = NSRect(
                x: windowFrame.origin.x,
                y: windowFrame.origin.y,
                width: self.collapsedWidth + 25,
                height: self.collapsedHeight + 25
            )

            let hovering = NSMouseInRect(mouseLoc, hoverZone, false)
            if self.isHovered != hovering {
                DispatchQueue.main.async {
                    self.isHovered = hovering
                }
            }
            return event
        }
    }

    private func setupClickOutsideTracking() {
        clickOutsideMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self = self, self.isExpanded, let window = self.window else { return }
            let mouseLoc = NSEvent.mouseLocation
            if !NSMouseInRect(mouseLoc, window.frame, false) {
                DispatchQueue.main.async {
                    self.collapsePanel()
                }
            }
        }
    }

    deinit {
        if let monitor = globalMouseMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = localMouseMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = clickOutsideMonitor { NSEvent.removeMonitor(monitor) }
    }
}
