//
//  WeatherManager.swift
//  WeatherAppJP
//
//  Created by Johana Šlechtová on 11/06/2020.
//  Copyright © 2020 Jan Podmolík. All rights reserved.
//

import Foundation
import Alamofire

enum WeatherError: Error, LocalizedError {
    
    case unknown
    case custom(description: String)
    
    var errorDescription: String? {
        switch self {
            case .unknown:
                return "unknown error"
            case .custom(description: let description):
                return description
        }
    }
}

struct WeatherManager {
    
    private let API_KEY = "cd049b86a81cb411c5b41a28d73bcf3f"
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
    let path = "https://api.openweathermap.org/data/2.5/weather?appid=%@&units=metric&lat=%f&lon=%f"
    let urlString = String(format: path, API_KEY, lat, lon)
        handleRequest(urlString: urlString, completion: completion)
    }
    
    func fetchWeather(city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        
        let path = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let urlString = String(format: path, query, API_KEY)
        handleRequest(urlString: urlString, completion: completion)
    }
    
    private func handleRequest(urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        
        AF.request(urlString)
            .validate()
            .responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
            switch response.result {
            case .success(let weatherData):
                let model = weatherData.model
                completion(.success(model))
            case .failure(let error):
                if let err = self.getWeatherError(error: error, data: response.data) {
                    completion(.failure(err))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getWeatherError(error: AFError, data: Data?) -> Error? {
        if error.responseCode == 404,
            let failureData = data,
            let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: failureData) {
            let message = failure.message
            return WeatherError.custom(description: message)
        } else {
            return WeatherError.unknown
        }
    }
}
