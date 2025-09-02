//
//  BookingRoomJoined.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 28/08/25.
//

import Foundation

struct BookingRoomJoined: Codable, Identifiable {
    let br_id: Int
    let room_id: Int
    let br_event: String
    let br_date: Date
    let br_start: String
    let br_end: String
    let br_desc: String
    let br_status: String
    let br_decline_reason: String
    let created_at: Date
    
    let room: Room?
    let user: User?
    
    var id: Int { br_id }
}
