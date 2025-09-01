//
//  WeeklyCalendarView.swift
//  HC Approval
//
//  Created by Wilbert Bryan on 31/08/25.
//

import SwiftUI

struct WeeklyCalendarView: View {
    @State private var currentWeekStart: Date = Calendar.current.startOfWeek(for: Date())
    @State private var dragOffset: CGFloat = 0
    @Binding var selectedDate: Date // tanggal yang dipilih
    
    private let horizontalPadding: CGFloat = 5
    private let circleSize: CGFloat = 40 // circle besar
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 12) {
                
                HStack(){
                    // Title: Nama bulan
                    Text(weekTitle(for: currentWeekStart))
                        .font(.title2)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                
                
                // Days of the week
                HStack() {
                    ForEach(0..<7, id: \.self) { i in
                        let day = Calendar.current.date(byAdding: .day, value: i, to: currentWeekStart)!
                        let isSelected = Calendar.current.isDate(selectedDate ?? Date.distantPast, inSameDayAs: day)
                        let isToday = Calendar.current.isDateInToday(day)
                        
                        VStack(spacing: 6) {
                            Text(day, format: Date.FormatStyle().weekday(.narrow))
                                .font(.caption)
                            
                            Text(day, format: Date.FormatStyle().day())
                                .font(.headline)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .background(isSelected ? Color.accentColor : Color.clear) // biru kalau selected
                        .foregroundColor(isSelected ? .white : .primary)          // text putih kalau selected
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .onTapGesture {
                            selectedDate = day
                            // Print tanggal ke console
                            let comps = Calendar.current.dateComponents([.day, .month, .year], from: day)
                            if let d = comps.day, let m = comps.month, let y = comps.year {
                                print("Selected date: \(d), month: \(m), year: \(y)")
                                print("Click Selected date: \(selectedDate)")
                            }
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
                                // Swipe kiri → next week
                                if let newDate = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekStart) {
                                    withAnimation(.spring()) {
                                        currentWeekStart = newDate
                                    }
                                }
                            } else if value.translation.width > threshold {
                                // Swipe kanan → previous week
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
            // ketika page terload → ambil current date format yyyy-MM-dd
            let today = Date()
            print(today)
            selectedDate = today
        }
        
    }
    private func printDateFormatted(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formatted = formatter.string(from: date)
        print("Selected date: \(formatted)")
    }
    
    private func dayWidth(in geo: GeometryProxy) -> CGFloat {
        return (geo.size.width - horizontalPadding * 2) / 7
    }
    
}

// MARK: - Helpers
extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        var cal = self
        // Uncomment jika minggu ingin mulai Senin
        // cal.firstWeekday = 2
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? date
    }
}

extension WeeklyCalendarView {
    func weekTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
}

//#Preview {
//    WeeklyCalendarView()
//}
