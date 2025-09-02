struct EditProfileView: View {
    @State var user: UserResponse
    var onSave: (UserResponse) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
                    TextField("Name", text: $user.user_name)
                    TextField("Department", text: $user.user_dept)
                    TextField("Email", text: $user.user_email)
                    TextField("Phone", text: Binding($user.user_phone, replacingNilWith: ""))
                    SecureField("Password", text: $user.user_pass)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            do {
                                try await UserService().updateUser(user: user)
                                onSave(user) // update state di ProfilView
                                dismiss()
                            } catch {
                                print("Update failed: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
}

// helper buat binding optional String
extension Binding where Value == String? {
    init(_ source: Binding<String?>, replacingNilWith defaultValue: String) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}
