//
//  ContactFilterView.swift
//  searchly
//
//  Created by cobsccompy4231p-007 on 2024-11-10.
//

import SwiftUI
import Foundation


struct ContactFilterView: View {
    @Binding var selectedContactMethodFilters: [String]
    @Binding var isPresented: Bool
    var allContactMethodFilters: [ContactMethodFilter]
    var onApply: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Contact Methods")
                .font(.title)
                .padding(.top, 20)
            
            List(allContactMethodFilters) { contactMethodFilter in
                MultipleSelectionRowWithImage(
                    title: contactMethodFilter.name,
                    imageURL: contactMethodFilter.imageURL,
                    isSelected: selectedContactMethodFilters.contains(contactMethodFilter.id)
                ) {
                    if selectedContactMethodFilters.contains(contactMethodFilter.id) {
                        selectedContactMethodFilters.removeAll(where: { $0 == contactMethodFilter.id })
                    } else {
                        selectedContactMethodFilters.append(contactMethodFilter.id)
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
