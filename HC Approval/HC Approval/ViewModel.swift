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
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func search(date: String, capacity: Int) async {
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
    
//    func insertBooking(roomId: Int, start: String, end: String, date: String, userId: String) async {
//            do {
//                let payload: [String: Any] = [
//                    "room_id": roomId,
//                    "br_start": start,
//                    "br_end": end,
//                    "br_date": date,
//                    "user_id": userId
//                ]
//                
//                try await client.database
//                    .from("booking_rooms")
//                    .insert(values: payload)
//                    .execute()
//                
//                successMessage = "Booking berhasil dibuat!"
//            } catch {
//                errorMessage = "Gagal booking: \(error.localizedDescription)"
//            }
//        }
}
