//
//  ParticipantsView.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 08/09/25.
//
import SwiftUI

struct ParticipantsView: View {
    var brId: Int
    @Environment(\.dismiss) var dismiss
    @State private var participants: [Participant] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading participants...")
                        .padding()
                } else if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if participants.isEmpty {
                    Text("No participants found")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(participants) { participant in
                        HStack {
                            let initial = participant.user_name?.first.map { String($0).uppercased() } ?? "?"
                            
                            Text(initial)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .frame(width: 40, height: 40)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                            
                            Text(participant.user_name ?? "Unknown User")
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Participants")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await fetchParticipants() // Menjalankan fetch data peserta
        }
    }

    func fetchParticipants() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [ParticipantResponse] = try await SupabaseManager.shared.client
                .from("participants_br")
                .select("user_id, br_id, pic, users:user_id(user_name)")
                .eq("br_id", value: brId)
                .execute()
                .value
            
            let mappedParticipants = response.map { p in
                Participant(
                    user_id: p.user_id,
                    br_id: p.br_id,
                    pic: p.pic,
                    user_name: p.users?.user_name
                )
            }
            
            DispatchQueue.main.async {
                self.participants = mappedParticipants
                self.isLoading = false
            }
            
            print("Fetched participants count: \(response.count)")
            print("Data: \(response)")
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch participants: \(error.localizedDescription)"
                self.isLoading = false
            }
            print("Error fetch participants: \(error.localizedDescription)")
            dump(error)
        }
    }
}
