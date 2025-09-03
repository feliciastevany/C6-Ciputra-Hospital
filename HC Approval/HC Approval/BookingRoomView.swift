//
//  BookingRoomView.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import SwiftUI

//struct BookingRoomView: View {
//    
//    @State private var showSheet = true
//    
//    var body: some View {
//        Button("Add new bookings") {
//            showSheet = true
//        }
//        .sheet(isPresented: $showSheet) {
//            BookingRoomModalView()
//        }
//    }
//}
//
struct BookingRoomModalView: View {
    @State private var brName: String = ""
    @State private var brDate: Date = Date()
    @State private var brRoom: Int?
    @State private var brStart: String = "07:30"
    @State private var brEnd: String = "08:00"
    @State private var brDesc: String = ""
    @State private var brStatus: String = "Pending"
   
    @State private var rooms: [Room] = []
//    private lazy var times = generateTimes()
    
    @State private var showUserPicker = false
    @State private var selectedUsers: [User] = []
    
    @State private var selectedProperties: [SelectedProperty] = []
    @State private var showPropertyPicker = false
    
    @State private var existingBookings: [BookingRoom] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Date", selection: $brDate, in: Date()..., displayedComponents: .date)
                    
                    Picker("Room", selection: $brRoom) {
                        Text("None").tag(nil as Int?)
                        ForEach(rooms) { room in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .tint(colorForRoom(id: room.room_id))
                                Text(room.room_name)
                            }
                            .tag(room.room_id as Int?)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Start", selection: $brStart) {
                        if let roomId = brRoom {
                            ForEach(availableSlots(for: roomId, date: brDate), id: \.self) { time in
                                Text(time).tag(time)
                            }
                        }
                    }

                    Picker("End", selection: $brEnd) {
                        if let roomId = brRoom, !brStart.isEmpty {
                            let slots = availableSlots(for: roomId, date: brDate)
                            ForEach(slots.filter { $0 > brStart }, id: \.self) { time in
                                Text(time).tag(time)
                            }
                        }
                    }
                    .disabled(brStart.isEmpty) // end baru bisa dipilih setelah start
                }
                
                Section {
                    TextField("Event", text: $brName)
                    TextField("Description", text: $brDesc)
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {}
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {}
                }
            }
            .task {
                await fetchRooms()
            }
            .onChange(of: brRoom) { newValue, _ in
                if let roomId = newValue {
                    Task { await fetchBookingsForRoom(roomId, date: brDate) }
                }
            }
            .onChange(of: brDate) { newValue, _ in
                if let roomId = brRoom {
                    Task { await fetchBookingsForRoom(roomId, date: newValue) }
                }
            }
            .sheet(isPresented: $showUserPicker) {
                UserPickerView(selectedUsers: $selectedUsers)
            }
            .sheet(isPresented: $showPropertyPicker) {
                PropertyPickerView(selectedProperties: $selectedProperties)
            }
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
            print("Error fetch rooms: ", error)
        }
    }

//    func fetchBookingsForRoom() async {
//        do {
////            let formatter = DateFormatter()
////            formatter.dateFormat = "yyyy-MM-dd"
////            let dateString = formatter.string(from: date)
//
//            let response: [BookingRoom] = try await SupabaseManager.shared.client
//                .from("booking_rooms")
//                .select()
////                .eq("room_id", value: roomId)
////                .eq("br_date", value: dateString)
//                .execute()
//                .value
//
//            print("bookings: ", response)
//            DispatchQueue.main.async {
//                self.existingBookings = response
//            }
//        } catch {
//            print("Error fetch bookings: \(error)")
//        }
//    }
    
    func fetchBookingsForRoom(_ roomId: Int, date: Date) async {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: date)

            let response: [BookingRoom] = try await SupabaseManager.shared.client
                .from("bookings_room")
                .select()
                .eq("room_id", value: roomId)
                .eq("br_date", value: dateString)
                .execute()
                .value

            DispatchQueue.main.async {
                self.existingBookings = response
            }
        } catch {
            print("Error fetch bookings: \(error)")
        }
    }

    
    func colorForRoom(id: Int) -> Color {
        let colors: [Color] = [.purple, .red, .orange, .yellow, .green]
        return colors[id % colors.count]
    }
    
    func availableSlots(for roomId: Int, date: Date) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let allSlots = generateTimes()

        // filter booking untuk room + date
        let bookings = existingBookings.filter { $0.room_id == roomId }

        return allSlots.filter { slot in
            guard let slotDate = formatter.date(from: slot) else { return false }
            for booking in bookings {
                guard let start = formatter.date(from: booking.br_start),
                      let end = formatter.date(from: booking.br_end) else { continue }
                if slotDate >= start && slotDate < end {
                    return false // bentrok
                }
            }
            return true
        }
    }
    
    func generateTimes(start: String = "07.30", end: String = "21.00") -> [String] {
        var times: [String] = []
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let startTime = formatter.date(from: start),
              let endTime = formatter.date(from: end) else {
            return times
        }
        
        var current = startTime
        while current <= endTime {
            times.append(formatter.string(from: current))
            current = Calendar.current.date(byAdding: .minute, value: 30, to: current)!
        }
        return times
    }
}



#Preview {
    BookingRoomModalView()
}
