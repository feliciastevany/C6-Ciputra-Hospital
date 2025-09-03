//
//  BookingService.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 03/09/25.
//

import Foundation
import Supabase

struct BookingInsert: Codable {
    let room_id: Int
    let user_id: Int
    let br_event: String
    let br_date: String   // yyyy-MM-dd
    let br_start: String  // HH:mm
    let br_end: String    // HH:mm
    let br_desc: String
    let br_status: String
}

//struct BookingUpdate: Codable {
//    let br_id: Int
//    let br_event: String
//    let br_date: String
//    let br_start: String
//    let br_end: String
//    let br_desc: String
//    let br_status: String
//}

class BookingService {
    static let shared = BookingService()
    private let client = SupabaseManager.shared.client
    
    // MARK: - Booking
    
    func createBooking(_ booking: BookingInsert) async throws -> BookingRoom? {
        let response: [BookingRoom] = try await client
            .from("bookings_room")
            .insert(booking)
            .select()
            .execute()
            .value
        return response.first
    }
    
    func fetchBookings(roomId: Int, date: String) async throws -> [BookingRoom] {
        try await client
            .from("bookings_room")
            .select()
            .eq("room_id", value: roomId)
            .eq("br_date", value: date)
            .execute()
            .value
    }
    
    // MARK: - Participants
    
    func addParticipants(_ participants: [Participant]) async throws {
        try await client
            .from("participants")
            .insert(participants)
            .execute()
    }
    
    func fetchParticipants(brId: Int) async throws -> [Participant] {
        try await client
            .from("participants")
            .select()
            .eq("br_id", value: brId)
            .execute()
            .value
    }
    
    // MARK: - Properties Detail
    
    func addProperties(_ details: [BookingRoomDetail]) async throws {
        try await client
            .from("br_details")
            .insert(details)
            .execute()
    }
    
    func fetchProperties(brId: Int) async throws -> [BookingRoomDetail] {
        try await client
            .from("br_details")
            .select()
            .eq("br_id", value: brId)
            .execute()
            .value
    }
}
