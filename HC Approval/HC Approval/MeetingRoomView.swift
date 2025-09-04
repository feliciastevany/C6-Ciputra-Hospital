//
//  MeetingRoomView.swift
//  HC Approval
//
//  Created by Wilbert Bryan on 31/08/25.
//

import SwiftUI

struct MeetingRoomView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var rooms: [BookingRoomJoined] = []
    @State private var events: [roomEvent] = []
    @State private var selectedRoom = "All"
    let hours = Array(8...22) // jam 08.00 - 22.00
    let hourHeight: CGFloat = 60 // tinggi tetap untuk setiap jam
    
    var body: some View {
        VStack(spacing: 0) {
            // Header + Month + Date Selector
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Meeting Rooms")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    Button(action: {
                        print("Profile tapped")
                    }) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                BookingFilterView()
                    .padding(.top, -15)
                    .padding(.bottom, 10)
                
                HStack {
                    Text("Schedule")
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .padding()
                
                WeeklyCalendarView(selectedDate: $selectedDate, pickerMode: .room(selectedRoom: $selectedRoom))
                    .frame(height: 120)
                    .padding(.horizontal, -2)
                
            }
            .background(Color(.systemGray6))
            
            Divider()
            
            // Timeline + Schedule
            ScrollView([.horizontal, .vertical]) {
                HStack(alignment: .top, spacing: 0) {
                    // Kolom jam di sisi kiri
                    VStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            HStack {
                                HStack {
                                    Text("\(String(format: "%02d.00", hour))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                .frame(height: hourHeight)
                                .frame(width: 50, alignment: .leading)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                        }
                    }
                    
                    // Grid tiap Room
                    ForEach(filteredRooms, id: \.self) { room in
                        VStack(spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                // Background grid
                                VStack(spacing: 0) {
                                    ForEach(hours, id: \.self) { hour in
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 1)
                                            Rectangle()
                                                .fill(Color.clear)
                                                .frame(height: hourHeight)
                                        }
                                    }
                                }
                                
                                // Events
                                ForEach(events.filter { event in
                                    (selectedRoom == "All" || event.room == selectedRoom) && event.room == room
                                }) { event in
                                    ScheduleBlock(
                                        room: event.room,
                                        name: event.name,
                                        dept: event.dept,
                                        color: event.color,
                                        startHour: event.startHour,
                                        startMinute: event.startMinute,
                                        endHour: event.endHour,
                                        endMinute: event.endMinute,
                                        hourHeight: hourHeight
                                    )
                                }
                            }
                        }
                        .frame(width: filteredRooms.count == 1 ? UIScreen.main.bounds.width - 60 : 90)
                    }
                }
                .padding()
            }
        }
        // setiap kali selectedDate berubah → fetch ulang
        .onChange(of: selectedDate) { _ in
            Task {
                await fetchBookRooms(for: selectedDate)
            }
        }
        .task {
            await fetchBookRooms(for: selectedDate) // pertama kali load
        }
    }
    private var filteredRooms: [String] {
        if selectedRoom == "All" {
            return ["Room 1", "Room 2", "Room 3", "Hall", "Auditorium"]
        } else {
            return [selectedRoom]
        }
    }
    
    func fetchBookRooms(for date: Date) async {
        do {
            // Siapkan "yyyy-MM-dd" utk kolom br_date tipe DATE
            let dayFormatter = DateFormatter()
            dayFormatter.locale = Locale(identifier: "en_US_POSIX")
            dayFormatter.dateFormat = "yyyy-MM-dd"
            let dateOnly = dayFormatter.string(from: date)

            print("🗓️ Query date: \(dateOnly)")

            let raw = try await SupabaseManager.shared.client
                .from("bookings_room")
                .select("""
                    *,
                    user:user_id(*),
                    room:room_id(*)
                """)
                .eq("br_date", value: dateOnly)
                .eq("br_status", value: "Approved")
                .execute()

            let rows: [BookingRoomJoined] = try JSONDecoder.bookingDecoder.decode(
                [BookingRoomJoined].self,
                from: raw.data
            )

            print("✅ Response count: \(rows.count)")

            // Mapping → roomEvent
            let newEvents: [roomEvent] = rows.compactMap { booking in
                guard let user = booking.user, let room = booking.room else { return nil }

                func parseHHmm(_ s: String) -> (h: Int, m: Int)? {
                    let p = s.split(separator: ":").compactMap { Int($0) }
                    guard p.count >= 2 else { return nil }
                    return (p[0], p[1])
                }

                guard
                    let s = parseHHmm(booking.br_start),
                    let e = parseHHmm(booking.br_end)
                else { return nil }

                return roomEvent(
                    room: room.room_name,
                    name: user.user_name,
                    dept: user.user_dept,
                    color: colorForRoom(room.room_name),
                    startHour: s.h,
                    startMinute: s.m,
                    endHour: e.h,
                    endMinute: e.m
                )
            }

            await MainActor.run {
                self.events = newEvents
                print("📌 Events count: \(newEvents.count)")
                for e in newEvents {
                    print("➡️ \(e.room) | \(e.name) | \(e.dept) | \(e.startHour):\(String(format: "%02d", e.startMinute)) - \(e.endHour):\(String(format: "%02d", e.endMinute))")
                }
            }

        } catch {
            print("❌ Error fetch bookings:", error)
        }
    }

}

struct ScheduleBlock: View {
    var room: String
    var name: String
    var dept: String
    var color: Color
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var hourHeight: CGFloat
    
    let baseHour = 8 // timeline mulai 08:00
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(room)
                .bold()
                .font(.caption)
            Text(name)
                .font(.caption2)
            Text(dept)
                .font(.caption2)
                .lineLimit(2)
        }
        .padding(6)
        .frame(width: 90, height: blockHeight(), alignment: .topLeading)
        .background(color.opacity(0.20))
        .overlay(alignment: .leading) {
            Rectangle().fill(color).frame(width: 3)   // accent bar kiri
        }
        .offset(y: yOffset())
    }
    
    private func blockHeight() -> CGFloat {
        let durationMinutes = blockDurationMinutes()
        return CGFloat(durationMinutes) * hourHeight / 60.0
    }
    
    private func yOffset() -> CGFloat {
        let offsetMinutes = offsetMinutes()
        return CGFloat(offsetMinutes) * hourHeight / 60.0 + 30
    }
    
    private func blockDurationMinutes() -> Int {
        (endHour * 60 + endMinute) - (startHour * 60 + startMinute)
    }
    
    private func offsetMinutes() -> Int {
        (startHour * 60 + startMinute) - (baseHour * 60)
    }
}

struct roomEvent: Identifiable {
    let id = UUID()
    let room: String
    let name: String
    let dept: String
    let color: Color
    let startHour: Int
    let startMinute: Int
    let endHour: Int
    let endMinute: Int
}

func colorForRoom(_ roomName: String) -> Color {
    switch roomName.lowercased() {
    case "room 1": return .red
    case "room 2": return .orange
    case "room 3": return .yellow
    case "hall": return .purple
    case "auditorium": return .green
    default: return .gray
    }
}

struct MeetingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingRoomView()
    }
}
