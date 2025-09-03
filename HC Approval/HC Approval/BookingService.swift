//
//  BookingService.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 03/09/25.
//

import Foundation
import Supabase

struct BookingRoomInsert: Codable {
    let room_id: Int
    let user_id: Int
    let br_event: String
    let br_date: String   // yyyy-MM-dd
    let br_start: String  // HH:mm
    let br_end: String    // HH:mm
    let br_desc: String
    let br_status: String
}

struct BookingCarInsert: Codable {
    var user_id: Int
    var driver_id: Int
    var bc_date: String    // yyyy-MM-dd
    var bc_start: String   // HH:mm
    var bc_end: String     // HH:mm
    var bc_from: String
    var bc_desc: String
    var bc_people: Int
    var bc_status: String
    var bc_decline_reason: String?
    var carpool_req: Bool
    var carpool_desc: String?
    var carpool_status: String?
}

struct DestinationInsert: Codable {
    var destination_name: String
    var bc_id: Int
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
    
    // MARK: - Booking Room
    
    func createBookingRoom(_ booking: BookingRoomInsert) async throws -> BookingRoom? {
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
            .from("participants_br")
            .insert(participants)
            .execute()
    }
    
    func fetchParticipants(brId: Int) async throws -> [Participant] {
        try await client
            .from("participants_br")
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
    
    // MARK: - Booking Car
    func createBookingCar(_ booking: BookingCarInsert) async throws -> BookingCar? {
        let response: [BookingCar] = try await client
            .from("bookings_car")
            .insert(booking)
            .select()
            .execute()
            .value
        return response.first
    }

    func fetchBookingsCar(date: String) async throws -> [BookingCar] {
        try await client
            .from("bookings_car")
            .select()
            .eq("bc_date", value: date)
            .execute()
            .value
    }
    
    func fetchDrivers() async throws -> [Driver] {
        try await client
            .from("drivers")
            .select()
            .eq("driver_active", value: true)
            .execute()
            .value
    }
    
    func addDestinations(_ destinations: [DestinationInsert]) async throws -> [Destination] {
        let response: [Destination] = try await client
            .from("destinations")
            .insert(destinations)
            .select()
            .execute()
            .value
        return response
    }

}
