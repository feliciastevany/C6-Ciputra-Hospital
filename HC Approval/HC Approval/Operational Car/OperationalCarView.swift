//
//  OperationalCarView.swift
//  HC Approval
//
//  Created by Wilbert Bryan on 31/08/25.
//

import SwiftUI

struct OperationalCarView: View {
    @AppStorage("loggedInUserId") var loggedInUserId: Int = 0
    @State private var goToProfil = false
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var cars: [BookingCarJoined] = []
    @State private var events: [carEvent] = []
    @State private var selectedCar = "All"
    @State private var selectedEvent: carEvent? = nil
    @State private var showBookingDetail = false
    let hours = Array(8...22) // jam 08.00 - 22.00
    let hourHeight: CGFloat = 80 // tinggi tetap untuk setiap jam
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Operational Car")
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: {
                    goToProfil = true
                }) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue)
                }.navigationDestination(isPresented: $goToProfil) {
                    ProfilView(userId: loggedInUserId)
                }
            }
            .padding(.top)
            .padding(.horizontal)
            
            BookingCarView()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Schedule")
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .padding(.top, 5)
                .padding(.horizontal)
                
                WeeklyCalendarView(selectedDate: $selectedDate, pickerMode: .car(selectedCar: $selectedCar))
                    .frame(height: 120)
                    .padding(.horizontal, -2)
                
                Divider()
            }
            
            // Timeline + Schedule
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
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
                                
                            }
                        }
                    }
                    
                    // Grid tiap Car (anggap analogi room → car slot)
                    ForEach(filteredCars, id: \.self) { car in
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
                                        .padding(.leading, -6)
                                    }
                                }
                                
                                // Events
                                ForEach(events.filter { $0.driver == car }) { event in
                                    ScheduleBlockCar(
                                        bc_id: event.bc_id,
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
                                    .onTapGesture {
                                        selectedEvent = event
                                        showBookingDetail = true
                                    }
                                }
                            }
                        }
                        .frame(width: filteredCars.count == 1 ? UIScreen.main.bounds.width - 60 : 150)
                    }
                    
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
        .background(Color(.systemGray6))
        // setiap kali selectedDate berubah → fetch ulang
        .onChange(of: selectedDate) { _ in
            Task {
                await fetchBookCars(for: selectedDate)
            }
        }
        .task {
            await fetchBookCars(for: selectedDate) // pertama kali load
        }
        .sheet(item: $selectedEvent) { event in
            BookingCarDetailView(bcId: event.bc_id)
        }
    }
    
    private var filteredCars: [String] {
        let result: [String]
        if selectedCar == "All" {
            result = ["1", "2"]
        } else if selectedCar == "Purbo" {
            result = ["1"]
        } else {
            result = ["2"]
        }
        print("🚗 Filtered Cars: \(result)")
        return result
    }
    
    
    
    
    func fetchBookCars(for date: Date) async {
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
}

struct ScheduleBlockCar: View {
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
        .padding(.leading, -8)
    }
    
    private func blockHeight() -> CGFloat {
        let durationMinutes = blockDurationMinutes()
        return CGFloat(durationMinutes) * hourHeight / 60.0
    }
    
    private func yOffset() -> CGFloat {
        let offsetMinutes = offsetMinutes()
        return CGFloat(offsetMinutes) * hourHeight / 60.0 + 40
    }
    
    private func blockDurationMinutes() -> Int {
        (endHour * 60 + endMinute) - (startHour * 60 + startMinute)
    }
    
    private func offsetMinutes() -> Int {
        (startHour * 60 + startMinute) - (baseHour * 60)
    }
}

struct carEvent: Identifiable {
    let id = UUID()
    let bc_id: Int
    let driver: String
    let from: String
    let destination: String
    let participant: String
    let name: String
    let dept: String
    let startHour: Int
    let startMinute: Int
    let endHour: Int
    let endMinute: Int
    let carpoolStatus: String
}
func colorForCar(_ driver: String) -> Color {
    switch driver {
    case "1": return .red
    case "2": return .green
    default: return .gray
    }
}

struct OperationalCarView_Previews: PreviewProvider {
    static var previews: some View {
        OperationalCarView()
    }
}
