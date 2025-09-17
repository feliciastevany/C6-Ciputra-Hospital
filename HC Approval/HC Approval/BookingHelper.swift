//
//  BookingHelper.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 02/09/25.
//

import Foundation

protocol Bookable {
    var startTime: String { get }
    var endTime: String { get }
}

extension BookingRoom: Bookable {
    var startTime: String { br_start }
    var endTime: String { br_end }
}

extension BookingCar: Bookable {
    var startTime: String { bc_start }
    var endTime: String { bc_end }
}

protocol HasStatus {
    var status: String { get }
}

extension BookingCar: HasStatus {
    var status: String { bc_status }
}

extension BookingRoom: HasStatus {
    var status: String { br_status }
}


struct BookingTimeHelper {
    static func timeToDate(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.dateFormat = "HH:mm:ss"
        if let d = formatter.date(from: time) { return d }
        
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: time)
    }
    
    static func isBooked<T: Bookable>(time: String, bookings: [T], forStart: Bool = true) -> Bool {
        guard let t = timeToDate(time) else { return false }
        
        for booking in bookings {
            guard let start = timeToDate(booking.startTime),
                  let end = timeToDate(booking.endTime) else { continue }
            
            if forStart {
                if t >= start && t < end {
                    return true
                }
            } else {
                if t > start && t < end {
                    return true
                }
            }
        }
        return false
    }
    
    static func generateHalfHourTimes(start: String, end: String) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let startDate = formatter.date(from: start),
              let endDate = formatter.date(from: end) else { return [] }
        
        var times: [String] = []
        var current = startDate
        
        while current <= endDate {
            times.append(formatter.string(from: current))
            current = Calendar.current.date(byAdding: .minute, value: 30, to: current)!
        }
        
        return times
    }
    
    static func currentTimeOfDay() -> Date {
        let now = Date()
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: now)
        return cal.date(from: comps)! // Date dengan jam & menit hari ini
    }
    
    // Dipake waktu selected date = hari ini
    static func availableTodayStartTimes<T: Bookable>(bookings: [T]) -> [String] {
        let all = generateHalfHourTimes(start: "07:30", end: "20:30")
            
        let now = DateHelper.currentHourMinute()
            
        return all.filter { timeStr in
            guard let slot = DateHelper.timeStringToHourMinute(timeStr) else { return false }
                
            // cek apakah slot >= jam sekarang
            if slot.hour < now.hour || (slot.hour == now.hour && slot.minute < now.minute) {
                return false
            }
                
            return !isBooked(time: timeStr, bookings: bookings, forStart: true)
        }
    }
        
    static func availableTodayStartTimesIgnoringCancelled<T: Bookable & HasStatus>(bookings: [T]) -> [String] {
        let activeBookings = bookings.filter {
            let status = $0.status.lowercased()
            return status != "cancel" && status != "cancelled" && status != "declined"
        }
            
        return availableTodayStartTimes(bookings: activeBookings)
    }


    // Dipake waktu selected date != hari ini
//    static func availableStartTimes<T: Bookable>(bookings: [T]) -> [String] {
//        let all = generateHalfHourTimes(start: "07:30", end: "20:30")
//        let now = currentTimeOfDay() // pakai jam & menit sekarang
//            
//        return all.filter { timeStr in
//            guard let t = timeToDate(timeStr) else { return false }
//                
//            // Cek slot >= waktu sekarang
//            guard t >= now else { return false }
//                
//            return !isBooked(time: timeStr, bookings: bookings, forStart: true)
//        }
//    }
        
    static func availableStartTimesIgnoringCancelled<T: Bookable & HasStatus>(bookings: [T]) -> [String] {
        let activeBookings = bookings.filter {
            let status = $0.status.lowercased()
            return status != "cancel" && status != "cancelled" && status != "declined"
        }
            
        let all = generateHalfHourTimes(start: "07:30", end: "20:30")
        let now = currentTimeOfDay()
            
        return all.filter { timeStr in
            guard let t = timeToDate(timeStr) else { return false }
            guard t >= now else { return false }
            return !isBooked(time: timeStr, bookings: activeBookings, forStart: true)
        }
    }
    
    static func validEndTimes<T: Bookable>(startTime: String, bookings: [T]) -> [String] {
        guard let start = timeToDate(startTime) else { return [] }
        
        let nextBookingStart = bookings
            .compactMap { timeToDate($0.startTime) }
            .filter { $0 > start }
            .min()
        
        return generateHalfHourTimes(start: "08:00", end: "21:00").filter { timeStr in
            guard let t = timeToDate(timeStr) else { return false }
            
            guard t > start else { return false }
            guard !isBooked(time: timeStr, bookings: bookings, forStart: false) else { return false }
            
            if let nextStart = nextBookingStart {
                return t <= nextStart
            }
            return true
        }
    }
    
    static func validEndTimesIgnoringCancelled<T: Bookable & HasStatus>(startTime: String, bookings: [T]) -> [String] {
        let activeBookings = bookings.filter {
            let status = $0.status.lowercased()
            return status != "cancel" && status != "cancelled" && status != "declined"
        }
        return validEndTimes(startTime: startTime, bookings: activeBookings)
    }
}


struct DateHelper {
    static func isToday(_ dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: dateString) else { return false }
        return Calendar.current.isDateInToday(date)
    }

    /// Format Date → "yyyy-MM-dd" (buat backend)
    static func toBackendFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// Format "yyyy-MM-dd" → "d MMMM yyyy" (buat UI)
    static func toDisplayFormat(_ dateString: String, locale: String = "en_US") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: locale)
        displayFormatter.dateFormat = "d MMMM yyyy"
        
        return displayFormatter.string(from: date)
    }
    
    static func currentHourMinute() -> (hour: Int, minute: Int) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
        return (comps.hour ?? 0, comps.minute ?? 0)
    }

    static func timeStringToHourMinute(_ time: String) -> (hour: Int, minute: Int)? {
        let parts = time.split(separator: ":")
        guard parts.count == 2,
              let h = Int(parts[0]),
              let m = Int(parts[1]) else { return nil }
        return (h, m)
    }
}

