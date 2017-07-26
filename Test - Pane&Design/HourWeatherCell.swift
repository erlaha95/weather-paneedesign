//
//  HourWeatherCell.swift
//  Test - Pane&Design
//
//  Created by Yerlan Ismailov on 07.05.17.
//  Copyright © 2017 Luca Casula. All rights reserved.
//

import UIKit

class HourWeatherCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var degreeLbl: UILabel!
    
    static let defaultReuseIdentifier = "HourWeatherCell"
    
    func configureCell(weather: Weather) {
        
        self.timeLbl.text = weather.dateShort
        self.iconImageView.image = UIImage(named: weather.iconDescr)
        self.degreeLbl.text = weather.temp
    }
    
    
}
