import Foundation
import MapKit
import Observation

@MainActor
@Observable
class LocationsViewModel {
    var locations: [Location] = []

    private let service: PlatziService

    init(service: PlatziService = PlatziService()) {
        self.service = service
    }

    func loadLocations() async throws {
        locations = try await service.loadLocations()
    }

    /// A region that fits all loaded locations, or `nil` when there are none.
    func regionThatFitsAllLocations() -> MKCoordinateRegion? {
        let coordinates = locations.map { $0.coordinate }
        guard !coordinates.isEmpty else { return nil }

        let mapRect = coordinates.reduce(MKMapRect.null) { rect, coord in
            let point = MKMapPoint(coord)
            let pointRect = MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0))
            return rect.union(pointRect)
        }

        return MKCoordinateRegion(mapRect)
    }
}
