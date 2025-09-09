//
//  SignUpView.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 28/08/25.
//


import SwiftUI

struct SignUpView: View {
    @State private var user = User(
        user_id: 0,
        user_name: "",
        user_pass: "",
        user_dept: "",
        user_email: "",
        user_phone: "",
        user_active: true
    )
    
    @State private var confirm_pass = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    @State private var goToLogin = false
    
    // Menambahkan state untuk mengontrol apakah password terlihat
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Spacer()
                    
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 15) {
                        TextField("Name", text: $user.user_name)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(25)
                            .shadow(radius: 1)
                        
                        TextField("Department", text: $user.user_dept)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(25)
                            .shadow(radius: 1)
                        
                        TextField("Phone", text: $user.user_phone)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(25)
                            .shadow(radius: 1)
                        
                        TextField("Email", text: $user.user_email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(25)
                            .shadow(radius: 1)
                        
                        ZStack {
                            // Password Field (TextField/SecureField)
                            if isPasswordVisible {
                                TextField("Password", text: $user.user_pass)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding(15)
                                    
                                    .background(Color(.systemBackground))
                                    .cornerRadius(25)
                                    .shadow(radius: 1)
                            } else {
                                SecureField("Password", text: $user.user_pass)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding(15)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(25)
                                    .shadow(radius: 1)
                               
                            }
                           
                            HStack {
                                Spacer()
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(isConfirmPasswordVisible ? .blue : .gray)
                                        .padding(.trailing, 15)
                                }
                            }
                        }
                        
                        ZStack {
                           
                            if isConfirmPasswordVisible {
                                TextField("Repeat Password", text: $confirm_pass)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding(15)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(25)
                                    .shadow(radius: 1)
                            } else {
                                SecureField("Repeat Password", text: $confirm_pass)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding(15)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(25)
                                    .shadow(radius: 1)
                            }
                            
                           
                            HStack {
                                Spacer()
                                Button(action: {
                                    isConfirmPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(isConfirmPasswordVisible ? .blue : .gray)
                                        .padding(.trailing, 15)
                                }
                            }
                        }
                    }
                    
                    // Sign Up Button
                    Button(action: {
                        Task { await handleSignUp() }
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(30)
                        } else {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    .blue
                                )
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error / Success Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    if !successMessage.isEmpty {
                        Text(successMessage)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        Button("Login") {
                            goToLogin = true
                        }
                        .fontWeight(.bold)
                    }
                    Spacer()
                    
                    // NavigationLink tersembunyi ke LoginView
                    NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $goToLogin) {
                        EmptyView()
                    }
                }
                .padding()
            }
        }
    }
    
    private func handleSignUp() async {
        // Validasi field kosong
        guard !user.user_name.isEmpty,
              !user.user_email.isEmpty,
              !user.user_pass.isEmpty,
              !user.user_dept.isEmpty else {
            await MainActor.run { errorMessage = "Semua field harus diisi!" }
            return
        }
        
        // Validasi password match
        guard user.user_pass == confirm_pass else {
            await MainActor.run { errorMessage = "Password tidak sama!" }
            return
        }
        
        // Set loading
        await MainActor.run {
            isLoading = true
            errorMessage = ""
            successMessage = ""
        }
        
        do {
            // Panggil service untuk signup (pastikan UserService.signUp compatible SDK terbaru)
            let service = UserService()
            try await service.signUp(user: user)
            
            await MainActor.run {
                successMessage = "Sign up berhasil!"
                // Reset form
                user = User(user_id: 0, user_name: "", user_pass: "", user_dept: "", user_email: "", user_phone: "", user_active: true)
                confirm_pass = ""
            }
            
            // Delay sebentar supaya user lihat pesan sukses, lalu navigate ke LoginView
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 detik
            
            await MainActor.run {
                goToLogin = true
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Sign up gagal: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}


// Preview
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
