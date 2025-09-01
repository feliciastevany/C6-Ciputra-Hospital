//
//  BookingRoom.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct BookingRoom: Codable, Identifiable {
    let br_id: Int
    let user_id: Int
    let room_id: Int
    let br_date: Date
    let br_start: String
    let br_end: String
    let br_desc: String
    let br_status: String
    let br_decline_reason: String
    let created_at: Date
    
    var id: Int { br_id }
    
    // Tambahan relasi
    let user: User?
    let room: Room?
    
    enum CodingKeys: String, CodingKey {
        case br_id, user_id, room_id, br_date, br_start, br_end, br_desc, br_status, br_decline_reason, created_at
        case user, room
    }
    
    // Custom decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        br_id = try container.decode(Int.self, forKey: .br_id)
        user_id = try container.decode(Int.self, forKey: .user_id)
        room_id = try container.decode(Int.self, forKey: .room_id)
        br_start = try container.decode(String.self, forKey: .br_start)
        br_end = try container.decode(String.self, forKey: .br_end)
        br_desc = try container.decode(String.self, forKey: .br_desc)
        br_status = try container.decode(String.self, forKey: .br_status)
        br_decline_reason = try container.decode(String.self, forKey: .br_decline_reason)
        
        user = try container.decodeIfPresent(User.self, forKey: .user)
        room = try container.decodeIfPresent(Room.self, forKey: .room)
        // Custom decoding untuk br_date
        let dateString = try container.decode(String.self, forKey: .br_date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            br_date = date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .br_date,
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        
        // Custom decoding untuk created_at
        let createdAtString = try container.decode(String.self, forKey: .created_at)
        
        // ISO 8601 with fractional seconds
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: createdAtString) {
            created_at = date
        } else {
            // fallback ke yyyy-MM-dd
            if let date = dateFormatter.date(from: createdAtString) {
                created_at = date
            } else {
                throw DecodingError.dataCorruptedError(
                    forKey: .created_at,
                    in: container,
                    debugDescription: "Invalid created_at format: \(createdAtString)"
                )
            }
        }
    }
    
    // Custom encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(br_id, forKey: .br_id)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(room_id, forKey: .room_id)
        try container.encode(br_start, forKey: .br_start)
        try container.encode(br_end, forKey: .br_end)
        try container.encode(br_desc, forKey: .br_desc)
        try container.encode(br_status, forKey: .br_status)
        try container.encode(br_decline_reason, forKey: .br_decline_reason)
        
        // Encode br_date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        try container.encode(dateFormatter.string(from: br_date), forKey: .br_date)
        
        // Encode created_at ke ISO8601
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        try container.encode(isoFormatter.string(from: created_at), forKey: .created_at)
    }
}
