import Foundation
import Supabase

class UserService {
    private let client = SupabaseManager.shared.client
    
    func signUp(user: User) async throws {
        let _: [User] = try await client.database
            .from("users")
            .insert(values: [
                "user_id": user.user_id,
                "user_name": user.user_name,
                "user_pass": user.user_pass,
                "user_dept": user.user_dept,
                "user_email": user.user_email,
                "user_phone": user.user_phone,
                "user_active": user.user_active
            ])
            .select()
            .execute()
            .value
    }
}
