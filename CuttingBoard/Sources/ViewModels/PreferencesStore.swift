import Foundation
import Combine

final class PreferencesStore: ObservableObject {
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin)
        }
    }

    @Published var keepForDays: Int {
        didSet {
            UserDefaults.standard.set(keepForDays, forKey: Keys.keepForDays)
        }
    }

    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
        static let keepForDays = "keepForDays"
    }

    init() {
        launchAtLogin = UserDefaults.standard.bool(forKey: Keys.launchAtLogin)
        let stored = UserDefaults.standard.integer(forKey: Keys.keepForDays)
        keepForDays = stored == 0 ? 14 : stored
    }
}
