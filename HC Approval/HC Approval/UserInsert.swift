// UserInsert.swift
import Foundation

struct UserInsert: Encodable {
    var user_name: String
    var user_pass: String
    var user_dept: String
    var user_email: String
    var user_phone: String
    var user_active: Bool
}
