//
//  StaffRoomDetailView.swift
//  HC Approval
//
//  Created by Wilbert Bryan on 08/09/25.
//

import SwiftUI

struct StaffRoomDetailView: View {
    let name: String
    @State private var selectedDate = Date()
    @State private var room: Room = Room(
        room_id : 0,
        room_name : "",
        room_capacity : 0
    )
    
    // Timeline state
    let hours = Array(8...22)
    let hourHeight: CGFloat = 80
    
    @State private var showBookingDetail = false
    @State private var selectedBrId: Int? = nil
    // Data
    @State private var events: [roomEvent] = []
    @State private var bookingRows: [BookingRoomJoined] = []
    
    @State private var goToBooking = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text("\(name)")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button("+ Create Booking") {
                    goToBooking = true
                }
            }
            .padding()
            
            
            // Calendar
            StaffWeeklyCalendarView(selectedDate: $selectedDate)
                .onChange(of: selectedDate) { newValue in
                    Task {
                        await fetchBookRoom(for: newValue, selectedRoomName: name)
                    }
                }
                .padding(.bottom, 10)
            
        }
        .background(Color(.systemGray6))
        
        
        // Timeline (single room column)
        ScrollView([.vertical, .horizontal], showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                // Left hour ruler
                VStack(spacing: 0) {
                    ForEach(hours, id: \.self) { h in
                        HStack {
                            HStack {
                                Text("\(String(format: "%02d.00", h))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .frame(height: hourHeight)
                            .frame(width: 55, alignment: .leading)
                            
                        }
                    }
                }
                
                // One room column
                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        // Background grid
                        VStack(spacing: 0) {
                            ForEach(hours, id: \.self) { _ in
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
                        ForEach(events) { e in
                            ScheduleBlockSingle(
                                br_id: e.br_id,
                                room: e.room,
                                name: e.name,
                                dept: e.dept,
                                color: e.color,
                                startHour: e.startHour,
                                startMinute: e.startMinute,
                                endHour: e.endHour,
                                endMinute: e.endMinute,
                                hourHeight: hourHeight,
                                baseHour: hours.first ?? 8
                            )
                            .onTapGesture {
                                selectedBrId = e.br_id
                                showBookingDetail = true
                            }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 80) // lebar kolom room
            }
        }
        
        .task {
            await fetchRoomByName(name)
            await fetchBookRoom(for: selectedDate, selectedRoomName: name)
        }
        .navigationDestination(isPresented: $goToBooking) {
            let bookingList = bookingRows.map { $0.toBookingRoom() }

            let start = BookingTimeHelper
                .availableStartTimesIgnoringCancelled(bookings: bookingList)
                .first ?? ""

            let end = BookingTimeHelper
                .validEndTimes(startTime: start, bookings: bookingList)
                .first ?? ""

            RoomDetailView(
                room: room,
                slot: TimeSlot(start: start, end: end),
                date: DateHelper.toBackendFormat(selectedDate),
                bookings: bookingList
            )
        }

        .sheet(item: $selectedBrId) { brId in
            BookingRoomDetailView(brId: brId)
        }
    }
    
    // MARK: - Helpers
    func roomId(for name: String) -> Int? {
        switch name.lowercased() {
        case "room 1": return 1
        case "room 2": return 2
        case "room 3": return 3
        case "hall": return 4
        case "auditorium": return 5
        default: return nil
        }
    }
    
    func fetchRoomByName(_ roomName: String) async {
        do {
            let raw = try await SupabaseManager.shared.client
                .from("rooms")
                .select()
                .eq("room_name", value: roomName)
                .single() // cuma ambil 1
                .execute()
            
            let r: Room = try JSONDecoder().decode(Room.self, from: raw.data)
            
            await MainActor.run {
                self.room = r   // pastikan kamu punya @State var room: Room
            }
        } catch {
            print("❌ Error fetch room:", error)
        }
    }

    
    func fetchBookRoom(for date: Date, selectedRoomName: String? = nil) async {
        do {
            // "yyyy-MM-dd" untuk kolom DATE
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "yyyy-MM-dd"
            let dateOnly = df.string(from: date)
            
            var q = SupabaseManager.shared.client
                .from("bookings_room")
                .select("""
                    *,
                    room:room_id!inner(*),
                    user:user_id(*)
                """)
                .eq("br_date", value: dateOnly)
                .eq("br_status", value: "Approved")
                .eq("room.room_name", value: selectedRoomName)
                .order("br_start", ascending: true)
            
            
            let raw = try await q.execute()
            
            let rows: [BookingRoomJoined] = try JSONDecoder.bookingDecoder.decode(
                [BookingRoomJoined].self,
                from: raw.data
            )
            
            // Parser "HH:mm"
            func parseHHmm(_ s: String) -> (h: Int, m: Int)? {
                let parts = s.split(separator: ":")
                guard parts.count >= 2,
                      let h = Int(String(parts[0])),
                      let m = Int(String(parts[1])) else { return nil }
                return (h, m)
            }
            
            // Mapping → roomEvent
            let newEvents: [roomEvent] = rows.compactMap { (b: BookingRoomJoined) -> roomEvent? in
                guard let user = b.user, let room = b.room else { return nil }

                func parseHHmm(_ s: String) -> (h: Int, m: Int)? {
                    let parts = s.split(separator: ":")
                    guard parts.count >= 2,
                          let h = Int(parts[0]),
                          let m = Int(parts[1]) else { return nil }
                    return (h, m)
                }

                guard
                    let s = parseHHmm(b.br_start),
                    let e = parseHHmm(b.br_end)
                else { return nil }

                return roomEvent(
                    br_id: b.br_id,
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
                self.bookingRows = rows
                self.events = newEvents
                print("✅ Events: \(newEvents.count)")
            }
            
        } catch {
            print("❌ Error fetch bookings:", error)
        }
    }
    
    
}

struct ScheduleBlockSingle: View {
    var br_id: Int
    var room: String
    var name: String
    var dept: String
    var color: Color
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var hourHeight: CGFloat
    var baseHour: Int = 8
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name.components(separatedBy: " ").first ?? name)
                .font(.subheadline)
                .lineLimit(1)
            Text(dept)
            .font(.subheadline)
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: blockHeight(), alignment: .topLeading)
        .background(color.opacity(0.2))
        .overlay(alignment: .leading) {
            Rectangle().fill(color).frame(width: 3)
        }
        .offset(y: yOffset())
    }
    
    private func blockDurationMinutes() -> Int {
        (endHour * 60 + endMinute) - (startHour * 60 + startMinute)
    }
    private func blockHeight() -> CGFloat {
        CGFloat(blockDurationMinutes()) * hourHeight / 60.0
    }
    private func offsetMinutes() -> Int {
        (startHour * 60 + startMinute) - (baseHour * 60)
    }
    private func yOffset() -> CGFloat {
        CGFloat(offsetMinutes()) * hourHeight / 60.0 + 40
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}
extension BookingRoomJoined {
    func toBookingRoom() -> BookingRoom {
        BookingRoom(
            br_id: self.br_id,
            room_id: self.room_id,
            br_event: self.br_event,
            br_date: Self.dateToString(self.br_date),
            br_start: self.br_start,
            br_end: self.br_end,
            br_desc: self.br_desc,
            br_status: self.br_status,
            br_decline_reason: self.br_decline_reason,
            created_at: self.created_at,
            user_id: self.user?.user_id ?? 0   // fallback 0 kalau nil
        )
    }
    
    private static func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}


#Preview {
    StaffRoomDetailView(name: "Room 1")
}

