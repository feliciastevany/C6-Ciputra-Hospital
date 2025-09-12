//
//  SupabaseManager.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 27/08/25.
//

import Supabase
import Foundation

//class SupabaseManager {
//    static let shared = SupabaseManager()
//    
//    let client = SupabaseClient(
//        supabaseURL: URL(string: "https://ekgaqkbgcwwwmrzvmlah.supabase.co")!,
//        supabaseKey:
//            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrZ2Fxa2JnY3d3d21yenZtbGFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyODU5NTMsImV4cCI6MjA3MTg2MTk1M30.wMY_xQD7wM4tZM4ABT7hwIqP-b_0DkSsk68XDh_w10U"
//    )
//}

struct TimeSlot: Identifiable {
    let id = UUID()
    let start: String
    let end: String
}

struct RoomAvailability: Identifiable {
    let id = UUID()
    let room: Room
    let bookings: [BookingRoom]
    let availableSlots: [TimeSlot]
}

struct DriverAvailability: Identifiable {
    let id = UUID()
    let driver: Driver
    let bookings: [BookingCar]
    let availableSlots: [TimeSlot]
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}

class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://ekgaqkbgcwwwmrzvmlah.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrZ2Fxa2JnY3d3d21yenZtbGFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyODU5NTMsImV4cCI6MjA3MTg2MTk1M30.wMY_xQD7wM4tZM4ABT7hwIqP-b_0DkSsk68XDh_w10U"
        )
    }
    
    func fetchRooms(minCapacity: Int) async throws -> [Room] {
        try await client
            .from("rooms")
            .select()
            .gte("room_capacity", value: minCapacity)
            .execute()
            .value
    }
    
    func fetchRoomBookings(roomId: Int, date: String) async throws -> [BookingRoom] {
        try await client
            .from("bookings_room")
            .select()
            .eq("room_id", value: roomId)
            .eq("br_date", value: date)
            .order("br_start", ascending: true)
            .execute()
            .value
    }
    
    func findAvailableRooms(date: String, capacity: Int) async throws -> [RoomAvailability] {
        let rooms = try await fetchRooms(minCapacity: capacity)
        var result: [RoomAvailability] = []
        
        for room in rooms {
            let bookings = try await fetchRoomBookings(roomId: room.room_id, date: date)
            let availableSlots = calculateAvailableRoomSlots(for: bookings)
            result.append(RoomAvailability(room: room, bookings: bookings, availableSlots: availableSlots))
        }
        
        return result
    }
    
    func fetchDrivers() async throws -> [Driver] {
        try await client
            .from("drivers")
            .select()
            .eq("driver_active", value: true)
            .execute()
            .value
    }
    
    func fetchBookingsCar(driverId: Int, date: String) async throws -> [BookingCar] {
        try await client
            .from("bookings_car")
            .select()
            .eq("driver_id", value: driverId)
            .eq("bc_date", value: date)
            .execute()
            .value
    }
    
    func findAvailableDrivers(date: String) async throws -> [DriverAvailability] {
        let drivers = try await fetchDrivers()
        var result: [DriverAvailability] = []
        
        for driver in drivers {
            let bookings = try await fetchBookingsCar(driverId: driver.driver_id, date: date)
            let availableSlots = calculateAvailableDriverSlots(for: bookings)
            result.append(DriverAvailability(driver: driver, bookings: bookings, availableSlots: availableSlots))
        }
        
        return result
    }
    
    //    private func calculateAvailableRoomSlots(for bookings: [BookingRoom]) -> [TimeSlot] {
    //        var slots: [TimeSlot] = []
    //        let dayStart = "07:30"
    //        let dayEnd = "21:00"
    //
    //        var currentStart = dayStart
    //        for booking in bookings {
    //            if currentStart < booking.br_start {
    //                slots.append(TimeSlot(start: currentStart, end: booking.br_start))
    //            }
    //            currentStart = max(currentStart, booking.br_end)
    //        }
    //        if currentStart < dayEnd {
    //            slots.append(TimeSlot(start: currentStart, end: dayEnd))
    //        }
    //        return slots
    //    }
    //
    //    private func calculateAvailableDriverSlots(for bookings: [BookingCar]) -> [TimeSlot] {
    //        var slots: [TimeSlot] = []
    //        let dayStart = "07:30"
    //        let dayEnd = "21:00"
    //
    //        var currentStart = dayStart
    //        for booking in bookings {
    //            if currentStart < booking.bc_start {
    //                slots.append(TimeSlot(start: currentStart, end: booking.bc_start))
    //            }
    //            currentStart = max(currentStart, booking.bc_end)
    //        }
    //        if currentStart < dayEnd {
    //            slots.append(TimeSlot(start: currentStart, end: dayEnd))
    //        }
    //        return slots
    //    }
    
    private func calculateAvailableRoomSlots(for bookings: [BookingRoom]) -> [TimeSlot] {
        var slots: [TimeSlot] = []
        let dayStart = "07:30"
        let dayEnd = "21:00"
        
        // hanya booking aktif yang dipakai
        let activeBookings = bookings.filter {
            let status = $0.br_status.lowercased()
            return status != "cancelled" && status != "declined"
        }.sorted { $0.br_start < $1.br_start }
        
        var currentStart = dayStart
        for booking in activeBookings {
            if currentStart < booking.br_start {
                slots.append(TimeSlot(start: currentStart, end: booking.br_start))
            }
            currentStart = max(currentStart, booking.br_end)
        }
        if currentStart < dayEnd {
            slots.append(TimeSlot(start: currentStart, end: dayEnd))
        }
        return slots
    }

    private func calculateAvailableDriverSlots(for bookings: [BookingCar]) -> [TimeSlot] {
        var slots: [TimeSlot] = []
        let dayStart = "07:30"
        let dayEnd = "21:00"
        
        // hanya booking aktif yang dipakai
        let activeBookings = bookings.filter {
            let status = $0.bc_status.lowercased()
            return status != "cancelled" && status != "declined"
        }.sorted { $0.bc_start < $1.bc_start }
        
        var currentStart = dayStart
        for booking in activeBookings {
            if currentStart < booking.bc_start {
                slots.append(TimeSlot(start: currentStart, end: booking.bc_start))
            }
            currentStart = max(currentStart, booking.bc_end)
        }
        if currentStart < dayEnd {
            slots.append(TimeSlot(start: currentStart, end: dayEnd))
        }
        return slots
    }
}

