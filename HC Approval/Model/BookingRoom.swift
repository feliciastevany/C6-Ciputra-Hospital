//
//  BookingRoom.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct BookingRoom: Codable, Identifiable {
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
    
    var id: Int{br_id}
}
