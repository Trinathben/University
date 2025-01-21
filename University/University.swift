//
//  University.swift
//  University
//
//  Created by Trinath Vikkurthi on 1/15/25.
//

import Foundation

struct University: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let domains: [String]
    let web_pages: [String]

    private enum CodingKeys: String, CodingKey {
        case name
        case web_pages
        case domains
    }
}
