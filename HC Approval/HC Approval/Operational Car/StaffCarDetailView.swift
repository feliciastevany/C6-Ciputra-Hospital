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
    @State private var driver: Driver = Driver(
        driver_id: 0,
        driver_name: "",
        driver_phone: "",
        driver_active: false
    )
    
    // Timeline state
    let hours = Array(8...22)
    let hourHeight: CGFloat = 80
    
    // Data
    @State private var events: [carEvent] = []
    @State private var cars: [BookingCarJoined] = []
    
    @State private var selectedEvent: carEvent? = nil
    @State private var showBookingDetail = false
    
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
                                bc_id: event.bc_id,
                                driver: event.driver,
                                from: event.from,
                                destination: event.destination,
                                participant: event.participant,
                                name: event.name,
                                dept: event.dept,
                                color: event.bc_status == "Approved"
                                        ? colorForCar(event.driver)
                                        : .gray,
                                startHour: event.startHour,
                                startMinute: event.startMinute,
                                endHour: event.endHour,
                                endMinute: event.endMinute,
                                hourHeight: hourHeight,
                                carpoolStatus: event.carpoolStatus
                            )
                            .onTapGesture {
                                selectedEvent = event
                                showBookingDetail = true
                            }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 80) // lebar kolom room
            }
        }
        
        .task {
            await fetchDriverByName(name)
            await fetchBookCar(for: selectedDate, selectedCarName: name)
        }
        .sheet(item: $selectedEvent) { event in
            BookingCarDetailView(
                bcId: event.bc_id,
                onDismiss: {
                    Task {
                        await fetchBookCar(for: selectedDate)
                    }
                }
            )
        }
        .navigationDestination(isPresented: $goToBooking) {
            let bookingList = cars.map { $0.toBookingCar() }

            // cari start pertama
            let start = BookingTimeHelper
                .availableStartTimesIgnoringCancelled(bookings: bookingList)
                .first ?? ""

            // cari end valid untuk start tsb
            let end = BookingTimeHelper
                .validEndTimes(startTime: start, bookings: bookingList)
                .first ?? ""

            CarDetailView(
                driver: driver,
                slot: TimeSlot(start: start, end: end),
                date: DateHelper.toBackendFormat(selectedDate),
                passengers: 1,
                bookings: bookingList
            )
        }

    }
    
    
    func fetchDriverByName(_ driverName: String) async {
        do {
            let raw = try await SupabaseManager.shared.client
                .from("drivers")
                .select()
                .eq("driver_name", value: driverName)
                .single() // cuma ambil 1
                .execute()
            
            let d: Driver = try JSONDecoder().decode(Driver.self, from: raw.data)
            
            await MainActor.run {
                self.driver = d
            }
        } catch {
            print("❌ Error fetch driver:", error)
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
                .or("bc_status.eq.Approved,bc_status.eq.Pending")
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
                    bc_id: booking.bc_id,
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
                    carpoolStatus: booking.carpool_status,
                    bc_status: booking.bc_status
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
    var bc_id: Int
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
extension BookingCarJoined {
    func toBookingCar() -> BookingCar {
        return BookingCar(
            bc_id: self.bc_id,
            user_id: self.user_id,
            driver_id: self.driver_id,
            bc_date: Self.dateToString(self.bc_date),
            bc_start: self.bc_start,
            bc_end: self.bc_end,
            bc_from: self.bc_from,
            bc_desc: self.bc_desc,
            bc_people: self.bc_people,
            bc_status: self.bc_status,
            bc_decline_reason: self.bc_decline_reason ?? "",
            carpool_req: self.carpool_req ?? false,
            carpool_desc: self.carpool_desc ?? "",
            carpool_status: self.carpool_status,
            created_at: self.created_at ?? Date()
        )
    }
    
    private static func dateToString(_ date: Date?) -> String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"   // format sesuai kolom supabase
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}




#Preview {
    StaffCarDetailView(name: "Purbo")
}

