//
//  Driver.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct Driver: Codable, Identifiable {
    let driver_id: Int
    let driver_name: String
    let driver_phone: String
    let driver_active: Bool
    
    var id: Int{driver_id}
}
