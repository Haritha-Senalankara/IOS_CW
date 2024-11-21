//
//  AppFilterView.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation

// MARK: - AppFilterView
struct AppFilterView: View {
    @Binding var selectedAppFilters: [String]
    @Binding var isPresented: Bool
    var allAppFilters: [AppFilter]
    var onApply: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Apps")
                .font(.title)
                .padding(.top, 20)
            
            List(allAppFilters) { appFilter in
                MultipleSelectionRowWithImage(
                    title: appFilter.name,
                    imageURL: appFilter.imageURL,
                    isSelected: selectedAppFilters.contains(appFilter.id)
                ) {
                    if selectedAppFilters.contains(appFilter.id) {
                        selectedAppFilters.removeAll(where: { $0 == appFilter.id })
                    } else {
                        selectedAppFilters.append(appFilter.id)
                    }
                }
            }
            
            Button(action: {
                isPresented = false
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
    }
}
