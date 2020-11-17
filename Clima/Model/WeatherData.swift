//
//  WeatherData.swift
//  Clima
//
//  Created by Donghee Lee on 2020/10/24.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct WeatherData: Codable { // Codable - type alias for Decodable and Encodable
    let name: String // city name
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}
