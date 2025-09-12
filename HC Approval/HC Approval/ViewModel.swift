//
//  ViewModel.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 01/09/25.
//

import SwiftUI

@MainActor
class BookingSearchViewModel: ObservableObject {
    @Published var availableRooms: [RoomAvailability] = []
    @Published var availableDrivers: [DriverAvailability] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func searchRoom(date: String, capacity: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            availableRooms = try await SupabaseManager.shared.findAvailableRooms(date: date, capacity: capacity)
            
            if availableRooms.allSatisfy({ $0.availableSlots.isEmpty }) {
                errorMessage = "Tidak ada slot untuk tanggal ini. Silakan pilih tanggal lain."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func searchDriver(date: String) async {
        isLoading = true
        errorMessage = nil
        do {
            availableDrivers = try await SupabaseManager.shared.findAvailableDrivers(date: date)
            
            if availableDrivers.allSatisfy({ $0.availableSlots.isEmpty }) {
                errorMessage = "Tidak ada slot untuk tanggal ini. Silakan pilih tanggal lain."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
