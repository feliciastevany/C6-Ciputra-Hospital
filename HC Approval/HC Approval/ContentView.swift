//
//  ContentView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 26/08/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ApprovalsView()
                .tabItem {
                    Image(systemName: "checkmark.square")
                    Text("Approvals")
                    
//                    Label("Home", systemImage: "house.fill")
                }
            ApprovalsView()
                .tabItem {
                    Image(systemName: "text.page")
                    Text("Bookings")
//                    Label("Home", systemImage: "house.fill")
                }
            ApprovalsView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Meeting Room")
//                    Label("Home", systemImage: "house.fill")
                }
            ApprovalsView()
                .tabItem {
                    Image(systemName: "car")
                    Text("Operational Car")
//                    Label("Home", systemImage: "house.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
