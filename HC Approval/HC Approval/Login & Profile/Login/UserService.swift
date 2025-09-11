//
//  UserService.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 28/08/25.
//


import Foundation
import Supabase

class UserService {
    private let client = SupabaseManager.shared.client
    
    // Insert user baru (sign up)
    func signUp(user: User) async throws {
        let newUser = UserInsert(
            user_name: user.user_name,
            user_pass: user.user_pass,
            user_dept: user.user_dept,
            user_email: user.user_email,
            user_phone: user.user_phone,
            user_active: true
        )
        
        try await client
            .from("users")
            .insert(newUser)
            .execute()
    }
    
    // Ambil data user berdasarkan ID
    func fetchUser(byId id: Int) async throws -> UserResponse? {
        let response: [UserResponse] = try await client
            .from("users")
            .select()
            .eq("user_id", value: id)
            .execute()
            .value
        
        return response.first
    }
    
    // Update data user
    func updateUser(user: UserResponse) async throws {
        try await client
            .from("users")
            .update([
                "user_name": user.user_name,
                "user_pass": user.user_pass,
                "user_dept": user.user_dept,
                "user_email": user.user_email,
                "user_phone": user.user_phone,
                "user_active": user.user_active ? "true" : "false"
            ])
            .eq("user_id", value: user.user_id)
            .execute()
    }
}

