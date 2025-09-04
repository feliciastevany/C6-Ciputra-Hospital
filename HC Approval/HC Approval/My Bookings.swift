//
//  My Bookings.swift
//  HC Approval
//
//  Created by Graciella Michelle Siswoyo on 28/08/25.
//
import SwiftUI

struct MyBookings : View {
    @AppStorage("loggedInUserId") var loggedInUserId: Int = 0
    @State private var goToProfil = false
    
    @State var bookingRoom: [BookingRoomJoined] = []
    @State var bookingCar: [BookingCarJoined] = []
    
    @State var segmentedControl = 0
    
    var groupedRooms: [Date: [BookingRoomJoined]] {
        Dictionary(grouping: bookingRoom, by: { $0.br_date })
    }

    var groupedCars: [Date: [BookingCarJoined]] {
        Dictionary(grouping: bookingCar, by: { $0.bc_date })
    }

    
    var body: some View {
        VStack {
            HStack {
                Text("My Bookings")
                    .font(.title.bold())
                    .accessibilityLabel("My list of bookings today")
                
                Spacer()
                
                Button(action: {
                    print("Profile tapped")
                    goToProfil = true
                }) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color(.systemBlue))
                        .accessibilityLabel("My Profile")
                }.navigationDestination(isPresented: $goToProfil) {
                    ProfilView(userId: loggedInUserId)
                }
            }
            .padding(.top)
            
            Picker("", selection: $segmentedControl){
                Text("Rooms").tag(0)
                    .accessibilityHint("Segmented control Rooms")
                Text("Cars").tag(1)
                    .accessibilityHint("Segmented control Cars")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 15)
            
            ScrollView {
                VStack (spacing: 15) {
                    if segmentedControl == 0 {
                        ForEach(groupedRooms.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(date.toEnglishFormat())")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                ForEach(groupedRooms[date] ?? [], id: \.bookId) { booking in
                                    BookingCard(
                                        title: booking.title,
                                        date: booking.br_date,
                                        event: booking.br_event,
                                        startTime: toHourMinute(booking.br_start),
                                        endTime: toHourMinute(booking.br_end),
                                        status: booking.br_status
                                    )
                                }
                            }
                        }
                    }
                    if segmentedControl == 1 {
                        ForEach(groupedCars.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(date.toEnglishFormat())")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                ForEach(groupedCars[date] ?? [], id: \.bookId) { booking in
                                    if booking.carpool_status == "Pending" {
                                        CarpoolCard(title: booking.title,
                                                    date: booking.bc_date,
                                                    event: booking.destination?.last?.destination_name ?? "Unknown",
                                                    startTime: toHourMinute(booking.bc_start),
                                                    endTime: toHourMinute(booking.bc_end),
                                                    status: booking.bc_status,
                                                    carpool_req_name: "hehe",
                                                    carpool_desc: "nebeng",
                                                    onApprove: {
                                            Task {
                                                try? await SupabaseManager.shared.updateCarpoolStatus(booking: booking, status: "Approved")
                                                await fetchMyBookings()
                                            }
                                        },
                                                    onDecline: {
                                            Task {
                                                try? await SupabaseManager.shared.updateCarpoolStatus(booking: booking, status: "Declined")
                                                await fetchMyBookings()
                                            }
                                        },
                                                    pressed: false)
                                    } else {
                                        BookingCard(title: booking.title,
                                                    date: booking.bc_date,
                                                    event: booking.destination?.last?.destination_name ?? "Unknown",
                                                    startTime: toHourMinute(booking.bc_start),
                                                    endTime: toHourMinute(booking.bc_end),
                                                    status: booking.bc_status)
                                    }
                                }
                            }
                        }
                    }
                }
                .task {
                    await fetchMyBookings()
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
    }
    func fetchMyBookings() async {
        do {
            let (rooms, cars) = try await SupabaseManager.shared.fetchBookings(for: loggedInUserId)
            DispatchQueue.main.async {
                self.bookingRoom = rooms
                self.bookingCar = cars
            }
            print("respones: ", rooms, cars)
        } catch {
            print("Error fetch my bookings:", error)
        }
    }
}

extension SupabaseManager {
    func updateCarpoolStatus(booking: any AnyBooking, status: String) async throws {
        if let roomBooking = booking as? BookingRoomJoined {
            try await client
                .from("bookings_room")
                .update(["carpool_status": status])
                .eq("br_id", value: roomBooking.br_id)
                .execute()
            print(status)
            
        } else if let carBooking = booking as? BookingCarJoined {
            try await client
                .from("bookings_car")
                .update(["carpool_status": status])
                .eq("bc_id", value: carBooking.bc_id)
                .execute()
            
            print(status)
        }
    }
}

#Preview {
    MyBookings()
}
