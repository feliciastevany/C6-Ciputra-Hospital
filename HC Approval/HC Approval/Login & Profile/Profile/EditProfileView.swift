//
//  EditProfileView.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 29/08/25.
//

import SwiftUI

struct EditProfileView: View {
    let user: UserResponse
    var onSave: (UserResponse) -> Void

    @State private var name: String
    @State private var department: String
    @State private var email: String
    @State private var phone: String
    @State private var password: String

    @State private var isPasswordVisible = false
    @State private var showCancelAlert = false
    @State private var hasChanges = false

    @Environment(\.dismiss) private var dismiss

    let departments = ["Human Capital", "Marketing", "Finance", "Building & Facilities", "IT"]

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
                            .onChange(of: name) { _ in checkForChanges() }
                    }

                    Picker("Department", selection: $department) {
                        ForEach(departments, id: \.self) { dept in
                            Text(dept).tag(dept)
                        }
                    }
                    .onChange(of: department) { _ in checkForChanges() }

                    HStack {
                        Text("Email")
                        Spacer()
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: email) { _ in checkForChanges() }
                    }

                    HStack {
                        Text("Phone")
                        Spacer()
                        TextField("Phone", text: $phone)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: phone) { _ in checkForChanges() }
                    }

                    HStack {
                        Text("Password")
                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(isPasswordVisible ? .blue : .gray)
                                .padding(.trailing, 15)
                        }
                        Spacer()

                        ZStack(alignment: .trailing) {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .multilineTextAlignment(.trailing)
                                    .textContentType(.password)
                                    .onChange(of: password) { _ in checkForChanges() }
                            } else {
                                SecureField("Password", text: $password)
                                    .multilineTextAlignment(.trailing)
                                    .textContentType(.password)
                                    .onChange(of: password) { _ in checkForChanges() }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if hasChanges {
                            showCancelAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task { await saveChanges() }
                    }
                }
            }
            .alert("Are you sure you want to discard changes?",
                   isPresented: $showCancelAlert) {
                Button("No", role: .cancel) { }
                Button("Yes", role: .destructive) {
                    dismiss()
                }
            }
        }
    }

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
            print("Update failed: \(error.localizedDescription)")
        }
    }

    private func checkForChanges() {
        hasChanges =
            name != user.user_name ||
            department != user.user_dept ||
            email != user.user_email ||
            phone != (user.user_phone ?? "") ||
            password != user.user_pass
    }
}
