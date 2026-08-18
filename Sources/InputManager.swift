import Cocoa
import CoreGraphics

class InputManager: ObservableObject {
    static let shared = InputManager()
    
    @Published var isPlayMode = false
    @Published var activeKeys: [String: Bool] = ["W": false, "A": false, "S": false, "D": false]
    @Published var debugLogs: [String] = []
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private var keyStates: [Int64: Bool] = [
        13: false, // W
        0: false,  // A
        1: false,  // S
        2: false   // D
    ]
    
    private let keycodeToName: [Int64: String] = [
        13: "W",
        0: "A",
        1: "S",
        2: "D"
    ]
    
    private func addLog(_ message: String) {
        print(message)
        DispatchQueue.main.async {
            self.debugLogs.append(message)
            if self.debugLogs.count > 10 {
                self.debugLogs.removeFirst()
            }
        }
    }
    
    func start() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if trusted {
            setupEventTap()
        } else {
            addLog("[SYSTEM] Accessibility permission missing")
        }
    }
    
    func checkAccessibility() -> Bool {
        return AXIsProcessTrusted()
    }
    
    private func setupEventTap() {
        if eventTap != nil { return } // Already setup
        
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        
        let callback: CGEventTapCallBack = { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
            guard let refcon = refcon else { return Unmanaged.passRetained(event) }
            let manager = Unmanaged<InputManager>.fromOpaque(refcon).takeUnretainedValue()
            return manager.handleEvent(proxy: proxy, type: type, event: event)
        }
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            addLog("[ERROR] Failed to create event tap")
            return
        }
        
        self.eventTap = tap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        addLog("[SYSTEM] Global Event Tap Created Successfully")
    }
    
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard isPlayMode else { return Unmanaged.passRetained(event) }
        
        let keycode = event.getIntegerValueField(.keyboardEventKeycode)
        
        guard let keyName = keycodeToName[keycode] else {
            return Unmanaged.passRetained(event) // Not W, A, S, D
        }
        
        if type == .keyDown {
            if !(keyStates[keycode] ?? false) {
                keyStates[keycode] = true
                addLog("[KEY DOWN] \(keyName)")
                DispatchQueue.main.async { self.activeKeys[keyName] = true }
                postMouseEvent(for: keyName, isDown: true)
            }
            // Block the physical key event
            return nil
        } else if type == .keyUp {
            keyStates[keycode] = false
            addLog("[KEY UP] \(keyName)")
            DispatchQueue.main.async { self.activeKeys[keyName] = false }
            postMouseEvent(for: keyName, isDown: false)
            return nil
        }
        
        return Unmanaged.passRetained(event)
    }
    
    private func postMouseEvent(for key: String, isDown: Bool) {
        let appKitPos = SettingsManager.shared.getPosition(for: key)
        let center = CGPoint(x: appKitPos.x + 20, y: appKitPos.y + 20)
        
        // AppKit coordinates origin is bottom-left. CGEvent origin is top-left.
        let mainScreenHeight = NSScreen.screens.first?.frame.height ?? 0
        let cgTarget = CGPoint(x: center.x, y: mainScreenHeight - center.y)
        
        let eventType: CGEventType = isDown ? .leftMouseDown : .leftMouseUp
        
        if isDown {
            addLog("[MAPPED] \(key) -> NSScreen: (\(Int(center.x)), \(Int(center.y)))")
            addLog("[MOUSE DOWN] at CGEvent: (\(Int(cgTarget.x)), \(Int(cgTarget.y)))")
        } else {
            addLog("[MOUSE UP] at CGEvent: (\(Int(cgTarget.x)), \(Int(cgTarget.y)))")
        }
        
        if let mouseEvent = CGEvent(mouseEventSource: nil, mouseType: eventType, mouseCursorPosition: cgTarget, mouseButton: .left) {
            mouseEvent.post(tap: .cghidEventTap)
        } else {
            addLog("[ERROR] Could not create CGEvent")
        }
    }
}
