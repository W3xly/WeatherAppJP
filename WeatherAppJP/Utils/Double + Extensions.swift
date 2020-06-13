//
//  Double + Extensions.swift
//  WeatherAppJP
//
//  Created by Johana Šlechtová on 11/06/2020.
//  Copyright © 2020 Jan Podmolík. All rights reserved.
//

import Foundation

extension Double {
    
    func toString() -> String {
        String(format: "%.1f", self)
    }
}
