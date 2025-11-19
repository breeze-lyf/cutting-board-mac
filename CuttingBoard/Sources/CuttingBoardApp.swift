import SwiftUI
import AppKit

@main
struct CuttingBoardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var historyStore = ClipboardHistoryStore.shared
    @StateObject private var preferences = PreferencesStore()

    var body: some Scene {
        MenuBarExtra("CuttingBoard", systemImage: "scissors") {
            ContentView()
                .environmentObject(historyStore)
                .environmentObject(preferences)
                .frame(width: 420, height: 540)
                .padding(.vertical)
        }
        .menuBarExtraStyle(.window)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Clear History", action: historyStore.clear)
                Button("Toggle Launch at Login") {
                    preferences.launchAtLogin.toggle()
                }
                .keyboardShortcut("l", modifiers: [.command, .option])
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var monitor: ClipboardMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        monitor = ClipboardMonitor()
    }
}
