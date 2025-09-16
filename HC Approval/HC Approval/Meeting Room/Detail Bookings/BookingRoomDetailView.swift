//
//  BookingRoomDetailView.swift
//  HC Approval
//
//  Created by Livanty Efatania Dendy on 03/09/25.
//

import SwiftUI

struct BookingRoomDetailView: View {
    var brId: Int
    var onDismiss: (() -> Void)? = nil
    @State private var bookingDetail: BookingRoom?
    @State private var rooms: [Room] = []
    @State private var participants: [ParticipantBr] = []
    @State private var properties: [Property] = []
    
    @State private var showParticipant = false
    @State private var showProperty = false
    @State private var showAlert = false
    @State private var goToMyBooking = false 
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    if let booking = bookingDetail {

                        Section(header: Text("STATUS")) {
                            Text("\(booking.br_status)")
                                .foregroundColor(.secondary)

                            if booking.br_status == "Declined" {
                                Text("\(booking.br_decline_reason)")
                                    .foregroundColor(.secondary)
                            }
                        }

                        Section(header: Text("ROOM INFO")) {
                            let room = rooms.first { $0.room_id == booking.room_id }
                            Text(room?.room_name ?? "None")
                                .foregroundColor(.secondary)

                            if let capacity = room?.room_capacity {
                                Text("\(capacity)").foregroundColor(.secondary)
                            } else {
                                Text("None").foregroundColor(.secondary)
                            }
                        }

                        Section(header: Text("BOOKING DETAIL")) {
                            HStack {
                                Text("Date")
                                Spacer()
                                Text(booking.br_date.formattedDateReadable)
                                    
                            }.foregroundColor(.secondary)
                            HStack {
                                Text("Start")
                                Spacer()
                                Text(booking.br_start.formattedHourMinute)
                                    
                            }.foregroundColor(.secondary)
                            HStack {
                                Text("End")
                                Spacer()
                                Text(booking.br_end.formattedHourMinute)
                                    
                            }.foregroundColor(.secondary)
                        }

                        Section {
                            Text(booking.br_event)
                                .foregroundColor(.secondary)
                            Text(booking.br_desc)
                                .foregroundColor(.secondary)
                        }

                        Section {
                            HStack {
                                Text("Participant")
                                Spacer()
                                Button {
                                    showParticipant = true
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Section {
                            HStack {
                                Text("Properties")
                                Spacer()
                                Button {
                                    showProperty = true
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        if booking.br_status == "Approved" || booking.br_status == "Pending"{
                            Section {
                                Button {
                                    showAlert = true
                                } label: {
                                    Text("Cancel Booking")
//                                        .foregroundStyle(Color(.systemBackground))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                            }
                        }
                    } else {
                        Text("Loading details...")
                            .foregroundColor(.gray)
                    }
                }

                // 👇 Invisible NavigationLink
                NavigationLink(
                    destination: ContentView()
                        .navigationBarBackButtonHidden(true),
                    isActive: $goToMyBooking
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Booking Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { dismiss() }
                        .foregroundColor(Color(.systemBlue))
                }
            }
            .onAppear {
                Task {
                    await fetchBookingDetails(brId: brId)
                    await fetchRooms()
                }
            }
            .sheet(isPresented: $showParticipant) {
                ParticipantsView(brId: brId)
            }
            .sheet(isPresented: $showProperty) {
                PropertyView(brId: brId)
            }
            .alert("Do you want to cancel this booking?", isPresented: $showAlert) {
                Button("Yes", role: .destructive) {
                    Task {
                        if let id = bookingDetail?.br_id {
                            await cancelBooking(id: id)
//                            goToMyBooking = true
                            onDismiss?()
                            dismiss()
                        }
                    }
                }
                Button("No", role: .cancel) { }
            }
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
    
    func cancelBooking(id: Int) async {
        do {
            try await SupabaseManager.shared.client
                .from("bookings_room")
                .update(["br_status": "Cancelled"])
                .eq("br_id", value: id)
                .execute()
            
            print("Booking cancelled")
            await fetchBookingDetails(brId: id)
        } catch {
            print("Error cancelling booking: \(error)")
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
    
    
    func fetchParticipants(brId: Int) async {
        do {
            let response: [ParticipantBr] = try await SupabaseManager.shared.client
                .from("participants_br")
                .select("*, users:user_id(*)")
                .eq("br_id", value: brId)
                .execute()
                .value
            
            DispatchQueue.main.async {
                participants = response
            }
        } catch {
            print("Error fetching participants: \(error)")
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

import Foundation

extension String {
    var formattedHourMinute: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.dateFormat = "HH:mm:ss"
        if let date = formatter.date(from: self) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        }
        
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: self) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        }
        
        return self
    }
}

extension String {
    var formattedDateReadable: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: self) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "id_ID")
            displayFormatter.dateFormat = "dd MMMM yyyy"
            return displayFormatter.string(from: date)
        }
        
        return self
    }
}
