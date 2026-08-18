import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard
    
    // Default starting positions so they don't overlap completely
    func getPosition(for key: String) -> CGPoint {
        if let data = defaults.data(forKey: "pos_\(key)"),
           let point = try? JSONDecoder().decode(CGPoint.self, from: data) {
            return point
        }
        
        let defaults: [String: CGPoint] = [
            "W": CGPoint(x: 150, y: 200),
            "A": CGPoint(x: 100, y: 150),
            "S": CGPoint(x: 150, y: 150),
            "D": CGPoint(x: 200, y: 150)
        ]
        return defaults[key] ?? CGPoint(x: 100, y: 100)
    }
    
    func setPosition(_ position: CGPoint, for key: String) {
        if let data = try? JSONEncoder().encode(position) {
            defaults.set(data, forKey: "pos_\(key)")
        }
    }
    
    func resetPositions() {
        for key in ["W", "A", "S", "D"] {
            defaults.removeObject(forKey: "pos_\(key)")
        }
    }
}
