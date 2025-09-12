import SwiftUI

struct StaffWeeklyCalendarView: View {
    @State private var currentWeekStart: Date = Calendar.current.startOfWeek(for: Date())
    @State private var dragOffset: CGFloat = 0
    @Binding var selectedDate: Date
    @State private var didSetup = false
    
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    private let horizontalPadding: CGFloat = 15

    private let months = DateFormatter().monthSymbols ?? []

    var body: some View {
        VStack(spacing: 12) {

            // === Month card ===
            HStack {
                Text("Month")
                    .foregroundStyle(.secondary)
                Spacer()
                Menu {
                    ForEach(1...12, id: \.self) { m in
                        Button(months[m-1]) { changeMonth(to: m) }
                    }
                } label: {
                    Text(months[safe: selectedMonth - 1] ?? "-")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.systemGray5))
                        )
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal, horizontalPadding)

            // === Days of week ===
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
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(isSelected ? Color.accentColor : Color.clear)
                    .foregroundColor(isSelected ? .white : .primary)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedDate = day }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .offset(x: dragOffset)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { dragOffset = $0.translation.width }
                    .onEnded { value in
                        let threshold: CGFloat = 80 // tak perlu GeometryReader
                        if value.translation.width < -threshold {
                            if let newDate = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekStart) {
                                withAnimation(.spring()) { currentWeekStart = newDate }
                            }
                        } else if value.translation.width > threshold {
                            if let newDate = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart) {
                                withAnimation(.spring()) { currentWeekStart = newDate }
                            }
                        }
                        withAnimation(.interactiveSpring()) { dragOffset = 0 }
                    }
            )
        }
        // ⬇️ Biar benar-benar “size to fit”
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            guard !didSetup else { return }
            currentWeekStart = Calendar.current.startOfWeek(for: selectedDate)
            selectedMonth = Calendar.current.component(.month, from: selectedDate)
            didSetup = true
        }
    }

    private func changeMonth(to newMonth: Int) {
        selectedMonth = newMonth
        let year = Calendar.current.component(.year, from: Date())
        if let newDate = Calendar.current.date(from: DateComponents(year: year, month: newMonth, day: 1)) {
            currentWeekStart = Calendar.current.startOfWeek(for: newDate)
            selectedDate = newDate
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


#Preview {
    StaffWeeklyCalendarView(selectedDate: .constant(Date()))
        .background(Color(.systemGray6))
}
