//
//  ParticipantBr.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 03/09/25.
//

import Foundation

struct ParticipantBr: Codable, Identifiable {
    let user_id: Int
    let br_id: Int
    let pic: Bool
    
    var user_name: String?
    
    var id: String{"\(user_id)-\(br_id)"}
}
