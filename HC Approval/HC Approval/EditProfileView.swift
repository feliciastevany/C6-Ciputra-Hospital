//
//  EditProfileView.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 29/08/25.
//

import SwiftUI

struct EditProfileView: View {
    // incoming immutable user
    let user: UserResponse
    // callback untuk mengirim user yang sudah di-update ke ProfilView
    var onSave: (UserResponse) -> Void

    // local editable states
    @State private var name: String
    @State private var department: String
    @State private var email: String
    @State private var phone: String
    @State private var password: String

    @State private var isPasswordVisible = false // To control password visibility

    @Environment(\.dismiss) private var dismiss

    // inisialisasi state dari user yang dikirim
    init(user: UserResponse, onSave: @escaping (UserResponse) -> Void) {
        self.user = user
        self.onSave = onSave
        _name = State(initialValue: user.user_name)
        _department = State(initialValue: user.user_dept)
        _email = State(initialValue: user.user_email)
        _phone = State(initialValue: user.user_phone ?? "")
        _password = State(initialValue: user.user_pass)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Name", text: $name)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text("Department")
                        Spacer()
                        TextField("Department", text: $department)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text("Email")
                        Spacer()
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text("Phone")
                        Spacer()
                        TextField("Phone", text: $phone)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text("Password")
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(isPasswordVisible ? .blue : .gray)
                                .padding(.trailing, 15) // Adjust the padding to position it to the right
                        }
                        Spacer()
                        
                        ZStack(alignment: .trailing) {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.primary)
                                    .textContentType(.password)
                            } else {
                                SecureField("Password", text: $password)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.primary)
                                    .textContentType(.password)
                            }
                            
                            // Eye Icon Button for toggling password visibility
                            
                        }
                    }

                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task { await saveChanges() }
                    }
                }
            }
        }
    }

    // build updated user and call service
    private func saveChanges() async {
        let updatedUser = UserResponse(
            user_id: user.user_id,
            user_name: name,
            user_email: email,
            user_pass: password,
            user_dept: department,
            user_phone: phone.isEmpty ? nil : phone,
            user_active: user.user_active
        )

        do {
            try await UserService().updateUser(user: updatedUser)
            await MainActor.run {
                onSave(updatedUser)
                dismiss()
            }
        } catch {
            await MainActor.run {
                print("Update failed: \(error.localizedDescription)")
            }
        }
    }
}


struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(user: UserResponse(
            user_id: 1,
            user_name: "John Doe",
            user_email: "john.doe@example.com",
            user_pass: "password123",
            user_dept: "Engineering",
            user_phone: "1234567890",
            user_active: true
        ), onSave: { updatedUser in
            print("Updated User: \(updatedUser)")
        })
        .previewDevice("iPhone 13")
    }
}

