import SwiftUI
import MapKit

struct LocationDetailScreen: View {
    
    let location: Location
    @State private var cameraPosition: MapCameraPosition
    
    init(location: Location) {
        self.location = location
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        cameraPosition = MapCameraPosition.region(region)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(location.name)
                .font(.largeTitle)
            Text(location.description)
            Map(position: $cameraPosition) {
                Marker(location.name, coordinate: location.coordinate)
            }.clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
}

#Preview {
    LocationDetailScreen(location: Location(
        id: 1,
        name: "1934 Pine Grove",
        description: "Charming house with 3 bedrooms and large backyard.",
        latitude: 37.7749,
        longitude: -122.4194
    ))
}
