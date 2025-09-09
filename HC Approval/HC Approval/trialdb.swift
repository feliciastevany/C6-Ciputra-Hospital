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

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                // Ambil semua driver aktif
                let drivers = try await SupabaseManager.shared.fetchDrivers()
//                print("Drivers:", drivers)
                
                // Kalau mau ambil booking driver pertama di tanggal tertentu
                if let firstDriver = drivers.first {
                    let bookings = try await SupabaseManager.shared.findAvailableDrivers(
                        date: "2025-09-08"
                    )
                    print("Bookings for driver \(firstDriver.driver_name):", bookings)
                }
            } catch {
                print("Error fetching data:", error)
            }
        }
    }
}


#Preview {
    ViewController()
}
