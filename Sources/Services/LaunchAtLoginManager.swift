import Foundation
import ServiceManagement

public class LaunchAtLoginManager: ObservableObject {
    public static let shared = LaunchAtLoginManager()

    @Published public var isEnabled: Bool = false {
        didSet {
            setLaunchAtLogin(enabled: isEnabled)
        }
    }

    private init() {
        if #available(macOS 13.0, *) {
            self.isEnabled = (SMAppService.mainApp.status == .enabled)
        } else {
            self.isEnabled = false
        }
    }

    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
            } catch {
                print("Failed to toggle Launch at Login: \(error)")
            }
        }
    }
}
