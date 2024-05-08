//
//  ViewController.swift
//  Weather-Lab3
//
//  Created by Anand Krishna Shiju on 2023-11-17.   
//

import UIKit
import CoreLocation


struct Location: Codable {
    let name: String
}

struct Weather: Codable {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Codable {
    let text: String
    let code: Int
}

struct WeatherResponse: Codable {
    let location: Location
    let current: Weather
}


class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var toggleBtn: UISwitch!

    @IBOutlet weak var conditionTemp: UILabel!
    var tempInCelcius: Float = 0.0
    var tempInFarenheit: Float = 0.0

    let locationManager = CLLocationManager()

    
    var searchedCities: [WeatherResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "backgroundImage.jpg")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        searchTextField.delegate = self
        configureLocationManager()
        toggleBtn.isOn = false
        loadWeather(search: "London,Ontario")
        
        
        loadSearchedCities()
    }

    private func displaySampleImageForDemo() {
        let config = UIImage.SymbolConfiguration(paletteColors: [
            UIColor.systemYellow, UIColor.systemYellow, UIColor.systemYellow
        ])

        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image = UIImage(systemName: "cloud.fill")
    }

    @IBAction func toggleBtn(_ sender: UISwitch) {
        if sender.isOn {
            tempInFarenheit = (tempInCelcius * 9/5) + 32
            print(tempInFarenheit)
            temperatureLabel.text = "\(tempInFarenheit) F"
        } else {
            print(tempInFarenheit)
            temperatureLabel.text = "\(tempInCelcius) C"
        }
    }

    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        print(textField.text ?? "")
        loadWeather(search: textField.text)
        return true
    }

    @IBAction func onLocationTapped(_ sender: UIButton) {
        configureLocationManager()

        let londonOntarioCoordinates = CLLocationCoordinate2D(latitude: 42.9849, longitude: -81.2453)
        let query = "\(londonOntarioCoordinates.latitude),\(londonOntarioCoordinates.longitude)"

        loadWeather(search: query)
        toggleBtn.isOn = false
    }

    @IBAction func onSearchTapped(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        loadWeather(search: searchTextField.text)
        toggleBtn.isOn = false
    }

    private func loadWeather(search: String?) {
        guard let search = search else {
            return
        }

        guard let url = getURL(query: search) else {
            return
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            if let weatherResponse = self.parseJson(data: data) {
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.location.name

                    self.tempInCelcius = weatherResponse.current.temp_c
                    self.tempInFarenheit = weatherResponse.current.temp_f
                    self.conditionTemp.text = weatherResponse.current.condition.text
                    if self.toggleBtn.isOn {
                        self.tempInFarenheit = (self.tempInCelcius * 9/5) + 32
                        self.temperatureLabel.text = "\(self.tempInFarenheit) F"
                    } else {
                        self.temperatureLabel.text = "\(self.tempInCelcius) C"
                    }

                    self.setWeatherImage(for: weatherResponse.current.condition.code)

                    
                    self.updateUI(with: weatherResponse)

                    
                    self.searchedCities.append(weatherResponse)

                    
                    self.saveSearchedCities()
                }
            }
        }
        dataTask.resume()
    }

    private func setWeatherImage(for conditionCode: Int) {
        let config = UIImage.SymbolConfiguration(paletteColors: [
            .systemTeal, .systemBlue, .systemCyan
        ])
        var imageName: String

        switch conditionCode {
        case 1000:
            imageName = "sun.max"
        case 1003, 1006, 1009, 1030:
            imageName = "cloud"
        case 1063, 1189, 1186, 1192, 1195, 1198:
            imageName = "cloud.rain"
        case 1066, 1114, 1210, 1213, 1216, 1219, 1222, 1255:
            imageName = "snowflake"
        default:
            imageName = "cloud.fill"
        }

        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image = UIImage(systemName: imageName)
    }

    private func getURL(query: String) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey = "06ee591f1f9e4e51992223105231811"

        guard let url = "\(baseURL)\(currentEndPoint)?key=\(apiKey)&q=\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
        }

        return URL(string: url)
    }

    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?

        do {
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            
        }

        return weather
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let query = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            loadWeather(search: query)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }

    
    private func saveSearchedCities() {
        do {
            let data = try JSONEncoder().encode(searchedCities)
            UserDefaults.standard.set(data, forKey: "searchedCities")
        } catch {
            
        }
    }

    
    private func loadSearchedCities() {
        if let data = UserDefaults.standard.data(forKey: "searchedCities") {
            do {
                let cities = try JSONDecoder().decode([WeatherResponse].self, from: data)
                searchedCities = cities
            } catch {
                
            }
        }
    }

    
    private func updateUI(with weatherResponse: WeatherResponse) {
        
    }

    
    @IBAction func showCitiesScreen(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let secViewController = storyboard.instantiateViewController(withIdentifier: "SecViewController") as? SecViewController {
                secViewController.searchedCities = searchedCities
                present(secViewController, animated: true, completion: nil)
            }
    }
}
