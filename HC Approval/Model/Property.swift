//
//  Property.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct Property: Codable, Identifiable {
    let properties_id: Int
    let properties_name: String
    
    var id: Int{properties_id}
}
