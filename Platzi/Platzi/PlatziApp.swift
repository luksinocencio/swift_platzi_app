import SwiftUI

@main
struct PlatziApp: App {
    @AppStorage("isAuthenticated") private var isAuthenticated: Bool = false
    @Environment(\.authenticationController) private var authenticationController
    @State private var isLoading = true
    
    init() {
        loadRocketSimConnect()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    ProgressView("Loading...")
                        .task {
                            isAuthenticated = await authenticationController.checkAuthentication()
                            isLoading = false
                        }
                } else if isAuthenticated {
                    HomeScreen()
                } else {
                    NavigationStack {
                        LoginScreen()
                    }
                }
            }
            
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
