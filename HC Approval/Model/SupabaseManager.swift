//
//  SupabaseManager.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 27/08/25.
//

import Supabase
import Foundation

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://ekgaqkbgcwwwmrzvmlah.supabase.co")!,
        supabaseKey:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrZ2Fxa2JnY3d3d21yenZtbGFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyODU5NTMsImV4cCI6MjA3MTg2MTk1M30.wMY_xQD7wM4tZM4ABT7hwIqP-b_0DkSsk68XDh_w10U"
    )
}
