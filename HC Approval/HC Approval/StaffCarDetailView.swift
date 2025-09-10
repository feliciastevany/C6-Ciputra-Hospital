//
//  StaffCarDetailView.swift
//  HC Approval
//
//  Created by Wilbert Bryan on 09/09/25.
//

import SwiftUI

struct StaffCarDetailView: View {
    let name: String
    @State private var selectedDate = Date()
    
    // Timeline state
    let hours = Array(8...22)
    let hourHeight: CGFloat = 80
    
    // Data
    @State private var events: [carEvent] = []
    @State private var cars: [BookingCarJoined] = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text("\(name)")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    print("Profile tapped")
                }) {
                    Text("+ Create Booking")
                }
            }
            .padding()
            
            
            // Calendar
            StaffWeeklyCalendarView(selectedDate: $selectedDate)
                .onChange(of: selectedDate) { newValue in
                    Task {
                        await fetchBookCar(for: newValue, selectedCarName: name)
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
                        ForEach(events) { event in
                            ScheduleCarBlockSingle(
                                driver: event.driver,
                                from: event.from,
                                destination: event.destination,
                                participant: event.participant,
                                name: event.name,
                                dept: event.dept,
                                color: colorForCar(event.driver),
                                startHour: event.startHour,
                                startMinute: event.startMinute,
                                endHour: event.endHour,
                                endMinute: event.endMinute,
                                hourHeight: hourHeight,
                                carpoolStatus: event.carpoolStatus
                            )
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 80) // lebar kolom room
            }
        }
        
        .task {
            await fetchBookCar(for: selectedDate, selectedCarName: name)
        }
    }
    
    func fetchBookCar(for date: Date, selectedCarName: String? = nil) async {
        do {
            // "yyyy-MM-dd" untuk kolom DATE
            let dayFormatter = DateFormatter()
            dayFormatter.locale = Locale(identifier: "en_US_POSIX")
            dayFormatter.dateFormat = "yyyy-MM-dd"
            let dateOnly = dayFormatter.string(from: date)

            print("🗓️ Query date: \(dateOnly)")

            // Query → execute → decode pakai JSONDecoder.bookingDecoder
            let raw = try await SupabaseManager.shared.client
                .from("bookings_car")
                .select("""
                    *,
                    user:user_id(*),
                    driver:driver_id(*),
                    destination:destinations!destinations_bc_id_fkey(*)
                """)
                .eq("bc_date", value: dateOnly)
                .eq("bc_status", value: "Approved")
                .eq("driver.driver_name", value: selectedCarName)
                .order("bc_start", ascending: true)
                .execute()

            let rows: [BookingCarJoined] = try JSONDecoder.bookingDecoder.decode(
                [BookingCarJoined].self,
                from: raw.data
            )

            print("✅ Response count: \(rows.count)")
            // print("✅ Detail: \(rows)")

            // Mapping → carEvent
            let newEvents: [carEvent] = rows.compactMap { booking in
                guard let user = booking.user, let driver = booking.driver else { return nil }

                func parseHHmm(_ s: String) -> (h: Int, m: Int)? {
                    let p = s.split(separator: ":").compactMap { Int($0) }
                    guard p.count >= 2 else { return nil }
                    return (p[0], p[1])
                }

                guard
                    let s = parseHHmm(booking.bc_start),
                    let e = parseHHmm(booking.bc_end)
                else { return nil }

                let destText = (booking.destination?.map { $0.destination_name }.joined(separator: ", ")) ?? "-"

                return carEvent(
                    driver: String(driver.driver_id),        // ganti ke driver_name kalau ada
                    from: booking.bc_from,
                    destination: destText,
                    participant: "\(booking.bc_people)",
                    name: user.user_name,
                    dept: user.user_dept,
                    startHour: s.h,
                    startMinute: s.m,
                    endHour: e.h,
                    endMinute: e.m,
                    carpoolStatus: booking.carpool_status
                )
            }

            await MainActor.run {
                self.cars = rows
                self.events = newEvents
            }

        } catch {
            print("❌ Error fetch cars:", error)
        }
    }

    func roomId(for name: String) -> Int? {
        switch name.lowercased() {
        case "purbo": return 1
        case "sahrul": return 2
        default: return nil
        }
    }
    
}

struct ScheduleCarBlockSingle: View {
    var driver: String
    var from: String
    var destination: String
    var participant: String
    var name: String
    var dept: String
    var color: Color
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var hourHeight: CGFloat
    var carpoolStatus: String
    let baseHour = 8 // timeline mulai 08:00
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            
            Text("\(Image(systemName: "mappin.and.ellipse")) \(from)")
                .bold()
                .font(.caption)
            Text("\(Image(systemName: "location")) \(destination)")
                .bold()
                .font(.caption)
            
            if carpoolStatus == "Approved"{
                Text("Full booked")
                    .bold()
                    .font(.caption)
            }
            else{
                Text("\(Image(systemName:"person.fill")) \(participant)/7")
                    .font(.caption2)
            }
            
            Text("\(name) - \(dept)")
                .font(.caption2)
        }
        .padding(6)
        .frame(width: 150, height: blockHeight(), alignment: .topLeading)
        .background(color.opacity(0.20))
        .overlay(alignment: .leading) {
            Rectangle().fill(color).frame(width: 3)   // accent bar kiri
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

#Preview {
    StaffCarDetailView(name: "Purbo")
}

