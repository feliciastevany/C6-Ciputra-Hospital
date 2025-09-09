//
//  ApprovalsView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 26/08/25.
//

import SwiftUI

struct ApprovalsView: View {
    @AppStorage("loggedInUserId") var loggedInUserId: Int = 0
    @State private var goToProfil = false
    
    @State private var showDeclineSheet = false
    @State private var declineReason = ""
    @State private var selectedBooking: (any AnyBooking)?
    
    @State var bookingRoom: [BookingRoomJoined] = []
    @State var bookingCar: [BookingCarJoined] = []
    
    @State private var searchText = ""
    
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
    
    var searchedBookings: [any AnyBooking] {
        if searchText.isEmpty {
            return mergedBookings
        } else {
            return mergedBookings.filter { booking in
                let title = booking.title.lowercased()
                let event = (booking is BookingRoomJoined)
                ? (booking as! BookingRoomJoined).br_event.lowercased()
                : (booking as! BookingCarJoined).destination?.last?.destination_name.lowercased() ?? ""
                let date = (booking is BookingRoomJoined) ? (booking as! BookingRoomJoined).br_date.toEnglishFormat().lowercased() : (booking as! BookingCarJoined).bc_date.toEnglishFormat().lowercased()
                
                return title.contains(searchText.lowercased()) ||
                event.contains(searchText.lowercased()) ||
                date.contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    HStack {
                        Text("Booking Request")
                            .font(.title.bold())
                            .accessibilityLabel("My Booking Requests")
                        
                        Spacer()
                        
                        Button(action: {
                            print("Profile tapped")
                            goToProfil = true
                        }) {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(Color(.systemBlue))
                                .accessibilityLabel("My Profile")
                            
                        }.navigationDestination(isPresented: $goToProfil) {
                            ProfilView(userId: loggedInUserId)
                        }
                    }
                    .padding(.top)
                    
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(.systemGray2))
                            
                            TextField("Search bookings...", text: $searchText)
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(.systemGray2))
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray3), lineWidth: 1)
                                )
                        )
                        
                        Picker("ChooseType", selection: $selectedType) {
                            ForEach(BookingType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                                
                            }
                        }
                    }
                    
                    Picker("StatusRequest", selection: $selectedStatus) {
                        ForEach(BookingStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack (spacing: 15) {
                        ForEach(searchedBookings, id: \.bookId) { booking in
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
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .task {
                        await fetchAllBookings()
                    }
                }
            }
            .background(Color(.systemGray6))
            
            if showDeclineSheet {
                Color.black.opacity(0.3).ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("Decline Reason")
                        .font(.title3.bold())
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $declineReason)
                            .frame(height: 110)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray), lineWidth: 1)
                            )
                        
                        if declineReason.isEmpty {
                            Text("Enter reason...")
                                .foregroundColor(Color(.systemGray3))
                                .padding(.top, 14)
                                .padding(.leading, 15)
                        }
                    }
                    
                    HStack {
                        Button("Cancel") { showDeclineSheet = false }
                        Spacer()
                        Button("Submit") {
                            print("Reason: \(declineReason)")
                            Task {
                                if let booking = selectedBooking {
                                    try? await SupabaseManager.shared.updateBookingStatus(
                                        booking: booking,
                                        status: "Declined",
                                        dec_reason: declineReason
                                    )
                                    await fetchAllBookings()
                                }
                                showDeclineSheet = false
                                declineReason = ""
                            }
                            
                        }
                        .disabled(declineReason.isEmpty)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 8)
                .padding(40)
            }
        }
    }

//    func fetchAllBookings() async {
//        do {
//            let responseRooms = try await SupabaseManager.shared.client
//                .from("bookings_room")
//                .select("""
//                        *, room:rooms(*), user: users(*)
//                        """)
//                .execute()
//            
//            let rooms: [BookingRoomJoined] = try JSONDecoder.bookingDecoder.decode(
//                [BookingRoomJoined].self,
//                from: responseRooms.data
//            )
//            
//            let responseCars = try await SupabaseManager.shared.client
//                .from("bookings_car")
//                .select("""
//                        *, destination:destinations(*), driver:drivers(*), user: users(*)
//                        """)
//                .execute()
//            
//            let cars: [BookingCarJoined] = try JSONDecoder.bookingDecoder.decode(
//                [BookingCarJoined].self,
//                from: responseCars.data
//            )
//            
//            DispatchQueue.main.async {
//                self.bookingRoom = rooms
//                self.bookingCar = cars
//            }
//            print("respones: ", rooms, cars)
//        } catch {
//            print("Error fetch bookings:", error)
//        }
//    }
    func fetchAllBookings() async {
        do {
            let (rooms, cars) = try await SupabaseManager.shared.fetchBookings()
            DispatchQueue.main.async {
                self.bookingRoom = rooms
                self.bookingCar = cars
            }
            print("respones: ", rooms, cars)
        } catch {
            print("Error fetch my bookings:", error)
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
                            try? await SupabaseManager.shared.updateBookingStatus(booking: bookings, status: "Approved", dec_reason: "-")
                            await fetchAllBookings()
                        }
                    },
                    onDecline: {
                        selectedBooking = bookings
                        showDeclineSheet = true
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
    func updateBookingStatus(booking: any AnyBooking, status: String, dec_reason: String) async throws {
        if let roomBooking = booking as? BookingRoomJoined {
            try await client
                .from("bookings_room")
                .update(["br_status": status, "br_decline_reason": dec_reason])
                .eq("br_id", value: roomBooking.br_id)
                .execute()
            print(status, dec_reason)
            
        } else if let carBooking = booking as? BookingCarJoined {
            try await client
                .from("bookings_car")
                .update(["bc_status": status, "bc_decline_reason": dec_reason])
                .eq("bc_id", value: carBooking.bc_id)
                .execute()
            
            print(status, dec_reason)
        }
    }
}


#Preview {
    ApprovalsView()
}
