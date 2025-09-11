//
//  ProfilView.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 29/08/25.
//


import SwiftUI

struct ProfilView: View {
    let userId: Int
    
    @State private var user: UserResponse?
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    @State private var showEditSheet = false
    @State private var isLoggedOut = false
    
    @State private var showPassword = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading profile...")
                } else if let user = user {
                    Form {
                        Section(header: HStack {
                            Text("Profile Details")
                            Spacer()
                            Button(action: {
                                showEditSheet = true
                            }) {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(.primary)
                            }
                        }) {
                            profileRow(title: "Name", value: user.user_name)
                            profileRow(title: "Department", value: user.user_dept)
                            profileRow(title: "Email", value: user.user_email)
                            profileRow(title: "Phone", value: user.user_phone ?? "-")
                            
                            HStack {
                                Text("Password")
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(showPassword ? .blue : .gray)
                                        .padding(.trailing, 15)
                                }.accessibilityLabel("Hide")
                                    .accessibilityHint("Tap to see the password")
                                
                                Spacer()
                                
                            
                                ZStack(alignment: .trailing) {
                                    if showPassword {
                                        TextField("Password", text: .constant(user.user_pass ?? ""))
                                            .multilineTextAlignment(.trailing)
                                            .foregroundColor(.gray)
                                            .textContentType(.password)
                                    } else {
                                        SecureField("Password", text: .constant(user.user_pass ?? ""))
                                            .multilineTextAlignment(.trailing)
                                            .foregroundColor(.gray)
                                            .textContentType(.password)
                                    }
                                }
                            }
                        }
                        
                        Button(role: .destructive) {
                            logout()
                        } label: {
                            HStack {
                                Text("Logout").accessibilityHint("Tap to log out and return to the login screen")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                        }
                        .navigationDestination(isPresented: $isLoggedOut) {
                            LoginView()
                        }
                    }
                } else {
                    Text(errorMessage.isEmpty ? "User not found" : errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
            .accessibilityLabel("Halaman profil")
            .task {
                await loadUser()
            }
            .sheet(isPresented: $showEditSheet) {
                if let user = user {
                    EditProfileView(user: user) { updatedUser in
                        self.user = updatedUser
                    }
                }
            }
            .navigationDestination(isPresented: $isLoggedOut) {
                LoginView()
            }
        }
    }
    
    @ViewBuilder
    func profileRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
    
    private func loadUser() async {
        do {
            isLoading = true
            if let fetched = try await UserService().fetchUser(byId: userId) {
                await MainActor.run {
                    user = fetched
                    isLoading = false
                }
            } else {
                await MainActor.run {
                    errorMessage = "User not found."
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error loading user: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func logout() {
        UserDefaults.standard.removeObject(forKey: "loggedInUserId")
        isLoggedOut = true
    }
}


struct ProfilView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilView(userId: 2)
    }
}
