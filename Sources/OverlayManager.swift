import Cocoa
import SwiftUI

class OverlayManager {
    static let shared = OverlayManager()
    
    var buttonWindows: [String: NSWindow] = [:]
    let keys = ["W", "A", "S", "D"]
    
    func setup() {
        for key in keys {
            let win = DraggableButtonWindow(key: key)
            buttonWindows[key] = win
        }
    }
    
    func setEditMode(_ isEdit: Bool) {
        for (key, win) in buttonWindows {
            if isEdit {
                win.orderFront(nil)
            } else {
                win.orderOut(nil)
                // Save position when exiting edit mode
                SettingsManager.shared.setPosition(win.frame.origin, for: key)
            }
        }
    }
    
    func resetPositions() {
        SettingsManager.shared.resetPositions()
        for (key, win) in buttonWindows {
            win.setFrameOrigin(SettingsManager.shared.getPosition(for: key))
        }
    }
}

class DraggableButtonWindow: NSWindow {
    let key: String
    
    init(key: String) {
        self.key = key
        
        let size: CGFloat = 40
        let rect = NSRect(origin: SettingsManager.shared.getPosition(for: key), size: CGSize(width: size, height: size))
        
        super.init(contentRect: rect, styleMask: [.borderless], backing: .buffered, defer: false)
        
        self.level = .floating
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        // Allow dragging by background
        self.isMovableByWindowBackground = true
        // Keep window above everything
        self.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        let view = NSHostingView(rootView: ButtonView(key: key))
        self.contentView = view
    }
}

struct ButtonView: View {
    let key: String
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.8))
                .shadow(radius: 2)
            Text(key)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(width: 40, height: 40)
    }
}
