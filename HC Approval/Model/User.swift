//
//  User.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 27/08/25.
//
import Foundation

struct User: Codable, Identifiable {
    let user_id: Int
    let user_name: String
    let user_pass: String
    let user_dept: String
    let user_email: String
    let user_phone: String
    let user_active: Bool
    
    // biar cocok sama Identifiablenya, jadi id refer ke user_id
    var id: Int {user_id}
}
