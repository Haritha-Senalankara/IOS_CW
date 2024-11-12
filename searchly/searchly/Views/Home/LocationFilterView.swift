import SwiftUI
import MapKit
import Combine
import CoreLocation

// MARK: - LocationSearchCompleter
class LocationSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var suggestions: [MKLocalSearchCompletion] = [] // Holds search suggestions
    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.resultTypes = .address // Specify result types
        completer.delegate = self
    }

    func updateSearch(query: String) {
        completer.queryFragment = query // Updates the query fragment
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results // Populate suggestions
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}

// MARK: - LocationFilterView
struct LocationFilterView: View {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var selectedRadius: Double
    @Binding var isPresented: Bool
    var onApply: () -> Void

    @State private var centerCoordinate: CLLocationCoordinate2D?
    @State private var searchQuery: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var userAddress: String = "Fetching current location..."

    @StateObject private var locationManager = LocationManager()
    @StateObject private var searchCompleter = LocationSearchCompleter()

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                // Search Field
                HStack {
                    TextField("Search for a location", text: $searchQuery)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: searchQuery) { newValue in
                            searchCompleter.updateSearch(query: newValue)
                        }
                        .overlay(
                            HStack {
                                Spacer()
                                if !searchQuery.isEmpty {
                                    Button(action: {
                                        searchQuery = ""
                                        searchCompleter.suggestions = []
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color(.systemGray))
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                }
                .padding(.horizontal, 20)

                // Current Location Button
                Button(action: {
                    locationManager.requestLocation { location, address in
                        if let location = location {
                            userAddress = address ?? "Unable to fetch address"
                            centerCoordinate = location
                            selectedLocation = location
                        } else {
                            alertMessage = "Unable to fetch current location. Please ensure that location services are enabled."
                            showAlert = true
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Use Current Location")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)

                // Current Location Address
                VStack(spacing: 10) {
                    Text("Your Current Location:")
                        .font(.headline)
                    Text(userAddress)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)

                // Map View
                MapViewRepresentable(centerCoordinate: $centerCoordinate, selectedRadius: $selectedRadius)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)

                // Radius Slider
                VStack(spacing: 10) {
                    Text("Radius: \(Int(selectedRadius)) meters")
                        .font(.system(size: 16, weight: .regular))

                    Slider(value: $selectedRadius, in: 100...5000, step: 50)
                        .accentColor(.orange)
                        .padding(.horizontal, 20)
                }

                // Apply Button
                Button(action: {
                    isPresented = false
                    selectedLocation = centerCoordinate
                    onApply()
                }) {
                    Text("Apply")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.bottom, 30)
            .background(Color.white)
            .cornerRadius(12)
            .onAppear {
                locationManager.requestLocation { location, address in
                    if let location = location {
                        userAddress = address ?? "Unable to fetch address"
                        centerCoordinate = location
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            // Suggestions Overlay
            if !searchCompleter.suggestions.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(searchCompleter.suggestions, id: \.self) { suggestion in
                        Button(action: {
                            searchQuery = suggestion.title
                            performGeocoding(for: suggestion.title)
                            searchCompleter.suggestions.removeAll()
                        }) {
                            VStack(alignment: .leading) {
                                Text(suggestion.title)
                                    .font(.headline)
                                if !suggestion.subtitle.isEmpty {
                                    Text(suggestion.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(Color(.systemBackground))
                        }
                        Divider()
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                .padding(.horizontal, 20)
                .offset(y: 55)
            }
        }
    }

    func performGeocoding(for query: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { placemarks, error in
            if let error = error {
                alertMessage = "Unable to find location. Please try again."
                showAlert = true
            } else if let placemark = placemarks?.first, let location = placemark.location {
                centerCoordinate = location.coordinate
                selectedLocation = location.coordinate
            } else {
                alertMessage = "Location not found. Please try a different query."
                showAlert = true
            }
        }
    }
}

// MARK: - LocationManager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()
    private var locationCompletion: ((CLLocationCoordinate2D?, String?) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            if let locationCompletion = locationCompletion {
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                    if let placemark = placemarks?.first {
                        let address = "\(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "")"
                        locationCompletion(location.coordinate, address)
                    } else {
                        locationCompletion(location.coordinate, nil)
                    }
                }
                self.locationCompletion = nil
            }
        }
    }

    func requestLocation(completion: @escaping (CLLocationCoordinate2D?, String?) -> Void) {
        self.locationCompletion = completion

        // Check Location Authorization Status
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            completion(nil, "Location access restricted or denied. Please enable location permissions in settings.")
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            completion(nil, "Unknown location authorization status.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        if let locationCompletion = locationCompletion {
            locationCompletion(nil, nil)
            self.locationCompletion = nil
        }
    }
}
