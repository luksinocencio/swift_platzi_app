import SwiftUI
import MapKit

struct LocationsScreen: View {
    @State private var viewModel = LocationsViewModel()
    @State private var cameraPosition = MapCameraPosition.region(.defaultRegion)
    @State private var selectedLocation: Location?

    @Environment(ErrorState.self) private var errorState

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(viewModel.locations) { location in
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
                try await viewModel.loadLocations()

                if let region = viewModel.regionThatFitsAllLocations() {
                    cameraPosition = .region(region)
                }
            } catch {
                errorState.error = error
            }
        }
    }
}

#Preview {
    LocationsScreen()
        .environment(ErrorState())
}
