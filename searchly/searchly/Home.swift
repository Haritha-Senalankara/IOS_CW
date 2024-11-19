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
    
    @State private var isLoading: Bool = true
    
    @StateObject private var viewModel = ProductViewModel()
    @State private var showPriceFilter = false
    @State private var selectedMinPrice: Double = 0
    @State private var selectedMaxPrice: Double = 1000000
    
    @State private var showLocationFilter = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var selectedRadius: Double = 1000
    
    @State private var showRatingFilter = false
    @State private var selectedRating: Double = 0.0
    
    @State private var showLikesFilter = false
    @State private var selectedLikes: Int = 0 
    
    @State private var showAppFilter = false
    @State private var selectedAppFilters: [String] = []
    
    @State private var showContactFilter = false
    @State private var selectedContactMethodFilters: [String] = []
    
    
    // Navigation States
    @State private var searchText: String = ""
    @State private var selectedTab: BottomNavBar.NavTab = .home
    @State private var navigateToProfile = false
    @State private var navigateToNotification = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
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
                            if isLoading{
                                ProgressView()
                                    .scaleEffect(3)
                                    .padding(.top,200)
                                    .padding(.leading,170)
                            }
                            else{
                                ForEach(viewModel.products) { product in
                                    NavigationLink(value: product.id) {
                                        ProductCard(
                                            imageName: product.imageName,
                                            name: product.name,
                                            siteName: product.siteName,
                                            price: "\(Int(product.price))",
                                            likes: "\(product.likes)",
                                            rating: String(format: "%.1f", product.rating)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
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
            .navigationDestination(for: String.self) { productID in
                Product_Page(productID: productID)
            }
            
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    isLoading = false
                }
            }
            
            .onChange(of: searchText) { newValue in
                viewModel.searchText = newValue
                viewModel.applyFilters()
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            setCustomerLoggedIn()
        }
    }
    
    private func setCustomerLoggedIn(){
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isLoggedOut")
        defaults.synchronize()
    }
}

// MARK: - Preview
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
