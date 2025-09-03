//
//  BookingRoomDetail.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct BookingRoomDetail: Codable, Identifiable {
    var properties_id: Int
    var br_id: Int
    var qty: Int
    
    var id: String{"\(br_id)-\(properties_id)"}
}
