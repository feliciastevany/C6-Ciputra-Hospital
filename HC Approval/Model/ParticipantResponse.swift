//
//  ParticipantResponse.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 08/09/25.
//


struct ParticipantResponse: Codable {
    var user_id: Int
    var br_id: Int
    var pic: Bool
    var users: UserData?  

    struct UserData: Codable {
        var user_name: String
    }
}
