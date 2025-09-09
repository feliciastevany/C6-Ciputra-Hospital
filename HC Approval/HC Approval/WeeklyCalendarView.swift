//
//  WeeklyCalendarView.swift
//  HC Approval
//
//  Created by Wilbert Bryan on 31/08/25.
//

import SwiftUI

enum PickerMode {
    case room(selectedRoom: Binding<String>?)
    case car(selectedCar: Binding<String>?)
}

struct WeeklyCalendarView: View {
    @State private var currentWeekStart: Date = Calendar.current.startOfWeek(for: Date())
    @State private var dragOffset: CGFloat = 0
    @Binding var selectedDate: Date // tanggal yang dipilih
    
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    private let horizontalPadding: CGFloat = 5
    
    @State private var internalSelectedRoom: String = "All"
    @State private var internalSelectedCar: String = "All"

    let rooms = ["All", "Room 1", "Room 2", "Room 3", "Hall", "Auditorium"]
    let cars = ["All", "Purbo", "Sahrul"]
    
    var pickerMode: PickerMode
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 12) {
                
                HStack{
                    // 🔹 Month Picker
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(DateFormatter().monthSymbols[month - 1])
                                .tag(month)
                        }
                    }
                    .padding(.horizontal, 6)
                    Spacer()

                    switch pickerMode {
                    // 🔹 Room Picker
                    case .room(let selectedRoomBinding):
                        Picker("Room", selection: selectedRoomBinding ?? $internalSelectedRoom) {
                            ForEach(rooms, id: \.self) { room in
                                Text(room).tag(room)
                            }
                        }
                        
                    // 🔹 Car Picker
                    case .car(let selectedCarBinding):
                        Picker("Car", selection: selectedCarBinding ?? $internalSelectedCar) {
                            ForEach(cars, id: \.self) { car in
                                Text(car).tag(car)
                            }
                        }
                    }
                
                }
                
                
                .pickerStyle(.menu)
                .onChange(of: selectedMonth) { newMonth in
                    // Update currentWeekStart sesuai bulan yg dipilih
                    let year = Calendar.current.component(.year, from: Date())
                    if let newDate = Calendar.current.date(from: DateComponents(year: year, month: newMonth, day: 1)) {
                        currentWeekStart = Calendar.current.startOfWeek(for: newDate)
                        selectedDate = newDate
                    }
                }
                
                // 🔹 Days of the week
                HStack {
                    ForEach(0..<7, id: \.self) { i in
                        let day = Calendar.current.date(byAdding: .day, value: i, to: currentWeekStart)!
                        let isSelected = Calendar.current.isDate(selectedDate, inSameDayAs: day)
                        
                        VStack(spacing: 6) {
                            Text(day, format: Date.FormatStyle().weekday(.narrow))
                                .font(.caption)
                            
                            Text(day, format: Date.FormatStyle().day())
                                .font(.headline)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .background(isSelected ? Color.accentColor : Color.clear)
                        .foregroundColor(isSelected ? .white : .primary)
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .onTapGesture {
                            selectedDate = day
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold = geo.size.width * 0.18
                            
                            if value.translation.width < -threshold {
                                if let newDate = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekStart) {
                                    withAnimation(.spring()) {
                                        currentWeekStart = newDate
                                    }
                                }
                            } else if value.translation.width > threshold {
                                if let newDate = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart) {
                                    withAnimation(.spring()) {
                                        currentWeekStart = newDate
                                    }
                                }
                            }
                            
                            withAnimation(.interactiveSpring()) {
                                dragOffset = 0
                            }
                        }
                )
            }
        }
        .onAppear {
            selectedDate = Date()
            selectedMonth = Calendar.current.component(.month, from: Date())
        }
    }
}

// MARK: - Helpers
extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        var cal = self
        // Jika mau minggu mulai Senin:
        // cal.firstWeekday = 2
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? date
    }
}

//#Preview {
//    WeeklyCalendarView()
//}
