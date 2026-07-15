import SwiftUI

@main
struct PlatziApp: App {
    init() {
        loadRocketSimConnect()
    }
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            RegistrationScreen()
        }
    }
}

private func loadRocketSimConnect() {
#if DEBUG
    guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
        print("Failed to load linker framework")
        return
    }
    print("RocketSim Connect successfully linked")
#endif
}
