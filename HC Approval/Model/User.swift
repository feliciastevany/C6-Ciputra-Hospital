//
//  User.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 27/08/25.
//
import Foundation

struct User: Codable, Identifiable {
    var user_id: Int
    var user_name: String
    var user_pass: String
    var user_dept: String
    var user_email: String
    var user_phone: String
    var user_active: Bool
    
    // biar cocok sama Identifiablenya, jadi id refer ke user_id
    var id: Int {user_id}
}
