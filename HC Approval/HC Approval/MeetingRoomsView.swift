//
//  MeetingRoomsView.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 01/09/25.
//

import SwiftUI

struct MeetingRoomsView: View {
    @State private var date = Date()
    @State private var capacity: Int = 1
    @State private var goToAvailable = false
    
    @State private var brName: String = ""
    @State private var brDate: Date = Date()
    @State private var brRoom: Int?
    @State private var brStart: String = "07:30"
    @State private var brEnd: String = "08:00"
    @State private var brDesc: String = ""
    @State private var brStatus: String = "Pending"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker("Date", selection: $date, in: Date()..., displayedComponents: .date)
                
                HStack {
                    Text("Capacity")
                    Spacer()
                    Text("\(capacity)")
                        .frame(width: 30, alignment: .center)
                    Stepper("", value: $capacity, in: 1...500)
                        .labelsHidden()
                }
                
                NavigationLink(
                    destination: AvailableRoomsView(date: formatDate(date),capacity: Int(capacity) ?? 1),
                    isActive: $goToAvailable) {
                        EmptyView()
                    }
                
                    Button("Browse Rooms") {
                        goToAvailable = true
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(3)
                    .background(Color.blue)
                    .cornerRadius(8)
                
//                Text("Schedule")
//                    .font(.headline)
//                    .padding(.horizontal)
//                    
//                List(rooms) { room in
//                    HStack {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(room.name)
//                                .font(.body)
//                                .bold()
//                            Text("Capacity: \(room.capacity)")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.vertical, 4)
//                }
//                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationTitle("Meeting Rooms")
        }
    }
}

struct AvailableRoomsView: View {
    @State private var showSheet = true
    @StateObject private var vm = BookingSearchViewModel()
    var date: String
    var capacity: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text(DateHelper.formatDate(date))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(vm.availableRooms) { roomAvail in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(roomAvail.room.room_name)
                                .font(.headline)
                            Spacer()
                            Text("Capacity: \(roomAvail.room.room_capacity)")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        
                        let availableSlots = BookingTimeHelper.availableStartTimes(bookings: roomAvail.bookings)
                        
                        if availableSlots.isEmpty {
                            Text("Tidak ada slot tersedia")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            // Horizontal scroll of slots
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(availableSlots, id: \.self) { start in
                                        NavigationLink(
                                            destination: RoomDetailView(
                                                room: roomAvail.room,
                                                slot: TimeSlot(start: start, end: ""),
                                                date: date,
                                                bookings: roomAvail.bookings
                                            )
                                        ) {
                                            Text(start)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
            }
            .padding()
        }
        .navigationTitle("Available Rooms")
        .task {
            await vm.search(date: date, capacity: capacity)
        }
        .alert(item: Binding(
            get: { vm.errorMessage.map { ErrorWrapper(message: $0) } },
            set: { _ in vm.errorMessage = nil }
        )) { wrapper in
            Alert(title: Text("Info"), message: Text(wrapper.message), dismissButton: .default(Text("OK")))
        }
    }
}

struct RoomDetailView: View {
    var room: Room
    var slot: TimeSlot
    var date: String
    var bookings: [BookingRoom]
    
    @State private var startTime: String = ""
    @State private var endTime: String = ""
    @State private var goToSchedule = false
    @State private var eventName: String = ""
    @State private var eventDesc: String = ""
    
    @State private var showUserPicker = false
    @State private var selectedUsers: [User] = []
    
    @State private var selectedProperties: [SelectedProperty] = []
    @State private var showPropertyPicker = false
    
    private var availableTimeOptions: [String] {
        BookingTimeHelper.availableStartTimes(bookings: bookings)
    }
    
    private var validEndOptions: [String] {
        BookingTimeHelper.validEndTimes(startTime: startTime, bookings: bookings)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Room Info")) {
                Text(room.room_name)
                Text("Capacity: \(room.room_capacity)")
            }
            
            Section(header: Text("Booking")) {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(DateHelper.formatDate(date))
                }.frame(maxWidth: .infinity)
                
                Picker("Start Time", selection: $startTime) {
                    ForEach(availableTimeOptions, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }
                
                Picker("End Time", selection: $endTime) {
                    ForEach(validEndOptions, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }.disabled(startTime.isEmpty)
                
                Button("Confirm Booking") {
                    validateBooking()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Section {
                TextField("Event", text: $eventName)
                TextField("Description", text: $eventDesc)
            }
            
            Section {
                HStack {
                    Text("Participant")
                    Spacer()
                    Button {
                        showUserPicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                HStack() {
                    let maxVisible = 5
                    ForEach(selectedUsers.prefix(maxVisible)) { user in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(user.user_name.initials)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            )
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 2)
                            )
                    }

                    if selectedUsers.count > maxVisible {
                        let extra = selectedUsers.count - maxVisible
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("+\(extra)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            )
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 2)
                            )
                    } else if selectedUsers.isEmpty {
                        Text("No participants selected")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Properties")
                    Spacer()
                    Button {
                        showPropertyPicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                                
                if selectedProperties.isEmpty {
                    Text("No properties selected")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(selectedProperties) { sp in
                        HStack {
                            Text(sp.property.properties_name)
                            Spacer()
                            Text("x\(sp.quantity)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Booking Details")
        .onAppear {
            if startTime.isEmpty {
                startTime = slot.start // dari slot yg dipilih
            }
            if endTime.isEmpty, let last = validEndOptions.last {
                endTime = last
            }
        }
        .sheet(isPresented: $showUserPicker) {
            UserPickerView(selectedUsers: $selectedUsers)
        }
        .sheet(isPresented: $showPropertyPicker) {
            PropertyPickerView(selectedProperties: $selectedProperties)
        }
    }
    
    private func validateBooking() {
        guard !startTime.isEmpty, !endTime.isEmpty else { return }
        guard !eventName.isEmpty else {
            print("Event name required")
            return
        }

//        if startTime < endTime {
//            Task {
//                do {
//                    let booking = try await BookingService.createBooking(
//                        room: room,
//                        date: date, // pastikan sudah yyyy-MM-dd
//                        startTime: startTime,
//                        endTime: endTime,
//                        eventName: eventName,
//                        eventDesc: eventDesc,
//                        userId: 1, // TODO: ganti dengan user login aktif
//                        participants: selectedUsers,
//                        properties: selectedProperties
//                    )
//                    print("Booking berhasil: \(booking)")
//                } catch {
//                    print("Gagal insert booking: \(error)")
//                }
//            }
//        } else {
//            print("End time harus lebih besar dari start time")
//            goToSchedule = true
//        }
    }
}

struct RoomScheduleView: View {
    var room: Room
    var date: String
    var bookings: [BookingRoom]
    
    var body: some View {
        List {
            ForEach(bookings) { booking in
                VStack(alignment: .leading) {
                    Text(booking.br_event)
                        .font(.headline)
                    Text("\(booking.br_start) - \(booking.br_end)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("\(room.room_name) Schedule")
    }
}

func generateHalfHourTimes(start: String, end: String) -> [String] {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    guard let startDate = formatter.date(from: start),
          let endDate = formatter.date(from: end) else {
        return []
    }
    
    var times: [String] = []
    var current = startDate
    while current <= endDate {
        times.append(formatter.string(from: current))
        current = current.addingTimeInterval(30 * 60) // 30 menit
    }
    return times
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

#Preview {
    MeetingRoomsView()
}
