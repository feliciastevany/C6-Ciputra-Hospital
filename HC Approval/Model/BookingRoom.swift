//
//  BookingRoom.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct BookingRoom: Codable, Identifiable {
    var br_id: Int
    var room_id: Int
    var br_event: String
    var br_date: String
    var br_start: String
    var br_end: String
    var br_desc: String
    var br_status: String
    var br_decline_reason: String
    var created_at: Date
    
    var user_id: Int
    
    var id: Int{br_id}
}

extension Date {
    func toDBFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}

extension String {
    func toDateFromDB() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
}
