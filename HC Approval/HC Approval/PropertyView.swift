//
//  PropertyView.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 09/09/25.
//

import SwiftUI
import Supabase

struct PropertyView: View {
    var brId: Int // brId yang dipilih
    @Environment(\.dismiss) var dismiss // Untuk menutup sheet
    @State private var brDetails: [BookingRoomDetail] = [] // Untuk menyimpan data dari br_details
    @State private var properties: [Property] = [] // Untuk menyimpan data dari properties
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)").foregroundColor(.red)
                } else {
                    List(brDetails, id: \.id) { detail in
                        if let property = properties.first(where: { $0.properties_id == detail.properties_id }) {
                            HStack {
                                Text(property.properties_name)
                                Spacer()
                                Text("Qty: \(detail.qty)")
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Properties") // Judul untuk halaman
            .toolbar {
                // Tombol Cancel
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss() // Menutup sheet
                    }
                }
            }
        }
        .onAppear {
            fetchProp() // Mengambil data saat tampilan muncul
        }
    }

    func fetchProp() {
        isLoading = true
        Task {
            do {
                // Ambil data dari br_details berdasarkan br_id
                let brResponse: [BookingRoomDetail] = try await SupabaseManager.shared.client
                    .from("br_details")
                    .select("*")
                    .eq("br_id", value: brId)
                    .execute()
                    .value

                // Ambil data properties berdasarkan properties_id yang ditemukan di br_details
                let propertyIds = Set(brResponse.map { $0.properties_id })
                let propertyResponse: [Property] = try await SupabaseManager.shared.client
                    .from("properties")
                    .select("*")
                    .in("properties_id", value: Array(propertyIds))
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.brDetails = brResponse
                    self.properties = propertyResponse
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

