import SwiftUI

extension EnvironmentValues {
    @Entry var authenticationController = AuthenticationController(httpClient: HTTPClient())
}
