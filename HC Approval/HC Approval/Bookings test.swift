//
//  Bookings test.swift
//  HC Approval
//
//  Created by Graciella Michelle Siswoyo on 28/08/25.

import Foundation

struct Bookings: Identifiable {
    var title: String
    var start: String
    var stop: String
    var event: String
    var date: String
    var id: String { title }
    var status: String
}

