//
//  Room.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct Room: Codable, Identifiable, Hashable {
    var room_id: Int
    var room_name: String
    var room_capacity: Int
    
    var id: Int{room_id}
}
