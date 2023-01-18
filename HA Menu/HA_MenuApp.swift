//
//  HA_MenuApp.swift
//  HA Menu
//
//  Created by Andrew Jackson on 08/05/2022.
//

import Cocoa
import SwiftUI

@main
struct HA_MenuApp: App {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.openWindow) var openWindow
    
    @AppStorage("Servers") var haServerDetails: Data = Data()
        
    var body: some Scene {
#if DEBUG
        let icon = "StatusBarButtonImageDebug"
#else
        let icon = "StatusBarButtonImage"
#endif
        
        MenuBarExtra("HA Menu", image: icon) {
            Button("One") {
                
            }
            .keyboardShortcut("1")
            Button("Two") {
                
            }
            .keyboardShortcut("2")
            Button("Three") {
                
            }
            .keyboardShortcut("3")
            
            Divider()
            
            Button("Preferences\u{2026}") {
                openWindow(id: "preferences")
                NSApp.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut(",")
            
            Divider()
            
            Button("About") {
                let options = [String: Any]()
                NSApp.orderFrontStandardAboutPanel(options)
                NSApp.activate(ignoringOtherApps: true)
            }
            
            Divider()
            
            Button("Quit") {
                
                NSApplication.shared.terminate(nil)
                
            }.keyboardShortcut("q")
            
        }
        .menuBarExtraStyle(.menu)
        .onChange(of: scenePhase) { newPhase in //<-- HERE TOO! This modifier allows you to detect change of scene.
            if newPhase == .inactive {
                //Code for moved to inactive
                print("Moved to inactive")
            } else if newPhase == .active {
                //Code for moved to foreground
                print("Moved to foreground - now active")
                //This is where you would want to change your text
            } else if newPhase == .background {
                //Code for moved to background
                print("Moved to background")
            }
        }
        
        Window("Preferences", id: "preferences") {
            ContentView()
                .frame(minWidth: 500, minHeight: 300)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
                    hideButtons()
                })
                .onAppear() {
                    // Disable the menu
                }
                .onDisappear() {
                    // Re-enable the menu
                }
        }
        
//        WindowGroup {
//            ContentView()
//                .frame(minWidth: 500, minHeight: 300)
//                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
//                    hideButtons()
//                })
//                .onAppear() {
//                    // Disable the menu
//                }
//                .onDisappear() {
//                    // Re-enable the menu
//                }
//        }
//        .handlesExternalEvents(matching: ["preferencesScene"])
    }
    
    func hideButtons() {
        for window in NSApplication.shared.windows {
//            window.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isEnabled = false
            window.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isEnabled = false
            
        }
        
        for window in NSApplication.shared.windows {
            if window.title == "Preferences" {
                window.level = .floating
            }
        }
    }
    
    func getHaServerDetails(data: Data) -> [HaServerDetails] {
            return HaServerDetailsStorage.loadHaServerDetailsArray(data: data)
        }
    
    func addHaServerDetails() {
        var tmpHaServerDetails = getHaServerDetails(data: haServerDetails)
        
        tmpHaServerDetails.append(HaServerDetails())
        
        haServerDetails = HaServerDetailsStorage.archiveHaServerDetailsArray(object: tmpHaServerDetails)
    }
    
    class HaServerDetailsStorage: NSObject {
        
        static func archiveHaServerDetailsArray(object : [HaServerDetails]) -> Data {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
                return data
            } catch {
                fatalError("Can't encode data: \(error)")
            }

        }

        static func loadHaServerDetailsArray(data: Data) -> [HaServerDetails] {
            do {
                guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HaServerDetails] else {
                    return []
                }
                return array
            } catch {
                fatalError("loadHaServerDetailsArray - Can't encode data: \(error)")
            }
        }
    }
}
