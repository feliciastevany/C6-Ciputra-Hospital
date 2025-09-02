//
//  BookingStatus&Type.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 29/08/25.
//
import Foundation
import SwiftUI

enum BookingStatus: String, CaseIterable {
    case pending = "Pending"
    case approved = "Approved"
    case declined = "Declined"
    case cancelled = "Cancelled"
}

enum BookingType: String, CaseIterable {
    case all = "All"
    case rooms = "Rooms"
    case cars = "Cars"
}
