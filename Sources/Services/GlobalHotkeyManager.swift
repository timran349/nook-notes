import Foundation
import Carbon

public class GlobalHotkeyManager {
    public static let shared = GlobalHotkeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?
    public var onHotKeyTriggered: (() -> Void)?

    private init() {}

    public func register() {
        unregister() // Clear previous if any

        let hotKeyID = EventHotKeyID(signature: OSType(0x4E4F4F4B), id: 1) // 'NOOK'

        // Cmd + Shift + Space
        let modifierFlags: UInt32 = UInt32(cmdKey | shiftKey)
        let keyCode: UInt32 = UInt32(kVK_Space) // 0x31

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async {
                    manager.onHotKeyTriggered?()
                }
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            &handlerRef
        )

        if status == noErr {
            RegisterEventHotKey(
                keyCode,
                modifierFlags,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )
        }
    }

    public func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let ref = handlerRef {
            RemoveEventHandler(ref)
            handlerRef = nil
        }
    }
}
