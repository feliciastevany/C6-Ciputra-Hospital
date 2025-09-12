//
//  LoginView.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 28/08/25.
//


import SwiftUI
import Supabase

// Struct untuk decode response
struct UserResponse: Codable, Identifiable {
    var user_id: Int
    var user_name: String
    var user_email: String
    var user_pass: String
    var user_dept: String
    var user_phone: String?
    var user_active: Bool
    
    var id: Int { user_id }
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    @AppStorage("loggedInUserId") var loggedInUserId: Int = 0

    @State private var isLoggedIn = false
    @State private var GoToSignUp = false
    
    // Menambahkan state untuk kontrol visibilitas password
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                VStack(spacing: 25) {
                    Spacer()
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Form input
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 1)
                        
                        ZStack {
                            // Password Field (TextField/SecureField)
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(radius: 1)
                                    .textContentType(.password)
                            } else {
                                SecureField("Password", text: $password)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(radius: 1)
                                    .textContentType(.password)
                            }
                            
                            // Eye Icon Button untuk Password
                            HStack {
                                Spacer()
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(isPasswordVisible ? .blue : .gray)
                                        .padding(.trailing, 15)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 20)
                    
                    // Login Button
                    Button(action: {
                        Task { await handleLogin() }
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                        } else {
                            Text("Login")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .padding(.horizontal)
                    
                    // Navigasi ke halaman Sign Up
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Button("Sign Up") {
                            GoToSignUp = true
                        }
                        .fontWeight(.bold)
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    if !successMessage.isEmpty {
                        Text(successMessage)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    // NavigationLink ke SignUpView
                    NavigationLink(destination: SignUpView().navigationBarBackButtonHidden(true), isActive: $GoToSignUp) {
                        EmptyView()
                    }
                    
                    // NavigationLink ke ContentView setelah berhasil login
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true), isActive: $isLoggedIn) {
                        EmptyView()
                    }
                }
                .padding()
            }
        }
    }
    
    private func handleLogin() async {
        guard !email.isEmpty, !password.isEmpty else {
            await MainActor.run {
                errorMessage = "Email dan password harus diisi!"
            }
            return
        }
        
        // Start loading
        await MainActor.run {
            isLoading = true
            errorMessage = ""
            successMessage = ""
        }
        
        do {
            // Supabase query
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select()
                .eq("user_email", value: email)
                .eq("user_pass", value: password)
                .execute()
            
            let users = try JSONDecoder().decode([UserResponse].self, from: response.data)
            
            await MainActor.run {
                if !users.isEmpty {
                    successMessage = "Login berhasil!"
                    if let user = users.first {
                        loggedInUserId = user.user_id
                        isLoggedIn = true
                    }
                } else {
                    errorMessage = "Email atau password salah!"
                }
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Login gagal: \(error.localizedDescription)"
            }
        }
    }
}


// Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
