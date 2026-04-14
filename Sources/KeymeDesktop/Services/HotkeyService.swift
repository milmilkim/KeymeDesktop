import Carbon
import AppKit

final class HotkeyService {
    private var eventHandler: EventHandlerRef?
    private let onTrigger: () -> Void

    init(onTrigger: @escaping () -> Void) {
        self.onTrigger = onTrigger
    }

    func register(keyCode: UInt32 = 0x28, modifiers: UInt32 = UInt32(cmdKey | shiftKey)) {
        var hotKeyID = EventHotKeyID(signature: OSType(0x4B455945), id: 1)
        var hotKeyRef: EventHotKeyRef?
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let handler: EventHandlerUPP = { _, event, userData -> OSStatus in
            guard let userData else { return OSStatus(eventNotHandledErr) }
            let service = Unmanaged<HotkeyService>.fromOpaque(userData).takeUnretainedValue()
            DispatchQueue.main.async { service.onTrigger() }
            return noErr
        }
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventSpec, selfPtr, &eventHandler)
    }
}
