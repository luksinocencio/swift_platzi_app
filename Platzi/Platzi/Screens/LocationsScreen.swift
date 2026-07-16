import SwiftUI
import MapKit

struct LocationsScreen: View {
    @State private var cameraPosition = MapCameraPosition.region(.defaultRegion)
    @Environment(PlatziStore.self) private var store
    @State private var selectedLocation: Location?
    
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
                        .font(selectedLocation?.id == location.id ? .largeTitle : .title)
                        .foregroundStyle(selectedLocation?.id == location.id ? .blue : .red)
                        .scaleEffect(selectedLocation?.id == location.id ? 1.5 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedLocation?.id)
                        .onTapGesture {
                            selectedLocation = location
                        }
                }
            }
        }
        .sheet(item: $selectedLocation, content: { location in
            LocationDetailScreen(location: location)
                .presentationDetents([.medium])
        })
        .task {
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
    }
}

#Preview {
    LocationsScreen()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
