//
//  JSONDdecoder.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 29/08/25.
//

import Foundation

extension JSONDecoder {
    static var bookingDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX" // format default supabase
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Coba beberapa format
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", // full supabase
                "yyyy-MM-dd'T'HH:mm:ssXXXXX",        // tanpa microseconds
                "yyyy-MM-dd"                         // hanya tanggal
            ]
            
            for format in formats {
                let f = DateFormatter()
                f.dateFormat = format
                f.locale = Locale(identifier: "en_US_POSIX")
                if let date = f.date(from: dateString) {
                    return date
                }
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        return decoder
    }
}

import Supabase

extension PostgrestFilterBuilder {
    func decoded<T: Decodable>(using decoder: JSONDecoder) async throws -> T {
        let data = try await self.execute().data
        return try decoder.decode(T.self, from: data)
    }
}

extension Date {
    func toEnglishFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // supaya hari & bulan pakai bahasa Indonesia
        formatter.dateFormat = "EE, d MMM yyyy"      // contoh: Senin, 1 Sept 2025
        return formatter.string(from: self)
    }
    
    func toSimpleFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self)
    }
}
