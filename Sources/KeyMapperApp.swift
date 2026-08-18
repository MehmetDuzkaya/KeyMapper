import SwiftUI
import AppKit

@main
struct KeyMapperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var inputManager = InputManager.shared
    @State private var isEditMode = false
    @State private var hasAccessibility = false
    
    var body: some Scene {
        // MENU ICONU: Kendi ikonunuzu kullanmak isterseniz aşağıdaki satırı yorum satırı yapıp bir altındakini açın.
        // İkonunuzu Assets içine "MenuBarIcon" olarak eklemeyi unutmayın.
        MenuBarExtra("KeyMapper", systemImage: isEditMode ? "gamecontroller" : (inputManager.isPlayMode ? "gamecontroller.fill" : "keyboard")) {
        // MenuBarExtra("KeyMapper", image: "MenuBarIcon") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    // APP LOGOSU: "AppLogo" isimli görseli Assets bölümüne eklediğinizde burada görünür.
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .cornerRadius(6)
                        // Görsel yoksa gri bir yer tutucu göster:
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                    
                    Text("KeyMapper")
                        .font(.headline)
                }
                .padding(.bottom, 2)
                
                Divider()
                
                HStack {
                    Circle()
                        .fill(hasAccessibility ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(hasAccessibility ? "Accessibility Granted" : "Needs Accessibility")
                        .font(.caption)
                }
                
                if !hasAccessibility {
                    Button("Open System Settings") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    Button("Grant Accessibility (Prompt)") {
                        InputManager.shared.start()
                    }
                }
                
                Divider()
                
                Button(isEditMode ? "✓ Finish Edit Mode" : "✎ Edit Mode") {
                    isEditMode.toggle()
                    OverlayManager.shared.setEditMode(isEditMode)
                    
                    if isEditMode {
                        inputManager.isPlayMode = false
                    }
                }
                
                Button(inputManager.isPlayMode ? "⏹ Stop Play Mode" : "▶ Start Play Mode") {
                    inputManager.isPlayMode.toggle()
                    if inputManager.isPlayMode {
                        isEditMode = false
                        OverlayManager.shared.setEditMode(false)
                    }
                }
                .disabled(isEditMode || !hasAccessibility)
                
                Divider()
                
                Button("Reset Positions") {
                    OverlayManager.shared.resetPositions()
                }
                .disabled(!isEditMode)
                
                Divider()
                
                // --- DEBUG PANEL ---
                Text("Debug & Status")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                HStack(spacing: 15) {
                    ForEach(["W", "A", "S", "D"], id: \.self) { key in
                        HStack(spacing: 4) {
                            Text(key)
                            Circle()
                                .fill((inputManager.activeKeys[key] ?? false) ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                
                if !inputManager.debugLogs.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(inputManager.debugLogs.suffix(4), id: \.self) { log in
                            Text(log)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: 250, alignment: .leading)
                }
                // --- END DEBUG PANEL ---
                
                Divider()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding()
            .onAppear {
                hasAccessibility = InputManager.shared.checkAccessibility()
            }
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        OverlayManager.shared.setup()
        InputManager.shared.start()
    }
}
