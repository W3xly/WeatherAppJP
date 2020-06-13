//
//  WeatherData.swift
//  WeatherAppJP
//
//  Created by Johana Šlechtová on 11/06/2020.
//  Copyright © 2020 Jan Podmolík. All rights reserved.
//

import Foundation

struct WeatherData: Decodable {
    
    let name: String
    let main: Main
    let weather: [Weather]
    
    var model: WeatherModel {
        return WeatherModel(cityName: name,
                            temp: main.temp,
                            conditionId: weather.first?.id ?? 0,
                            conditionDescription: weather.first?.description ?? "")
    }
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
}
