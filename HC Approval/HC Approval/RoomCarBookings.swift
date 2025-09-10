//
//  AllBookings.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 29/08/25.
//
import Foundation

protocol AnyBooking: Identifiable {
    var bookId: UUID { get }
    var createdAt: Date { get }
    var status: String { get }
    var type: BookingType { get }
    var title: String { get } // supaya bisa ditampilkan di list
    var pic: String { get }
}

extension BookingRoomJoined: AnyBooking {
    var bookId: UUID { UUID(uuidString: "ROOM-\(br_id)") ?? UUID() }
    var createdAt: Date { created_at }
    var status: String { br_status }
    var type: BookingType { .rooms }
    var title: String { room?.room_name ?? "Unknown Room" }
    var pic: String { "\(user?.user_name ?? "Unknown") (\(user?.user_dept ?? "Unknown"))" }
}

extension BookingCarJoined: AnyBooking {
    var bookId: UUID { UUID(uuidString: "CAR-\(bc_id)") ?? UUID() }
    var createdAt: Date { created_at }
    var status: String { bc_status }
    var type: BookingType { .cars }
    var title: String { driver?.driver_name ?? "Unknown Driver" }
    var pic: String { "\(user?.user_name ?? "Unknown") (\(user?.user_dept ?? "Unknown"))" }
}
