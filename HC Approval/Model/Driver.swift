//
//  Driver.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct Driver: Codable, Identifiable {
    var driver_id: Int
    var driver_name: String
    var driver_phone: String
    var driver_active: Bool
    
    var id: Int{driver_id}
}
