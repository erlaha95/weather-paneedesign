//
//  DayWeatherCell.swift
//  Test - Pane&Design
//
//  Created by Yerlan Ismailov on 07.05.17.
//  Copyright © 2017 Luca Casula. All rights reserved.
//

import UIKit

class DayWeatherCell: UITableViewCell {

    @IBOutlet weak var dayLbl: UILabel!
    
    @IBOutlet weak var degreesLbl: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    static let defaultReuseIdentifier = "DayWeatherCell"
    
    let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(weather: Weather) {
        
        self.degreesLbl.text = "\(weather.tempMin) | \(weather.tempMax)"
        self.iconImageView.image = UIImage(named: weather.iconDescr)
        
        
        let index = getDayOfWeek(weather._date!)
        print("Day index: \(String(describing: index))")
        
        self.dayLbl.text = weekDays[index! - 1]
        
    }
    
    func getDayOfWeek(_ today:Double) -> Int? {
        
        //guard let todayDate = Date(timeIntervalSince1970: today) else { return nil }
        let todayDate = Date(timeIntervalSince1970: today)
        let myCalendar = Calendar(identifier: .gregorian)
        
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }

}
