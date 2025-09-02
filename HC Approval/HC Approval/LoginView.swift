import SwiftUI
import Supabase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding().background(Color.white).cornerRadius(25).shadow(radius: 1)
                
                SecureField("Password", text: $password)
                    .padding().background(Color.white).cornerRadius(25).shadow(radius: 1)
            }
            .padding(.horizontal)
            
            Button(action: {
                Task { await handleLogin() }
            }) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(30)
                } else {
                    Text("Login")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Login function
    private func handleLogin() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email dan password harus diisi!"
            return
        }
        
        isLoading = true
        errorMessage = ""
        successMessage = ""
        
        do {
            // Query Supabase untuk user dengan email & password
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select()
                .eq("user_email", email)
                .eq("user_pass", password)
                .execute()
            
            if let users = response.data as? [[String: Any]], !users.isEmpty {
                successMessage = "Login berhasil!"
                print("Login berhasil: \(users)")
                // Bisa navigasi ke halaman utama
            } else {
                errorMessage = "Email atau password salah!"
            }
        } catch {
            errorMessage = "Login gagal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
