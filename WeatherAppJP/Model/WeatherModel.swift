//
//  WeatherModel.swift
//  WeatherAppJP
//
//  Created by Johana Šlechtová on 12/06/2020.
//  Copyright © 2020 Jan Podmolík. All rights reserved.
//

import Foundation

struct WeatherModel {
    
    let cityName: String
    let temp: Double
    let conditionId: Int
    let conditionDescription: String
    
    var conditionImage: String {
        switch conditionId {
            case 200...232:
            return "imThunderstorm"
            case 300...321:
            return "imDrizzle"
            case 500...531:
            return "imRain"
            case 600...622:
            return "imSnow"
            case 701...781:
            return "imAtmosphere"
            case 800:
            return "imClear"
            case 801...804:
            return "imClouds"
            default:
            return "imClear"
        }
    }
}
