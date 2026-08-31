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
    @Published public var isPinned: Bool = false {
        didSet {
            UserDefaults.standard.set(isPinned, forKey: "nook_window_pinned")
            if isPinned {
                expandPanel()
                window?.level = .floating
            } else {
                let mouseLoc = NSEvent.mouseLocation
                if let frame = window?.frame, !NSMouseInRect(mouseLoc, frame.insetBy(dx: -25, dy: -25), false) {
                    collapsePanel()
                }
            }
        }
    }
    @Published public var screenCorner: String = "bottom_left" {
        didSet {
            UserDefaults.standard.set(screenCorner, forKey: "nook_screen_corner")
            updateWindowPosition(animated: true)
        }
    }

    public private(set) var window: NookWindow?
    private var globalMouseMonitor: Any?
    private var localMouseMonitor: Any?
    private var clickOutsideMonitor: Any?
    private var isFullScreenAppActive: Bool = false
    private var fullScreenCheckTimer: Timer?

    // Custom dragged position and size storage
    private var userExpandedOrigin: NSPoint?
    private var userExpandedWidth: CGFloat?
    private var userExpandedHeight: CGFloat?

    // Window dimensions
    public let collapsedWidth: CGFloat = 110
    public let collapsedHeight: CGFloat = 50

    public let defaultExpandedWidth: CGFloat = 410
    public let defaultExpandedHeight: CGFloat = 540

    public var currentExpandedWidth: CGFloat {
        userExpandedWidth ?? defaultExpandedWidth
    }

    public var currentExpandedHeight: CGFloat {
        userExpandedHeight ?? defaultExpandedHeight
    }

    public init() {
        self.screenCorner = UserDefaults.standard.string(forKey: "nook_screen_corner") ?? "bottom_left"
        self.isPinned = UserDefaults.standard.bool(forKey: "nook_window_pinned")
    }

    public func configureWindow(contentView: NSView) {
        let panel = NookWindow(
            contentRect: NSRect(x: 0, y: 0, width: collapsedWidth, height: collapsedHeight),
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = false
        panel.collectionBehavior = [.canJoinAllSpaces]
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = false
        panel.minSize = NSSize(width: 320, height: 380)
        panel.maxSize = NSSize(width: 1000, height: 1200)
        panel.contentView = contentView

        self.window = panel

        if isPinned {
            isExpanded = true
        }

        updateWindowPosition(animated: false)
        panel.orderFrontRegardless()

        setupMouseTracking()
        setupClickOutsideTracking()
        setupWindowObserverTracking()
        setupFullScreenDetector()
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
        guard isExpanded && !isPinned else { return }

        if let currentFrame = window?.frame {
            self.userExpandedOrigin = currentFrame.origin
            self.userExpandedWidth = currentFrame.size.width
            self.userExpandedHeight = currentFrame.size.height
        }

        isExpanded = false
        isSettingsPresented = false
        isHovered = false

        updateWindowPosition(animated: true)
    }

    public func resetCornerPosition() {
        self.userExpandedOrigin = nil
        self.userExpandedWidth = nil
        self.userExpandedHeight = nil
        updateWindowPosition(animated: true)
    }

    public func updateWindowPosition(animated: Bool = false) {
        guard let window = window else { return }

        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? NSScreen.main ?? NSScreen.screens[0]

        let physicalFrame = targetScreen.frame
        let visibleFrame = targetScreen.visibleFrame

        let width = isExpanded ? currentExpandedWidth : collapsedWidth
        let height = isExpanded ? currentExpandedHeight : collapsedHeight

        let targetOrigin: NSPoint

        if isExpanded {
            if let custom = userExpandedOrigin {
                targetOrigin = custom
            } else {
                switch screenCorner {
                case "bottom_right":
                    targetOrigin = NSPoint(x: visibleFrame.origin.x + visibleFrame.width - width, y: visibleFrame.origin.y)
                case "top_left":
                    targetOrigin = NSPoint(x: visibleFrame.origin.x, y: visibleFrame.origin.y + visibleFrame.height - height)
                case "top_right":
                    targetOrigin = NSPoint(x: visibleFrame.origin.x + visibleFrame.width - width, y: visibleFrame.origin.y + visibleFrame.height - height)
                default: // bottom_left
                    targetOrigin = NSPoint(x: visibleFrame.origin.x, y: visibleFrame.origin.y)
                }
            }
        } else {
            // Minimized tab: docked ALL THE WAY against the physical screen edge
            switch screenCorner {
            case "bottom_right":
                targetOrigin = NSPoint(x: physicalFrame.origin.x + physicalFrame.width - width, y: physicalFrame.origin.y)
            case "top_left":
                targetOrigin = NSPoint(x: physicalFrame.origin.x, y: physicalFrame.origin.y + physicalFrame.height - height)
            case "top_right":
                targetOrigin = NSPoint(x: physicalFrame.origin.x + physicalFrame.width - width, y: physicalFrame.origin.y + physicalFrame.height - height)
            default: // bottom_left
                targetOrigin = NSPoint(x: physicalFrame.origin.x, y: physicalFrame.origin.y)
            }
        }

        let targetRect = NSRect(
            x: targetOrigin.x,
            y: targetOrigin.y,
            width: max(width, 320),
            height: max(height, isExpanded ? 380 : collapsedHeight)
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

    private func setupFullScreenDetector() {
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.checkFullScreenState()
        }
        center.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] _ in
            self?.checkFullScreenState()
        }

        // Lightweight 0.8s timer to continuously check full screen state during video playback
        fullScreenCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            self?.checkFullScreenState()
        }
    }

    private func checkFullScreenState() {
        guard let window = window else { return }
        let screen = window.screen ?? NSScreen.main ?? NSScreen.screens[0]

        let physicalHeight = screen.frame.height
        let physicalWidth = screen.frame.width

        let visibleHeight = screen.visibleFrame.height
        let visibleWidth = screen.visibleFrame.width

        // Full screen video or app is active when visibleFrame occupies physical screen bounds
        let isScreenFullScreen = (visibleHeight >= physicalHeight - 4.0) && (visibleWidth >= physicalWidth - 4.0)
        let presentationOpts = NSApplication.shared.currentPresentationOptions
        let isAppFullScreen = presentationOpts.contains(.fullScreen) || presentationOpts.contains(.autoHideMenuBar)

        let isFullScreenMode = isScreenFullScreen || isAppFullScreen

        if isFullScreenMode {
            if !isFullScreenAppActive {
                isFullScreenAppActive = true
                window.orderOut(nil)
            }
        } else {
            if isFullScreenAppActive {
                isFullScreenAppActive = false
                window.orderFrontRegardless()
            }
        }
    }

    private func setupWindowObserverTracking() {
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, self.isExpanded, let frame = self.window?.frame else { return }
            self.userExpandedOrigin = frame.origin
        }

        NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, self.isExpanded, let frame = self.window?.frame else { return }
            self.userExpandedWidth = max(frame.size.width, 320)
            self.userExpandedHeight = max(frame.size.height, 380)
            self.userExpandedOrigin = frame.origin
        }
    }

    private func setupMouseTracking() {
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in
            guard let self = self, let window = self.window else { return }
            let mouseLoc = NSEvent.mouseLocation
            let windowFrame = window.frame

            if !self.isExpanded {
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
            } else if !self.isPinned && !self.isSettingsPresented && !window.inLiveResize {
                let expandedHitZone = windowFrame.insetBy(dx: -30, dy: -30)
                if !NSMouseInRect(mouseLoc, expandedHitZone, false) {
                    DispatchQueue.main.async {
                        self.collapsePanel()
                    }
                }
            }
        }

        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            guard let self = self, let window = self.window else { return event }
            let mouseLoc = NSEvent.mouseLocation
            let windowFrame = window.frame

            if !self.isExpanded {
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
            return event
        }
    }

    private func setupClickOutsideTracking() {
        clickOutsideMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self = self, self.isExpanded, let window = self.window else { return }

            if self.isPinned { return }
            if NSEvent.pressedMouseButtons != 0 || window.inLiveResize { return }
            if self.isSettingsPresented { return }

            let mouseLoc = NSEvent.mouseLocation
            let borderHitArea = window.frame.insetBy(dx: -25, dy: -25)

            if !NSMouseInRect(mouseLoc, borderHitArea, false) {
                DispatchQueue.main.async {
                    self.collapsePanel()
                }
            }
        }
    }

    deinit {
        fullScreenCheckTimer?.invalidate()
        if let monitor = globalMouseMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = localMouseMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = clickOutsideMonitor { NSEvent.removeMonitor(monitor) }
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
