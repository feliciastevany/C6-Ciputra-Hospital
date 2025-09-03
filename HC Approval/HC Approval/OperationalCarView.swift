//
//  OperationalCarView.swift
//  HC Approval
//
//  Created by Wilbert Bryan on 31/08/25.
//

import SwiftUI

struct OperationalCarView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var cars: [BookingCar] = []
    @State private var events: [carEvent] = []
    @State private var selectedCar = "All"
    let hours = Array(8...22) // jam 08.00 - 22.00
    let hourHeight: CGFloat = 60 // tinggi tetap untuk setiap jam
    
    var body: some View {
        VStack(spacing: 0) {
            // Header + Month + Date Selector
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Operational Car")
                        .font(.title)
                        .bold()
                    Button(action: {}) {
                        Image(systemName: "plus.circle")
                            .font(.title.bold())
                    }
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
                
                WeeklyCalendarView(selectedDate: $selectedDate, pickerMode: .car(selectedCar: $selectedCar))
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
                                    }
                                }
                                
                                // Events
                                ForEach(events.filter { $0.driver == car }) { event in
                                    ScheduleBlockCar(
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
                                        hourHeight: hourHeight
                                    )
                                }
                            }
                        }
                        .frame(width: filteredCars.count == 1 ? UIScreen.main.bounds.width - 60 : 150)
                    }

                }
                .padding()
            }
        }
        // setiap kali selectedDate berubah → fetch ulang
        .onChange(of: selectedDate) { _ in
            Task {
                await fetchBookCars(for: selectedDate)
            }
        }
        .task {
            await fetchBookCars(for: selectedDate) // pertama kali load
        }
        
    }
    
    private var filteredCars: [String] {
        let result: [String]
        if selectedCar == "All" {
            result = cars.map { String($0.driver_id) }
        } else if selectedCar == "Car 1" {
            result = ["1"]
        } else {
            result = ["2"]
        }
        print("🚗 Filtered Cars: \(result)")
        return result
    }


    
    
    func fetchBookCars(for date: Date) async {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let todayString = formatter.string(from: date)
            
            print("🗓️ Query date: \(todayString)")
            
            let response: [BookingCar] = try await SupabaseManager.shared.client
                .from("bookings_car")
                .select("""
                    *,
                    user:user_id(*),
                    driver:driver_id(*),
                    destination:bc_id(*)
                """)
                .eq("bc_date", value: todayString)
                .execute()
                .value
            
            print("✅ Response count: \(response.count)")
            print("✅ Response detail: \(response)")
            
            // 🟢 Konversi BookingCar → Event
            let newEvents: [carEvent] = response.compactMap { booking in
                guard
                    let user = booking.user,
                    let driver = booking.driver
                else { return nil }
                
                // parse start/end time
                let startParts = booking.bc_start.split(separator: ":").compactMap { Int($0) }
                let endParts = booking.bc_end.split(separator: ":").compactMap { Int($0) }
                
                guard startParts.count >= 2, endParts.count >= 2 else { return nil }
                
                return carEvent(
                    driver: String(driver.driver_id),  // atau driver.name kalau ada
                    from: booking.bc_from,
                    destination: booking.destination?.map { $0.destination_name }.joined(separator: ", ") ?? "-",
                    participant: "\(booking.bc_people)",
                    name: user.user_name,
                    dept: user.user_dept,
                    startHour: startParts[0],
                    startMinute: startParts[1],
                    endHour: endParts[0],
                    endMinute: endParts[1]
                )
            }
            DispatchQueue.main.async {
                cars = response
                events = newEvents
            }

        } catch {
            print("❌ Error fetch cars:", error)
        }
    }
}

struct ScheduleBlockCar: View {
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
    
    let baseHour = 8 // timeline mulai 08:00
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
           
            Text("\(Image(systemName: "mappin.and.ellipse")) \(from)")
                .bold()
                .font(.caption)
            Text("\(Image(systemName: "location")) \(destination)")
                .bold()
                .font(.caption)
            Text("\(Image(systemName:"person.fill")) \(participant)/7")
                .font(.caption2)
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

struct carEvent: Identifiable {
    let id = UUID()
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
