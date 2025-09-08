//
//  ApprovalsView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 26/08/25.
//

import SwiftUI

struct ApprovalsView: View {
    @State var bookingRoom: [BookingRoomJoined] = []
    @State var bookingCar: [BookingCarJoined] = []
    

    @State private var selectedStatus: BookingStatus = .pending
    @State private var selectedType: BookingType = .all
    
    // MARK: - Filtered Data by type & status
    var filteredRooms: [BookingRoomJoined] {
        bookingRoom
            .filter { room in
                selectedType == .all || selectedType == .rooms
            }
            .filter { room in
                // filter status
                switch selectedStatus {
                case .pending:   return room.br_status == "Pending"
                case .approved:  return room.br_status == "Approved"
                case .declined:  return room.br_status == "Declined"
                case .cancelled: return room.br_status == "Cancelled"
                }
            }
    }
    
    var filteredCars: [BookingCarJoined] {
        bookingCar
            .filter { car in
                selectedType == .all || selectedType == .cars
            }
            .filter { car in
                switch selectedStatus {
                case .pending:   return car.bc_status == "Pending"
                case .approved:  return car.bc_status == "Approved"
                case .declined:  return car.bc_status == "Declined"
                case .cancelled: return car.bc_status == "Cancelled"
                }
            }
    }
    
    // MARK: - Sort room and car merged data by createdAt
    var mergedBookings: [any AnyBooking] {
        let rooms: [any AnyBooking] = filteredRooms
        let cars: [any AnyBooking] = filteredCars
        return (rooms + cars).sorted { $0.createdAt < $1.createdAt }
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Booking Request")
                        .font(.title.bold())
                    
                    Spacer()
                    
                    Button(action: {
                        print("Profile tapped")
                    }) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(Color(.systemBlue))
                    }
                                    .padding(.bottom, 3)
                }
                .padding(.top)
                
                HStack {
                    Spacer()
                    Picker("ChooseType", selection: $selectedType) {
                        ForEach(BookingType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                .padding(.bottom, 3)
                
                Picker("StatusRequest", selection: $selectedStatus) {
                    ForEach(BookingStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 3)
                
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack (spacing: 15) {
                    ForEach(mergedBookings, id: \.bookId) { booking in
                        bookingView(
                            title: booking.title,
                            event: booking.type == .rooms
                            ? (booking as! BookingRoomJoined).br_event
                            : "📍\((booking as! BookingCarJoined).destination?.last?.destination_name ?? "Unknown")",
                            date: booking is BookingRoomJoined
                            ? (booking as! BookingRoomJoined).br_date
                            : (booking as! BookingCarJoined).bc_date,
                            startTime: booking is BookingRoomJoined
                            ? toHourMinute((booking as! BookingRoomJoined).br_start)
                            : toHourMinute((booking as! BookingCarJoined).bc_start),
                            endTime: booking is BookingRoomJoined
                            ? toHourMinute((booking as! BookingRoomJoined).br_end)
                            : toHourMinute((booking as! BookingCarJoined).bc_end),
                            status: booking.status,
                            bookings: booking
                        )
                    }
                }
                .padding()
                .task {
                    await fetchAllBookings()
                }
            }
        }
        .background(Color(.systemGray6))
    }
    
    func fetchAllBookings() async {
        do {
            let responseRooms = try await SupabaseManager.shared.client
                .from("bookings_room")
                .select("""
                        *, room:rooms(*), user: users(*)
                        """)
                .execute()
            
            let rooms: [BookingRoomJoined] = try JSONDecoder.bookingDecoder.decode(
                [BookingRoomJoined].self,
                from: responseRooms.data
            )
            
            let responseCars = try await SupabaseManager.shared.client
                .from("bookings_car")
                .select("""
                        *, destination:destinations(*), driver:drivers(*), user: users(*)
                        """)
                .execute()
            
            let cars: [BookingCarJoined] = try JSONDecoder.bookingDecoder.decode(
                [BookingCarJoined].self,
                from: responseCars.data
            )
            
            DispatchQueue.main.async {
                self.bookingRoom = rooms
                self.bookingCar = cars
            }
            print("respones: ", rooms, cars)
        } catch {
            print("Error fetch bookings:", error)
        }
    }
    func bookingView(title: String, event: String, date: Date, startTime: String, endTime: String, status: String, bookings: any AnyBooking) -> some View {
        if status == "Pending" {
            return AnyView(
                PendingView(
                    title: title,
                    event: event,
                    date: date,
                    startTime: startTime,
                    endTime: endTime,
                    onApprove: {
                        Task {
                            try? await SupabaseManager.shared.updateBookingStatus(booking: bookings, status: "Approved")
                            await fetchAllBookings()
                        }
                    },
                    onDecline: {
                        Task {
                            try? await SupabaseManager.shared.updateBookingStatus(booking: bookings, status: "Declined")
                            await fetchAllBookings()
                        }
                    }
                )
            )
        } else {
            return AnyView(
                StatusView(
                    title: title,
                    event: event,
                    date: date,
                    startTime: startTime,
                    endTime: endTime
                )
            )
        }
        
//        .padding(14)
//        //    .frame(width: 365)
//        .background(Color(.systemBackground))
//        .cornerRadius(10)
//        //    .shadow(radius: 5, x: 3, y: 3)
//        .padding(.horizontal, 20)
    }
}

func toHourMinute(_ timeString: String) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "HH:mm:ss"
    
    if let date = formatter.date(from: timeString) {
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "HH:mm"
        return outFormatter.string(from: date)
    }
    return timeString
}

extension SupabaseManager {
    func updateBookingStatus(booking: any AnyBooking, status: String) async throws {
        if let roomBooking = booking as? BookingRoomJoined {
            try await client
                .from("bookings_room")
                .update(["br_status": status])
                .eq("br_id", value: roomBooking.br_id)
                .execute()
            print(status)
            
        } else if let carBooking = booking as? BookingCarJoined {
            try await client
                .from("bookings_car")
                .update(["bc_status": status])
                .eq("bc_id", value: carBooking.bc_id)
                .execute()
            
            print(status)
        }
    }
}


#Preview {
    ApprovalsView()
}
