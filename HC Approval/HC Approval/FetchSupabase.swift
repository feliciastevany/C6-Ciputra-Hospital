//
//  FetchSupabase.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 03/09/25.
//
import Foundation
import Supabase

extension SupabaseManager {
    func fetchBookings(for userId: Int? = nil) async throws -> ([BookingRoomJoined], [BookingCarJoined]) {
        var roomQuery = client
            .from("bookings_room")
            .select("*, room:rooms(*), user: users(*)")
        if let userId {
            roomQuery = roomQuery.eq("user_id", value: userId)
        }
        
        let responseRooms = try await roomQuery.execute()
        let rooms: [BookingRoomJoined] = try JSONDecoder.bookingDecoder.decode(
            [BookingRoomJoined].self,
            from: responseRooms.data
        )
        
        var carQuery = client
            .from("bookings_car")
            .select("*, destination:destinations(*), driver:drivers(*), user: users(*)")
        if let userId {
            carQuery = carQuery.eq("user_id", value: userId)
        }
        
        let responseCars = try await carQuery.execute()
        let cars: [BookingCarJoined] = try JSONDecoder.bookingDecoder.decode(
            [BookingCarJoined].self,
            from: responseCars.data
        )
        
        return (rooms, cars)
    }
}

