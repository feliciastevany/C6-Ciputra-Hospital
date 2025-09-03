//
//  BookingHelper.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 02/09/25.
//

import Foundation

struct BookingTimeHelper {
    static func timeToDate(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.dateFormat = "HH:mm:ss"
        if let d = formatter.date(from: time) { return d }
        
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: time)
    }
    
    static func isBooked(time: String, bookings: [BookingRoom], forStart: Bool = true) -> Bool {
        guard let t = timeToDate(time) else { return false }
        
        for booking in bookings {
            guard let start = timeToDate(booking.br_start),
                  let end = timeToDate(booking.br_end) else { continue }
            
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
    
    static func availableStartTimes(bookings: [BookingRoom]) -> [String] {
        let all = generateHalfHourTimes(start: "07:30", end: "21:00")
        return all.filter { !isBooked(time: $0, bookings: bookings, forStart: true) }
    }
    
    static func validEndTimes(startTime: String, bookings: [BookingRoom]) -> [String] {
        guard let start = timeToDate(startTime) else { return [] }
        
        let nextBookingStart = bookings
            .compactMap { timeToDate($0.br_start) }
            .filter { $0 > start }
            .min()
        
        return generateHalfHourTimes(start: "07:30", end: "21:00").filter { timeStr in
            guard let t = timeToDate(timeStr) else { return false }
            
            guard t > start else { return false }
            guard !isBooked(time: timeStr, bookings: bookings, forStart: false) else { return false }
            
            if let nextStart = nextBookingStart {
                return t <= nextStart
            }
            return true
        }
    }
}

struct DateHelper {
    static func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd" // sesuaikan dengan format dari backend
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "en_US") // atau "id_ID" kalau mau bahasa Indonesia
        displayFormatter.dateFormat = "d MMMM yyyy" // contoh: 1 August 2025
        
        return displayFormatter.string(from: date)
    }
}
