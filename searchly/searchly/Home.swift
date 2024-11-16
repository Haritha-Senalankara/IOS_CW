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
    @State private var selectedMinPrice: Double = 0 // Default min price
    @State private var selectedMaxPrice: Double = 1000000 // Default max price
    
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
    
    
    // Navigation States
    @State private var searchText: String = ""
    @State private var selectedTab: BottomNavBar.NavTab = .home
    @State private var navigateToProfile = false
    @State private var navigateToNotification = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Navigation Bar
                // Inside your Home view's body, where you initialize TopNavBar
                TopNavBar(
                    searchText: $searchText,
                    onProfileTap: {
                        navigateToProfile = true
                    },
                    onNotificationTap: {
                        navigateToNotification = true
                    },
                    onSearchBarTap: {
                        if selectedTab != .home {
                            selectedTab = .home
                        }
                    }
                )
                
                // Conditionally Display Content Based on Selected Tab
                if selectedTab == .home {
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
                                NavigationLink(value: product.id) { // Use 'value' instead of 'destination'
                                    ProductCard(
                                        imageName: product.imageName,
                                        name: product.name,
                                        siteName: product.siteName,
                                        price: "\(Int(product.price))",
                                        likes: "\(product.likes)",
                                        rating: String(format: "%.1f", product.rating)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle()) // Optional: Remove default button styling
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                } else if selectedTab == .favorites {
                    // Favorites Content
                    Wishlist()
                } else if selectedTab == .settings {
                    // Settings Content
                    Settings()
                }
                
                Spacer() // Pushes content to the top
                
                // Bottom Navigation Bar
                BottomNavBar(selectedTab: selectedTab) { tab in
                    selectedTab = tab
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            // Navigation Destinations for Product Pages
            .navigationDestination(for: String.self) { productID in
                Product_Page(productID: productID)
            }
            // Sheets for Profile and Notifications
            .sheet(isPresented: $navigateToProfile) {
                Customer_Profile()
            }
            .sheet(isPresented: $navigateToNotification) {
                Notifications()
            }
            // Sheets for Filters
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
                PriceFilterView(
                    selectedMinPrice: $selectedMinPrice,
                    selectedMaxPrice: $selectedMaxPrice,
                    isPresented: $showPriceFilter
                ) {
                    viewModel.selectedMinPrice = selectedMinPrice
                    viewModel.selectedMaxPrice = selectedMaxPrice
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
            // After your existing modifiers in the Home view, add:
            .onChange(of: searchText) { newValue in
                viewModel.searchText = newValue
                viewModel.applyFilters()
            }
        }
        .navigationBarHidden(true) // Hide the default navigation bar
    }
    
    
}

// MARK: - Preview
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
