//
//  Participant.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 30/08/25.
//

import Foundation

struct Participant: Codable, Identifiable {
    var user_id: Int
    var br_id: Int
    var pic: Bool
    var user_name: String?
    
    var id: String{"\(user_id)-\(br_id)"}
}
