//
//  trialdb.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 27/08/25.
//

import SwiftUI

struct trialdb: View {
    
    @State var drivers: [Driver] = []
    
    var body: some View {
        List(drivers) { driver in
            VStack(alignment: .leading) {
                Text("Id: \(driver.driver_id)")
                Text("Name: \(driver.driver_name)")
                Text("Phone: \(driver.driver_phone)")
                Text("Name: \(driver.driver_active)")
            }
        }
        .task {
            await fetchUsers()
        }
    }
    
    func fetchUsers() async {
        do {
            let response: [Driver] = try await SupabaseManager.shared.client
                .from("drivers")
                .select()
                .execute()
                .value
            print("response: ", response)
            DispatchQueue.main.async {
                drivers = response
            }
        } catch {
            print("Error fetch users: ", error)
        }
    }
}

#Preview {
    trialdb()
}
