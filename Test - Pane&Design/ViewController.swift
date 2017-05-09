//
//  ViewController.swift
//  Test - Pane&Design
//
//  Created by Luca on 11/04/17.
//  Copyright © 2017 Luca Casula. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, WeatherLocationDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cityLbl: UILabel!
    
    @IBOutlet weak var degreeLbl: UILabel!
    
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var weather: Weather = Weather()
    var weatherForecast = [Weather]()
    var weatherPerDay = [Weather]()
    
    
    var forecast: Forecast?
    
    
    var isFirstLaunch: Bool = true
    let locationManager = CLLocationManager()
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        searchBar.delegate = self
        
        locationManager.delegate = self
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        self.loadForecast()
        
        if forecast == nil {
            locationManager.requestWhenInUseAuthorization()
        } else {
            
            if let forecast = self.forecast {
                
                if let interval = forecast.updatedDate?.timeIntervalSinceNow, interval > 3600 {
                    
                    print("Interval: \(interval)")
                    
                    weather.downloadData(byCity: false, completed: { 
                        self.updateForecast()
                        self.updateUI()
                    })
                } else {
                    self.weather._date = forecast.date
                    self.weather.temp = forecast.temp!
                    self.weather.city = forecast.city!
                    self.weather.locationLat = forecast.latitude
                    self.weather.locationLng = forecast.longitude
                    self.weather.iconDescr = forecast.iconRef!
                    self.weather.iconId = Int(forecast.iconId)
                    self.updateUI()
                }
                
            }
        }
        
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            self.downloadForecast(byCity: false, completed: {
                self.collectionView.reloadData()
                self.tableView.reloadData()
            })
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        

        
    }
    
    // MARK: CoreData manipulation
    func saveForecast() {
        
        print("Save: \(weather.description)")
        
        let currentForecast = Forecast(context: managedObjectContext)
        currentForecast.date = weather._date!
        currentForecast.city = weather.city
        currentForecast.latitude = weather.locationLat
        currentForecast.longitude = weather.locationLng
        currentForecast.temp = weather.temp
        currentForecast.iconRef = weather.iconDescr
        currentForecast.updatedDate = NSDate()
        currentForecast.iconId = Int64(weather.iconId)
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save data")
        }
        
    }
    
    func updateForecast() {
        
        print("Update: \(weather.description)")
        
        forecast?.date = weather._date!
        forecast?.city = weather.city
        forecast?.latitude = weather.locationLat
        forecast?.longitude = weather.locationLng
        forecast?.temp = weather.temp
        forecast?.updatedDate = NSDate()
        forecast?.iconId = Int64(weather.iconId)
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save data")
        }
    }
    
    func loadForecast() {
        let forecastRequest:NSFetchRequest<Forecast> = Forecast.fetchRequest()
        
        do {
            let tempForecast = try managedObjectContext.fetch(forecastRequest)
            print("Forecast count: \(tempForecast.count)")
            if let forecast = tempForecast.last {
                self.forecast = forecast
            }
            
        } catch {
            print("Could not load data from CoreData db: \(error.localizedDescription)")
        }
        
    }
    
    // MARK: CLLocationManager delegate methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if isFirstLaunch {
                
                if (forecast == nil) {
                    if let location = manager.location {
                        print("Found user's location: \(location)")
                        weather.locationLat = location.coordinate.latitude
                        weather.locationLng = location.coordinate.longitude
                        
                        weather.downloadData(byCity: false, completed: {
                            self.updateUI()
                            
                            if self.forecast == nil {
                                self.saveForecast()
                            }
                            
                        })
                        
                        self.downloadForecast(byCity: false) {
                            self.collectionView.reloadData()
                            self.tableView.reloadData()
                        }
                    }
                    isFirstLaunch = false
                }
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    @IBAction func showMapBtnTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "MapVCSegue", sender: nil)
        
    }
    
    
    @IBAction func myLocationBtnTapped(_ sender: Any) {
        
        if let location = locationManager.location {
            weather.locationLat = location.coordinate.latitude
            weather.locationLng = location.coordinate.longitude
            
            weather.downloadData(byCity: false, completed: {
                
                self.updateUI()
                self.updateForecast()
                
            })
            
            self.downloadForecast(byCity: false, completed: { 
                self.collectionView.reloadData()
                self.tableView.reloadData()
            })
        }
    }
    
    // MARK: WeatherLocationDelegate methods
    func didSelectLocation(lat: Double, lng: Double) {
        print("Latitide: \(lat)\nLongitude: \(lng)")
        weather.locationLat = lat
        weather.locationLng = lng
        
        weather.downloadData(byCity: false) {
            
            self.updateForecast()
            self.updateUI()
            
            self.downloadForecast(byCity: false) {
                self.collectionView.reloadData()
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapVCSegue" {
            let vc = segue.destination as! MapVC
            vc.delegate = self
        }
    }
    
    // MARK: custom methods
    func downloadForecast(byCity: Bool, completed: @escaping()-> ()) {
        
        var url: URL?
        
        if byCity {
            if weather.city != "" {
                url = URL(string: "http://api.openweathermap.org/data/2.5/forecast?q=\(weather.city)&appid=5abdd2e83c8121d39bdbb4854344dcff&units=metric")!
            }
        } else {
            if weather.locationLat != 0.0 {
                url = URL(string: "http://api.openweathermap.org/data/2.5/forecast?lat=\(weather.locationLat)&lon=\(weather.locationLng)&appid=5abdd2e83c8121d39bdbb4854344dcff&units=metric")!
            }
        }
        
        guard let newUrl = url else { return }
        
        Alamofire.request(newUrl).responseJSON { (response) in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
                print("Dict: \(dict)")
                
                if let list = dict["list"] as? [Dictionary<String, AnyObject>] {
                    
                    if list.count > 9 {
                        
                        var tempArr = [Weather]()
                        for index in 0...9 {
                            let weatherHourly = Weather()
                            
                            if let dt = list[index]["dt"] as? Double {
                                weatherHourly._date = dt
                            }
                            if let main = list[index]["main"], let temp = main["temp"] as? Double {
                                
                                weatherHourly.temp = String(format: "%.f ºC", temp)
                            }
                            if let weatherList = list[index]["weather"] as? [Dictionary<String, AnyObject>] {
                                let weather = weatherList.first
                                
                                if let iconId = weather?["id"] as? Int {
                                    if iconId == 800 {
                                        weatherHourly.iconDescr = "Image1"
                                    } else if iconId >= 200 && iconId <= 232 {
                                        weatherHourly.iconDescr = "Image5"
                                    } else if iconId >= 300 && iconId <= 321 {
                                        weatherHourly.iconDescr = "Image6"
                                    } else if iconId >= 500 && iconId <= 531 {
                                        weatherHourly.iconDescr = "Image6"
                                    } else if iconId >= 600 && iconId <= 622 {
                                        weatherHourly.iconDescr = "Image7"
                                    } else if iconId >= 801 && iconId <= 802 {
                                        weatherHourly.iconDescr = "Image7"
                                    } else if iconId >= 803 && iconId <= 804 {
                                        weatherHourly.iconDescr = "Image2"
                                    } else {
                                        
                                        weatherHourly.iconDescr = "Image2"
                                        
                                    }
                                    
                                }
                            }
                            
                            tempArr.append(weatherHourly)
                        }
                        
                        var tempDayArr = [Weather]()
                        for i in stride(from: 0, to: list.count, by: 8) {
                            let weatherDaily = Weather()
                            
                            if let dt = list[i]["dt"] as? Double {
                                weatherDaily._date = dt
                            }
                            if let main = list[i]["main"], let temp = main["temp"] as? Double, let tempMin = main["temp_min"] as? Double, let tempMax = main["temp_max"] as? Double {
                                weatherDaily.temp = String(format: "%.f ºC", temp)
                                weatherDaily.tempMin = String(format: "%.f ºC", tempMin)
                                weatherDaily.tempMax = String(format: "%.f ºC", tempMax)
                                
                            }
                            if let weatherList = list[i]["weather"] as? [Dictionary<String, AnyObject>] {
                                let weather = weatherList.first
                                
                                if let iconId = weather?["id"] as? Int {
                                    if iconId == 800 {
                                        weatherDaily.iconDescr = "Image1"
                                    } else if iconId >= 200 && iconId <= 232 {
                                        weatherDaily.iconDescr = "Image5"
                                    } else if iconId >= 300 && iconId <= 321 {
                                        weatherDaily.iconDescr = "Image6"
                                    } else if iconId >= 500 && iconId <= 531 {
                                        weatherDaily.iconDescr = "Image6"
                                    } else if iconId >= 600 && iconId <= 622 {
                                        weatherDaily.iconDescr = "Image7"
                                    } else if iconId >= 801 && iconId <= 802 {
                                        weatherDaily.iconDescr = "Image7"
                                    } else if iconId >= 803 && iconId <= 804 {
                                        weatherDaily.iconDescr = "Image2"
                                    } else {
                                        
                                        weatherDaily.iconDescr = "Image2"
                                        
                                    }
                                    
                                }
                            }
                            
                            
                            tempDayArr.append(weatherDaily)
                        }
                        
                        self.weatherPerDay = tempDayArr
                        self.weatherForecast = tempArr
                        print("Count: \(self.weatherForecast.count)")
                    }
                    
                }
            }
            
            completed()
        }
        
    }
    
    func updateUI() {
        self.degreeLbl.text = "\(self.weather.temp)"
        self.cityLbl.text = self.weather.city
        self.timeLbl.text = self.weather.dateFull
        
        // snow
        // storm
        // sun
        // windy
        
        if weather.iconId != 0 {
            if weather.iconId >= 600 && weather.iconId <= 622 {
                self.bgImageView.image = UIImage(named: "Snow")
            }
            if weather.iconId == 800 {
                self.bgImageView.image = UIImage(named: "Sun")
            } else if weather.iconId >= 200 && weather.iconId <= 232 {
                self.bgImageView.image = UIImage(named: "Storm")
            } else if weather.iconId >= 300 && weather.iconId <= 321 {
                self.bgImageView.image = UIImage(named: "Storm")
            } else if weather.iconId >= 500 && weather.iconId <= 531 {
                self.bgImageView.image = UIImage(named: "Storm")
            } else if weather.iconId >= 600 && weather.iconId <= 622 {
                self.bgImageView.image = UIImage(named: "Snow")
            } else if weather.iconId >= 801 && weather.iconId <= 802 {
                self.bgImageView.image = UIImage(named: "Windy")
            } else if weather.iconId >= 803 && weather.iconId <= 804 {
                self.bgImageView.image = UIImage(named: "Windy")
            } else {
                self.bgImageView.backgroundColor = .blue
            }
        } else {
            print("IconID is 0")
        }
        
    }
    
    // MARK: UISearchBar delegate methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print("Search: \(String(describing: searchBar.text))")
        
        if let key = searchBar.text, key != "" {
            weather.city = key
            
            weather.downloadData(byCity: true) {
                self.updateUI()
                self.updateForecast()
            }
            self.downloadForecast(byCity: true) {
                self.collectionView.reloadData()
                self.tableView.reloadData()
            }
        }
        
        
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    // MARK: UITableView delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherPerDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayWeatherCell") as! DayWeatherCell
        cell.configureCell(weather: weatherPerDay[indexPath.row])
        
        return cell
    }
    
    // MARK: UICollectionView delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourWeatherCell", for: indexPath) as! HourWeatherCell
        
        cell.configureCell(weather: weatherForecast[indexPath.item])
        return cell
    }
    
    
}

