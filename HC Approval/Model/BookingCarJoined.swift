//
//  BookingCarJoined.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 28/08/25.
//

import Foundation

struct BookingCarJoined: Codable, Identifiable {
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
    let carpool_req_id: Int?
    let carpool_status: String
    let carpool_desc: String
    let created_at: Date
    
    let driver: Driver?
    let destination: [Destination]?
    let user: User?
    let carpool_user: User?
    let participant: [ParticipantBc]?
    
    var id: Int { bc_id }
}
