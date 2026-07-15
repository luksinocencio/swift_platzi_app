import SwiftUI

extension EnvironmentValues {
    @Entry var authenticationController = AuthenticationController(httpClinet: HTTPClient())
}
