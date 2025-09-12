//
//  Property.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct Property: Codable, Identifiable {
    var properties_id: Int
    var properties_name: String
    
    var id: Int{properties_id}
}

struct SelectedProperty: Identifiable {
    var id: Int { property.id }
    var property: Property
    var quantity: Int
}


