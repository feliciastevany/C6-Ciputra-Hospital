//
//  BookingService.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 03/09/25.
//

//import Foundation
//
//struct BookingService {
//    static func createBooking(
//        room: Room,
//        date: String,
//        startTime: String,
//        endTime: String,
//        eventName: String,
//        eventDesc: String,
//        userId: Int,
//        participants: [User],
//        properties: [SelectedProperty]
//    ) async throws -> BookingRoom {
//        
//        // 1. Insert ke bookings_room
//        let newBooking = [
//            "room_id": room.room_id,
//            "br_event": eventName,
//            "br_date": date,           // pastikan format yyyy-MM-dd
//            "br_start": startTime,
//            "br_end": endTime,
//            "br_desc": eventDesc,
//            "br_status": "Pending",
//            "user_id": userId
//        ] as [String : Any]
//
//        let inserted: [BookingRoom] = try await SupabaseManager.shared.client
//            .from("bookings_room")
//            .insert(newBooking)
//            .select()
//            .execute()
//            .value
//
//        guard let booking = inserted.first else {
//            throw NSError(domain: "BookingService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to insert booking"])
//        }
//
//        // 2. Insert participants (jika ada)
//        if !participants.isEmpty {
//            let data = participants.map { user in
//                [
//                    "br_id": booking.br_id,
//                    "user_id": user.user_id
//                ]
//            }
//
//            try await SupabaseManager.shared.client
//                .from("bookings_room_participants")
//                .insert(data)
//                .execute()
//        }
//
//        // 3. Insert properties (jika ada)
//        if !properties.isEmpty {
//            let data = properties.map { sp in
//                [
//                    "br_id": booking.br_id,
//                    "properties_id": sp.property.properties_id,
//                    "qty": sp.quantity
//                ]
//            }
//
//            try await SupabaseManager.shared.client
//                .from("bookings_room_detail")
//                .insert(data)
//                .execute()
//        }
//
//        return booking
//    }
//}
