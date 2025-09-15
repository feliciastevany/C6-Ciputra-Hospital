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
            .select("*, room:rooms(*), user: users(*), participant:participants_br(*, user:users(*))")
        if let userId {
//            roomQuery = roomQuery.or("user_id.eq.\(userId),participant.user_id.eq.\(userId)")
            roomQuery = roomQuery.or("user_id.eq.\(userId),user_id.eq.\(userId)", referencedTable: "participants_br")

        }
        
        let responseRooms = try await roomQuery.execute()
        let rooms: [BookingRoomJoined] = try JSONDecoder.bookingDecoder.decode(
            [BookingRoomJoined].self,
            from: responseRooms.data
        )
        
        var carQuery = client
            .from("bookings_car")
            .select("""
                    *, 
                    destination:destinations(*), 
                    driver:drivers(*),
                    user:users!bookings_car_user_id_fkey(*),
                    carpool_user:users!bookings_car_carpool_req_id_fkey(*),
                    participant:participants_bc(*, user:users(*))
                """)
        if let userId {
            carQuery = carQuery.or("user_id.eq.\(userId),carpool_req_id.eq.\(userId)")
        }
        
        let responseCars = try await carQuery.execute()
        let cars: [BookingCarJoined] = try JSONDecoder.bookingDecoder.decode(
            [BookingCarJoined].self,
            from: responseCars.data
        )
        
        return (rooms, cars)
    }
    
    func updateBookingStatus(booking: any AnyBooking, status: String, dec_reason: String) async throws {
        if let roomBooking = booking as? BookingRoomJoined {
            try await client
                .from("bookings_room")
                .update(["br_status": status, "br_decline_reason": dec_reason])
                .eq("br_id", value: roomBooking.br_id)
                .execute()
            print(status, dec_reason)
            
        } else if let carBooking = booking as? BookingCarJoined {
            try await client
                .from("bookings_car")
                .update(["bc_status": status, "bc_decline_reason": dec_reason])
                .eq("bc_id", value: carBooking.bc_id)
                .execute()
            
            print(status, dec_reason)
        }
    }

}


//    func fetchAllBookings() async {
//        do {
//            let responseRooms = try await SupabaseManager.shared.client
//                .from("bookings_room")
//                .select("""
//                        *, room:rooms(*), user: users(*)
//                        """)
//                .execute()
//
//            let rooms: [BookingRoomJoined] = try JSONDecoder.bookingDecoder.decode(
//                [BookingRoomJoined].self,
//                from: responseRooms.data
//            )
//
//            let responseCars = try await SupabaseManager.shared.client
//                .from("bookings_car")
//                .select("""
//                        *, destination:destinations(*), driver:drivers(*), user: users(*)
//                        """)
//                .execute()
//
//            let cars: [BookingCarJoined] = try JSONDecoder.bookingDecoder.decode(
//                [BookingCarJoined].self,
//                from: responseCars.data
//            )
//
//            DispatchQueue.main.async {
//                self.bookingRoom = rooms
//                self.bookingCar = cars
//            }
//            print("respones: ", rooms, cars)
//        } catch {
//            print("Error fetch bookings:", error)
//        }
//    }
