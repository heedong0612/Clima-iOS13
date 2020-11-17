//
//  WeatherManager.swift
//  Clima
//
//  Created by Donghee Lee on 2020/10/24.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDeligate {
    func didUpdateWeather(_ weatherManager: WeatherManager, _ weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid={YOUR_API_ACCESS_KEY}&units=metric"
    var delegate: WeatherManagerDeligate?
    
    func fetchWeather(_ cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString)
    }
    
    func fetchWeather(_ lon: CLLocationDegrees, _ lat: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lon=\(lon)&lat=\(lat)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String) {
        // 1. create a URL
        if let url = URL(string: urlString) {
            // URL is a String? because the string might have not been a valid url
            // 2. Create a URLsession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) { // it is good/required to put self when calling method in closrue
                        self.delegate?.didUpdateWeather(self, weather)
                    }
                    
                }
            }
            
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            // output will be the type of Weather Data
            
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            self.delegate?.didFailWithError(error)
            return nil
        }
    }
    
}
