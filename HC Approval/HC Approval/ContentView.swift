//
//  ContentView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 26/08/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentUser: UserResponse?
    @AppStorage("loggedInUserId") var loggedInUserId: Int = 0
    
    var body: some View {
        TabView {
            if currentUser?.user_dept == "Human Capital" {
                ApprovalsView()
                    .tabItem {
                        Image(systemName: "checkmark.square")
                        Text("Approvals")
                    }
            }
            ApprovalsView()
                .tabItem {
                    Image(systemName: "text.page")
                    Text("Bookings")
                }
            MeetingRoomView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Meeting Room")
                }
            OperationalCarView()
                .tabItem {
                    Image(systemName: "car")
                    Text("Operational Car")
                }
        }
        .task {
            do {
                currentUser = try await UserService().fetchUser(byId: loggedInUserId)
            } catch {
                print("Error fetching user: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
