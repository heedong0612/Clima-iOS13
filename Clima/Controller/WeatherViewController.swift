//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation // comes with a location manager

class WeatherViewController: UIViewController {
    // UITextFieldDelegate: we need this to enable return button on keyboard.
    // search button pressed isn't the same as return button pressed.

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager() // gets the current GPS location of the phone
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self // this must be set before any other requests
        
        locationManager.requestWhenInUseAuthorization() // shows a pop up to ask a user for permission
        // Give user message by adding a new property (Privacy - Location When In Use Usage Description)
        // and a message value in info.plist
        locationManager.requestLocation() // one-time delivery; we can get the data fomr locationManager(didUpdateLocations)
        
        searchTextField.delegate = self
        // the delegeat will later on triggers some functions ex) delegate.textFieldDidBeginEditing()
        // lets the text field report back to the controller
        // (that they started/stopped typing, what they typed in,..)
        weatherManager.delegate = self
    }
    @IBAction func navigateButtonPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            // stop as soon as we get the location
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(lon, lat)
        }
    }
    
    func  locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
}

//MARK: - UITextFieldDelegate


// for parts in WeatherViewController that adopats UITextFieldDelegate protocol
extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true) // keyboard will be dismissed!
    }
    
    // triggered when the return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // if we had multiple text fields, the argument textField could've been
        // any of them
        searchTextField.endEditing(true) // keyboard will be dismissed!
        return true
    }
     
    // what happens when the user disselects the text field
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            // if the user typed something in, it should end
            return true
        } else {
            // if the user didnt, hint them and do not let the user leave
            textField.placeholder = "Type something"
            return false
        }
    }
    
    // triggered when the user stops editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text { // city is now a string rather than string?
            weatherManager.fetchWeather(city)
        }
        
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDeligate

extension WeatherViewController : WeatherManagerDeligate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, _ weather: WeatherModel) {
        DispatchQueue.main.async { // a closure to call the main thread to update the UI in the background!
            self.temperatureLabel.text = weather.temperatureString // put self becuase it's a closure
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }

    func didFailWithError(_ error: Error) {
        print(error)
    }
}
