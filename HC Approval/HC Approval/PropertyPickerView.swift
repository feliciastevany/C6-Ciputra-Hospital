//
//  PropertyPickerView.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 30/08/25.
//

import SwiftUI

struct PropertyPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedProperties: [SelectedProperty]
    
    @State private var properties: [Property] = []
    @State private var tempSelected: [SelectedProperty] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(properties) { property in
                    HStack {
                        Text(property.properties_name)
                        
                        Spacer()
                        
                        // cari apakah property sudah dipilih
                        if let index = tempSelected.firstIndex(where: { $0.property.id == property.id }) {
                            Stepper(value: $tempSelected[index].quantity, in: 1...99) {
                                Text("\(tempSelected[index].quantity)")
                            }
                            .frame(width: 120)
                        } else {
                            Button("Add") {
                                tempSelected.append(SelectedProperty(property: property, quantity: 1))
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .navigationTitle("Select Properties")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedProperties = tempSelected
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                Task {
                    await fetchProperties()
                    tempSelected = selectedProperties
                }
            }
        }
    }
    
    func fetchProperties() async {
        do {
            let response: [Property] = try await SupabaseManager.shared.client
                .from("properties")
                .select()
                .execute()
                .value
            DispatchQueue.main.async {
                properties = response
            }
        } catch {
            print("Error fetch properties: ", error)
        }
    }
}
