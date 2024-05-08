//
//  SecViewController.swift
//  Weather-Lab3
//
//  Created by Anand Krishna Shiju on 2023-12-09.
//

import UIKit

class SecViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    var searchedCities: [WeatherResponse] = []

    @IBOutlet weak var citiesTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        citiesTableView.dataSource = self
        citiesTableView.delegate = self

        
        citiesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cityCell")

        
        loadSearchedCities()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedCities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)

        
        let weather = searchedCities[indexPath.row]
        
        var local = cell.defaultContentConfiguration()
        local.text = weather.location.name
        local.secondaryText = "\(weather.current.temp_c)"
        cell.contentConfiguration = local
        


        
        let config = UIImage.SymbolConfiguration(paletteColors: [
            .systemTeal, .systemBlue, .systemCyan
        ])
        var imageName: String

        switch weather.current.condition.code {
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

        let weatherImageView = UIImageView(image: UIImage(systemName: imageName))
        weatherImageView.preferredSymbolConfiguration = config
        cell.accessoryView = weatherImageView

        return cell
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    private func loadSearchedCities() {
            if let data = UserDefaults.standard.data(forKey: "searchedCities") {
                do {
                    searchedCities = try JSONDecoder().decode([WeatherResponse].self, from: data)
                    citiesTableView.reloadData()
                } catch {
                    // Handle decoding error
                    print("Error decoding searchedCities:", error)
                }
            }
        }
    
}
