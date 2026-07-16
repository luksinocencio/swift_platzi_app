import SwiftUI
import MapKit

struct LocationsScreen: View {
    @State private var cameraPosition = MapCameraPosition.region(.defaultRegion)
    @Environment(PlatziStore.self) private var store
    
    private func loadLocations() async {
        do {
            try await store.loadLocations()
            let coordinates = store.locations.map { $0.coordinate }
            if let region = regionThatFits(coordinates) {
                cameraPosition = .region(region)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func regionThatFits(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }
        
        let mapRect = coordinates.reduce(MKMapRect.null) { rect, coord in
            let point = MKMapPoint(coord)
            let pointRect = MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0))
            return rect.union(pointRect)
        }
        
        return MKCoordinateRegion(mapRect)
    }
    
    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(store.locations) { location in
                Annotation(location.name, coordinate: location.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                        .font(.title)
                }
            }
        }
            .task {
                Task { await loadLocations() }
            }
    }
}

#Preview {
    LocationsScreen()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
