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
    
    @State var searchText: String = ""
    
    @State private var selectedSheet: SheetType?
    
    @State var bookingRoom: [BookingRoomJoined] = []
    @State var bookingCar: [BookingCarJoined] = []
    
    @State var segmentedControl = 0
    
    var filteredRooms: [BookingRoomJoined] {
        let today = Calendar.current.startOfDay(for: Date())
        let baseFilter = bookingRoom.filter { $0.br_date >= today }
        
        let filtered = searchText.isEmpty
            ? baseFilter
            : baseFilter.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.br_event.localizedCaseInsensitiveContains(searchText) ||
                $0.br_status.localizedCaseInsensitiveContains(searchText) ||
                $0.br_date.toEnglishFormat().localizedCaseInsensitiveContains(searchText)
            }
        
        return filtered.sorted { $0.br_date < $1.br_date }
    }

    var filteredCars: [BookingCarJoined] {
        let today = Calendar.current.startOfDay(for: Date())
        let baseFilter = bookingCar.filter { $0.bc_date >= today }
        
        let filtered = searchText.isEmpty
            ? baseFilter
            : baseFilter.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.destination?.last?.destination_name.localizedCaseInsensitiveContains(searchText) ?? false) ||
                $0.bc_status.localizedCaseInsensitiveContains(searchText) ||
                $0.bc_date.toEnglishFormat().localizedCaseInsensitiveContains(searchText)
            }
        
        return filtered.sorted { $0.bc_date < $1.bc_date }
    }
    
    var groupedRooms: [(date: Date, bookings: [BookingRoomJoined])] {
        Dictionary(grouping: filteredRooms, by: { $0.br_date })
            .sorted { $0.key < $1.key }   // urut ascending
            .map { ($0.key, $0.value) }
    }

    var groupedCars: [(date: Date, bookings: [BookingCarJoined])] {
        Dictionary(grouping: filteredCars, by: { $0.bc_date })
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value) }
    }
    
    var body: some View {
        ZStack {
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
                            .frame(width: 32, height: 32)
                            .foregroundColor(Color(.systemBlue))
                            .accessibilityLabel("My Profile")
                    }.navigationDestination(isPresented: $goToProfil) {
                        ProfilView(userId: loggedInUserId)
                    }
                }
                .padding(.top)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(.systemGray2))
                        .accessibilityHidden(true)
                    
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
                
                Picker("Booking type", selection: $segmentedControl) {
                    Text("Rooms").tag(0)
                    Text("Cars").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .accessibilityLabel("Booking type")
                .accessibilityHint("Switch between rooms and cars")
                
                ScrollView {
                    VStack (spacing: 15) {
                        if segmentedControl == 0 {
                            ForEach(groupedRooms, id: \.date) { group in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("\(group.date.toEnglishFormat())")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .accessibilityLabel("")
                                        .accessibilityHint("Bookings on \(group.date.toEnglishFormat())")
                                    
                                    
                                    ForEach(group.bookings, id: \.bookId) { booking in
                                        BookingCard(
                                            title: booking.title,
                                            joinName: "",
                                            date: booking.br_date,
                                            event: booking.br_event,
                                            startTime: toHourMinute(booking.br_start),
                                            endTime: toHourMinute(booking.br_end),
                                            status: booking.br_status
                                        ).onTapGesture {
                                            selectedSheet = .roombooking(booking)
                                        }
                                    }
                                }
                            }
                        }
                        if segmentedControl == 1 {
                            ForEach(filteredCars.filter { $0.carpool_status == "Pending" }, id: \.bookId) { booking in
                                CarpoolCard(title: booking.title,
                                            date: booking.bc_date,
                                            event: booking.destination?.last?.destination_name ?? "Unknown",
                                            startTime: toHourMinute(booking.bc_start),
                                            endTime: toHourMinute(booking.bc_end),
                                            status: booking.bc_status,
                                            carpool_req_name: booking.carpool_user?.user_name ?? "Unknown",
                                            carpool_desc: booking.carpool_desc,
                                            onApprove: {
                                    Task {
                                        try? await SupabaseManager.shared.approveCarpool(booking: booking)
                                        await fetchMyBookings()
                                    }
                                },
                                            onDecline: {
                                    Task {
                                        try? await SupabaseManager.shared.declineCarpool(booking: booking)
                                        await fetchMyBookings()
                                    }
                                },
                                            onDetails: {
                                    selectedSheet = .carpool(booking)
                                }
                                ).onTapGesture {
                                    selectedSheet = .carbooking(booking)
                                }
                            }
                            
                            let nonPendingGroupedCars = Dictionary(
                                grouping: filteredCars.filter { $0.carpool_status != "Pending" },
                                by: { $0.bc_date }
                            )
                            
                            ForEach(nonPendingGroupedCars.keys.sorted(by: { $1 > $0 }), id: \.self) { date in
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("\(date.toEnglishFormat())")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    ForEach(nonPendingGroupedCars[date] ?? [], id: \.bookId) { booking in
                                        BookingCard(title: booking.title,
                                                    joinName: joinLabel(for: booking, currentUserId: loggedInUserId) ?? "",
                                                    date: booking.bc_date,
                                                    event: booking.destination?.last?.destination_name ?? "Unknown",
                                                    startTime: toHourMinute(booking.bc_start),
                                                    endTime: toHourMinute(booking.bc_end),
                                                    status: booking.bc_status
                                        ).onTapGesture {
                                            selectedSheet = .carbooking(booking)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    .task {
                        await fetchMyBookings()
                    }
                }
                .refreshable {
                    await fetchMyBookings()
                }
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .sheet(item: $selectedSheet) { sheet in
                switch sheet {
                case .carbooking(let car):
                    BookingCarDetailView(bcId: car.bc_id)
                case .carpool(let car):
                    CarpoolDetailView(booking: car)
                case .roombooking(let room):
                    BookingRoomDetailView(brId: room.br_id)
                }
            }
        }
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
        
    func joinLabel(for booking: BookingCarJoined, currentUserId: Int) -> String? {
        guard booking.carpool_status == "Approved",
              let participants = booking.participant else {
            return nil
        }
        
        if let me = participants.first(where: { $0.user_id == currentUserId }) {
            if me.pic {
                // saya PIC → tampilkan siapa yang join
                if let joiner = participants.first(where: { !$0.pic }) {
                    return "Joined by \(firstName(from:joiner.user?.user_name))"
                }
            } else {
                // saya bukan PIC → cari siapa PIC nya
                if let pic = participants.first(where: { $0.pic }) {
                    return "Joined with \(firstName(from:pic.user?.user_name))"
                }
            }
        }
        return nil
        
        func firstName(from fullName: String?) -> String {
            guard let fullName, !fullName.isEmpty else { return "Unknown" }
            return fullName.split(separator: " ").first.map(String.init) ?? fullName
        }
    }
}

extension SupabaseManager {
    func approveCarpool(booking: any AnyBooking) async throws {
        // Change status
        if let carBooking = booking as? BookingCarJoined {
            try await client
                .from("bookings_car")
                .update(["carpool_status": "Approved"])
                .eq("bc_id", value: carBooking.bc_id)
                .execute()
            
            print("Carpool request Approved")
            
            // Insert participant
            try await client
                .from("participants_bc")
                .insert([
                    "bc_id": carBooking.bc_id,
                    "user_id": carBooking.carpool_req_id,
                    "pic": 0
                ])
                .execute()
            
            print("Carpool approved and participant inserted")
        }
    }
    
    func declineCarpool(booking: BookingCarJoined) async throws {
        // Change status
        try await client
            .from("bookings_car")
            .update(["carpool_status": "Declined"])
            .eq("bc_id", value: booking.bc_id)
            .execute()
        
        print("Carpool request Declined")
    }
}


#Preview {
    MyBookings()
}
