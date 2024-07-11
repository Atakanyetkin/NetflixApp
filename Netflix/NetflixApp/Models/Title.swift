//
//  Title.swift
//  NetflixApp
//
//  Created by atakan yetkin on 9.07.2024.
//

import Foundation

struct TrendingTitleResponse: Codable {
    let results: [Title]
    
}

struct Title: Codable {
    let id: Int
    let media_type: String?
    let original_name: String?
    let original_title: String?
    let poster_path: String?
    let overview: String?
    let vote_count: Int?
    let realease_date: String?
    let vote_average: Double
}
