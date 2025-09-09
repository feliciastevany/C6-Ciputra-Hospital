//
//  ParticipantBr.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 03/09/25.
//

import Foundation

struct ParticipantBc: Codable, Identifiable {
    let user_id: Int
    let bc_id: Int
    let pic: Bool
    
    let user: User?
    
    var id: String{"\(user_id)-\(bc_id)"}
}
