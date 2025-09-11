//
//  UserPickerView.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 30/08/25.
//

import SwiftUI

struct UserPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedUsers: [User]
    
    @State private var users: [User] = []
    @State private var tempSelectedUsers: [User] = []
    @State private var searchText: String = ""
    
    // Filter user sesuai search (kalau kosong → tampil semua)
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.user_name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search field di atas list
                TextField("Search users...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                List(filteredUsers) { user in
                    Button(action: {
                        if let index = tempSelectedUsers.firstIndex(where: { $0.user_id == user.user_id }) {
                            tempSelectedUsers.remove(at: index)
                        } else {
                            tempSelectedUsers.append(user)
                        }
                    }) {
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 30, height: 30)
                                .overlay(Text(String(user.user_name.prefix(1))))
                            Text(user.user_name)
                            Spacer()
                            if tempSelectedUsers.contains(where: { $0.user_id == user.user_id }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Participants")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        selectedUsers = tempSelectedUsers
                        dismiss()
                    }
                }
            }
            .task {
                await fetchUsers()
                tempSelectedUsers = selectedUsers
            }
        }
    }
    
    func fetchUsers() async {
        do {
            let response: [User] = try await SupabaseManager.shared.client
                .from("users")
                .select()
                .eq("user_active", value: true)
                .execute()
                .value
            DispatchQueue.main.async {
                users = response
            }
        } catch {
            print("Error fetch users: ", error)
        }
    }
}
