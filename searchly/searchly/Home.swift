//
//  Home.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-10-27.
//

import SwiftUI
import FirebaseFirestore
import MapKit

// MARK: - Home View
struct Home: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var showPriceFilter = false
    @State private var selectedPrice: Double = 350000 // Default value
    
    @State private var showLocationFilter = false // State to control location filter visibility
    @State private var selectedLocation: CLLocationCoordinate2D? // Selected location
    @State private var selectedRadius: Double = 1000 // Default radius (1 km)
    
    @State private var showRatingFilter = false
    @State private var selectedRating: Double = 0.0 // Default rating
    
    @State private var showLikesFilter = false
    @State private var selectedLikes: Int = 0 // Default likes
    
    @State private var showAppFilter = false
    @State private var selectedAppFilters: [String] = [] // Selected app filter IDs
    
    @State private var showContactFilter = false
    @State private var selectedContactMethodFilters: [String] = [] // Selected contact method filter IDs
    
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    HStack {
                        Image("search")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .padding(.leading, 8)
                        
                        TextField("Search", text: $searchText)
                            .padding(10)
                            .onChange(of: searchText) { newValue in
                                viewModel.searchText = newValue
                                viewModel.applyFilters()
                            }
                    }
                    .background(Color(hex: "#F7F7F7"))
                    .cornerRadius(8)
                    .padding(.leading, 20)
                    .frame(height: 40)
                    
                    Spacer()
                    
                    Image("notification-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 15)
                    
                    Image("profile-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 20)
                }
                .padding(.top, 50)
                .padding(.bottom, 10)
                
                // Filter Buttons
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    FilterButton(iconName: "location-icon", title: "Location") {
                        showLocationFilter = true
                    }
                    FilterButton(iconName: "price-icon", title: "Price") {
                        showPriceFilter = true
                    }
                    FilterButton(iconName: "rating-icon", title: "Rating") {
                        showRatingFilter = true
                    }
                    FilterButton(iconName: "like-icon", title: "Likes") {
                        showLikesFilter = true
                    }
                    FilterButton(iconName: "app-icon-filter", title: "App") {
                        showAppFilter = true
                    }
                    FilterButton(iconName: "contact-icon", title: "Contact") {
                        showContactFilter = true
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                Divider()
                
                // Product Listings
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.products) { product in
                            NavigationLink(destination: Product_Page(productID: product.id)) {
                                ProductCard(
                                    imageName: product.imageName,
                                    name: product.name,
                                    siteName: product.siteName,
                                    price: "Rs.\(Int(product.price))",
                                    likes: "\(product.likes)",
                                    rating: String(format: "%.1f", product.rating)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                
                // Bottom Navigation Bar
                Divider()
                HStack {
                    NavigationLink(destination: Home()) {
                        BottomNavItem(iconName: "home-icon", title: "Home", isActive: true)
                        }
                    
                        //add nav here
                    Spacer()
                    NavigationLink(destination: Wishlist()) {
                            BottomNavItem(iconName: "heart-icon", title: "Favorites", isActive: false)
                        }
                    Spacer()
                    NavigationLink(destination: Settings()) {
                            BottomNavItem(iconName: "settings-icon", title: "Settings", isActive: false)
                        }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .background(Color(hex: "#102A36"))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
                .padding(.bottom, 30)
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $showLocationFilter) {
                LocationFilterView(
                    selectedLocation: $selectedLocation,
                    selectedRadius: $selectedRadius,
                    isPresented: $showLocationFilter
                ) {
                    viewModel.selectedLocation = selectedLocation
                    viewModel.selectedRadius = selectedRadius
                    viewModel.applyFilters()
                }
            }
            .sheet(isPresented: $showPriceFilter) {
                PriceFilterView(selectedPrice: $selectedPrice, isPresented: $showPriceFilter) {
                    viewModel.selectedPrice = selectedPrice
                    viewModel.applyFilters()
                }
            }
            .sheet(isPresented: $showRatingFilter) {
                RatingFilterView(selectedRating: $selectedRating, isPresented: $showRatingFilter) {
                    viewModel.selectedRating = selectedRating
                    viewModel.applyFilters()
                }
            }
            .sheet(isPresented: $showLikesFilter) {
                LikesFilterView(selectedLikes: $selectedLikes, isPresented: $showLikesFilter) {
                    viewModel.selectedLikes = selectedLikes
                    viewModel.applyFilters()
                }
            }
            .sheet(isPresented: $showAppFilter) {
                AppFilterView(
                    selectedAppFilters: $selectedAppFilters,
                    isPresented: $showAppFilter,
                    allAppFilters: viewModel.allAppFilters
                ) {
                    viewModel.selectedAppFilters = selectedAppFilters
                    viewModel.applyFilters()
                }
            }
            .sheet(isPresented: $showContactFilter) {
                ContactFilterView(
                    selectedContactMethodFilters: $selectedContactMethodFilters,
                    isPresented: $showContactFilter,
                    allContactMethodFilters: viewModel.allContactMethodFilters
                ) {
                    viewModel.selectedContactMethodFilters = selectedContactMethodFilters
                    viewModel.applyFilters()
                }
            }
            .onAppear {
                viewModel.fetchAppFilters {
                    viewModel.fetchContactMethodFilters {
                        viewModel.fetchProducts()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Home()
}

