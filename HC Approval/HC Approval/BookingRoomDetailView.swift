//
//  BookingRoomDetailView.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 03/09/25.
//

import SwiftUI


struct BookingRoomDetailView: View {
    var brId: Int
    @State private var bookingDetail: BookingRoom?
    @State private var rooms: [Room] = []
    @State private var participants: [Participant] = []
    @State private var properties: [Property] = []
    
    var body: some View {
        NavigationView {
            Form {
                if let booking = bookingDetail {
                    Section(header: Text("ROOM INFO")){
                        Text("Room: \(rooms.first(where: { $0.room_id == booking.room_id })?.room_name ?? "None")")
                        Text("Status: \(booking.br_status)")
                    }
                    Section(header: Text("BOOKING DETAIL")){
                        Text("Date: \(booking.br_date)")
                        Text("Start: \(booking.br_start)")
                        Text("End: \(booking.br_end)")
                    }
                    Section {
                        Text("Event: \(booking.br_event)")
                        Text("Description: \(booking.br_desc)")
                        
                        
                    }
                    Section {
                        Text("No participants or properties defined")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Loading details...").foregroundColor(.gray)
                }
            }
            .onAppear {
                Task {
                    await fetchBookingDetails(brId: brId)
                    await fetchRooms()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Booking Details")
        }
    }
    
    func fetchBookingDetails(brId: Int) async {
        do {
            let response: [BookingRoom] = try await SupabaseManager.shared.client
                .from("bookings_room")
                .select()
                .eq("br_id", value: brId)
                .execute()
                .value
            
            if let booking = response.first {
                DispatchQueue.main.async {
                    bookingDetail = booking
                }
            }
        } catch {
            print("Error fetching booking detail: \(error)")
        }
    }
    
    func fetchRooms() async {
        do {
            let response: [Room] = try await SupabaseManager.shared.client
                .from("rooms")
                .select()
                .execute()
                .value
            
            DispatchQueue.main.async {
                rooms = response
            }
        } catch {
            print("Error fetching rooms: \(error)")
        }
    }
}

struct BookingRoomDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookingRoomDetailView(brId: 1)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
