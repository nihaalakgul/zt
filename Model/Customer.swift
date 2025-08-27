//
//  Customer.swift
//  zt
//
//  Created by Nihal Akgül on 18.08.2025.
//

import Foundation

struct Customer: Codable, Identifiable {
    var id: String
    var nationalId: String
    var createdAt: Date
    var riskScore: Int?
    var riskFlags: [String]?
}
