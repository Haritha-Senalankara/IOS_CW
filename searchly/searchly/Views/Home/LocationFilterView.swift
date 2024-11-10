//
//  LocationFilterView.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation
import MapKit

// MARK: - LocationFilterView
struct LocationFilterView: View {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var selectedRadius: Double
    @Binding var isPresented: Bool
    var onApply: () -> Void // Closure to execute when 'Apply' is tapped

    @State private var centerCoordinate: CLLocationCoordinate2D?
    @State private var searchQuery: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("Search for a location", text: $searchQuery, onCommit: {
                    performGeocoding()
                })
                .padding(10)
                .background(Color(hex: "#F7F7F7"))
                .cornerRadius(8)
//                .overlay(
//                    Image(systemName: "magnifyingglass")
//                        .padding(.leading, 10),
//                    alignment: .leading
//                )
                .overlay(
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .padding(.trailing, 10)
                    },
                    alignment: .trailing
                )
            }
            .padding(.horizontal, 20)

            MapViewRepresentable(centerCoordinate: $centerCoordinate, selectedRadius: $selectedRadius)
                .frame(height: 300)
                .cornerRadius(12)
                .padding(.horizontal, 20)

            VStack(spacing: 10) {
                Text("Radius: \(Int(selectedRadius)) meters")
                    .font(.custom("Heebo-Regular", size: 16))

                Slider(value: $selectedRadius, in: 100...5000, step: 50) // Adjust the range as needed
                    .accentColor(Color(hex: "#F2A213"))
                    .padding(.horizontal, 20)
            }

            Button(action: {
                isPresented = false
                selectedLocation = centerCoordinate
                onApply()
            }) {
                Text("Apply")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#F2A213"))
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
            centerCoordinate = selectedLocation ?? CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Location Not Found"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func performGeocoding() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchQuery) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                alertMessage = "Unable to find location. Please try again."
                showAlert = true
            } else if let placemark = placemarks?.first, let location = placemark.location {
                centerCoordinate = location.coordinate
            } else {
                alertMessage = "Location not found. Please try a different query."
                showAlert = true
            }
        }
    }
}
