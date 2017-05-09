//
//  Weather.swift
//  Test - Pane&Design
//
//  Created by Yerlan Ismailov on 08.05.17.
//  Copyright © 2017 Luca Casula. All rights reserved.
//

import UIKit
import Alamofire

class Weather: NSObject {
    
    private var _temp: String?
    private var _tempMin: String?
    private var _tempMax: String?
    
    public var _date: Double?
    private var _city: String?
    private var _locationLat: Double?
    private var _locationLng: Double?
    private var _location: String?
    private var _weather: String?
    private var _iconDescr: String?
    
    private var _iconId: Int?
    
    var url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=Almaty&appid=5abdd2e83c8121d39bdbb4854344dcff&units=metric")
    
    func downloadData(byCity: Bool, completed: @escaping ()-> ()) {
        
        if byCity {
            if let newCity = _city {
                url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(newCity)&appid=5abdd2e83c8121d39bdbb4854344dcff&units=metric")
            }
        } else {
            if let lat = _locationLat, lat != 0.0, let lng = _locationLng, lng != 0.0 {
                url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lng)&appid=5abdd2e83c8121d39bdbb4854344dcff&units=metric")
            }
        }
        
        Alamofire.request(url!).responseJSON(completionHandler: {
            response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject>, let main = dict["main"] as? Dictionary<String, AnyObject>, let temp = main["temp"] as? Double, let weatherArray = dict["weather"] as? [Dictionary<String, AnyObject>], let weather = weatherArray[0]["main"] as? String, let name = dict["name"] as? String, let sys = dict["sys"] as? Dictionary<String, AnyObject>, let country = sys["country"] as? String, let dt = dict["dt"] as? Double, let city = dict["name"] as? String {
                
                
                self._temp = String(format: "%.f °C", temp)
                
                self._weather = weather
                self._location = "\(name), \(country)"
                self._date = dt
                self._city = city
                
                if let weatherArr = dict["weather"] as? [Dictionary<String, AnyObject>], let weatherDict = weatherArr.first, let iconId = weatherDict["id"] as? Int {
                
                    self._iconId = iconId
                    
                    if iconId == 800 {
                        
                        //Group 800: Clear
                        self._iconDescr = "Image1"
                    } else if iconId >= 200 && iconId <= 232 {
                        
                        //Group 2xx: Thunderstorm
                        self._iconDescr = "Image5"
                    } else if iconId >= 300 && iconId <= 321 {
                        
                        //Group 3xx: Drizzle
                        self._iconDescr = "Image6"
                    } else if iconId >= 500 && iconId <= 531 {
                        
                        //Group 5xx: Rain
                        self._iconDescr = "Image6"
                    } else if iconId >= 600 && iconId <= 622 {
                        
                        //Group 6xx: Snow
                        self._iconDescr = "Image7"
                    } else if iconId >= 801 && iconId <= 802 {
                        
                        // Group 80x: Clouds - scattered clouds
                        self._iconDescr = "Image7"
                    } else if iconId >= 803 && iconId <= 804 {
                        
                        // Group 80x: Clouds - broken clouds
                        self._iconDescr = "Image2"
                    } else {
                        
                        // default
                        self._iconDescr = "Image2"
                        
                    }
                    
                    
                }
                
                
            }
            
            completed()
        })
    }
    
    var iconId: Int {
        return _iconId ?? 0
    }
    
    var locationLat: Double {
        
        set(newLat) {
            _locationLat = newLat
        }
        get {
            return _locationLat ?? 0.0
        }
        
    }
    
    var locationLng: Double {
        set(newLng) {
            _locationLng = newLng
        }
        get {
            return _locationLng ?? 0.0
        }
    }
    
    var dateFull: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        let date = Date(timeIntervalSince1970: _date!)
        
        print("Date: \(String(describing: _date))")
        
        return "Today, \(dateFormatter.string(from: date))"
        
        
    }
    
    var dateShort: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        let date = Date(timeIntervalSince1970: _date!)
        
        print("Time: \(String(describing: _date))")
        
        return "\(dateFormatter.string(from: date))"
        
        
    }
    
    var temp: String {
        set (newTemp) {
            _temp = newTemp
        }
        get {
            return _temp ?? "0 ºC"
        }
    }
    
    var tempMin: String {
        set (newTemp) {
            _tempMin = newTemp
        }
        get {
            return _tempMin ?? "0 ºC"
        }
    }
    
    var tempMax: String {
        set (newTemp) {
            _tempMax = newTemp
        }
        get {
            return _tempMax ?? "0 ºC"
        }
    }
    
    var city: String {
        get {
            return _city ?? "Undefined"
        }
        set(newCity) {
            _city = newCity
        }
    }
    
    var iconDescr: String {
        set (newIconDescr) {
            self._iconDescr = newIconDescr
        }
        get {
            return _iconDescr ?? "default"
        }
        
    }
}
