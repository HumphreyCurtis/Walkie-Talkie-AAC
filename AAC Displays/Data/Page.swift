//
//  Page.swift
//  AAC Displays
//
//  Created by Humphrey Curtis on 01/04/2024.
//

import Foundation

struct Page: Identifiable, Codable {
    let id: UUID
    let pageExpression: String
    let backgroundColour: String
}


