//
//  Room.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct Room: Codable, Identifiable {
    let room_id: Int
    let room_name: String
    let room_capacity: Int
    
    var id: Int{room_id}
}
