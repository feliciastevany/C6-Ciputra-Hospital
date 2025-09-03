//
//  BookingCar.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct BookingCar: Codable, Identifiable {
    let bc_id: Int
    let user_id: Int
    let driver_id: Int
    let bc_date: Date
    let bc_start: String
    let bc_end: String
    let bc_from: String
    let bc_desc: String
    let bc_people: Int
    let bc_status: String
    let bc_decline_reason: String
    let carpool_req: Bool
    let carpool_desc: String
    let created_at: Date
    
    var id: Int { bc_id }
    
    let user: User?
    let driver: Driver?
    let destination: [Destination]? // one to many
    
    enum CodingKeys: String, CodingKey {
        case bc_id, user_id, driver_id, bc_date, bc_start, bc_end, bc_from, bc_desc, bc_people, bc_status, bc_decline_reason, carpool_req, carpool_desc, created_at
        case user, driver, destination
    }
    
    // Custom decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        bc_id = try container.decode(Int.self, forKey: .bc_id)
        user_id = try container.decode(Int.self, forKey: .user_id)
        driver_id = try container.decode(Int.self, forKey: .driver_id)
        bc_start = try container.decode(String.self, forKey: .bc_start)
        bc_end = try container.decode(String.self, forKey: .bc_end)
        bc_from = try container.decode(String.self, forKey: .bc_from)
        bc_desc = try container.decode(String.self, forKey: .bc_desc)
        bc_people = try container.decode(Int.self, forKey: .bc_people)
        bc_status = try container.decode(String.self, forKey: .bc_status)
        bc_decline_reason = try container.decode(String.self, forKey: .bc_decline_reason)
        carpool_req = try container.decode(Bool.self, forKey: .carpool_req)
        carpool_desc = try container.decode(String.self, forKey: .carpool_desc)
        
        user = try container.decodeIfPresent(User.self, forKey: .user)
        driver = try container.decodeIfPresent(Driver.self, forKey: .driver)
        destination = try container.decodeIfPresent([Destination].self, forKey: .destination)

        
        // bc_date format yyyy-MM-dd
        let dateString = try container.decode(String.self, forKey: .bc_date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) {
            bc_date = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .bc_date, in: container, debugDescription: "Invalid date format: \(dateString)")
        }
        
        // created_at ISO8601
        let createdAtString = try container.decode(String.self, forKey: .created_at)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: createdAtString) {
            created_at = date
        } else {
            // fallback ke yyyy-MM-dd
            if let date = dateFormatter.date(from: createdAtString) {
                created_at = date
            } else {
                throw DecodingError.dataCorruptedError(forKey: .created_at, in: container, debugDescription: "Invalid created_at format: \(createdAtString)")
            }
        }
    }
    
    // Custom encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(bc_id, forKey: .bc_id)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(driver_id, forKey: .driver_id)
        try container.encode(bc_start, forKey: .bc_start)
        try container.encode(bc_end, forKey: .bc_end)
        try container.encode(bc_from, forKey: .bc_from)
        try container.encode(bc_desc, forKey: .bc_desc)
        try container.encode(bc_people, forKey: .bc_people)
        try container.encode(bc_status, forKey: .bc_status)
        try container.encode(bc_decline_reason, forKey: .bc_decline_reason)
        try container.encode(carpool_req, forKey: .carpool_req)
        try container.encode(carpool_desc, forKey: .carpool_desc)
        
        // Encode bc_date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        try container.encode(dateFormatter.string(from: bc_date), forKey: .bc_date)
        
        // Encode created_at ke ISO8601
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        try container.encode(isoFormatter.string(from: created_at), forKey: .created_at)
        
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(driver, forKey: .driver)
        try container.encodeIfPresent(destination, forKey: .destination)
    }
}
