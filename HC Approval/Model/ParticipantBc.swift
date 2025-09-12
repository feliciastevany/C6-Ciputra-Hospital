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
    
    // Custom init biar user default nil
    init(user_id: Int, bc_id: Int, pic: Bool, user: User? = nil) {
        self.user_id = user_id
        self.bc_id = bc_id
        self.pic = pic
        self.user = user
    }
}
