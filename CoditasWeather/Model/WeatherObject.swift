//
//  WeatherObject.swift
//  NetwinWeather
//
//  Created by kipl on 04/02/19.
//  Copyright © 2019 shilendra. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class WeatherObject: Object {
    
    dynamic var value : Double = 0
    dynamic var year : Int = 0
    dynamic var month : Int = 0
    dynamic var tempType : String = ""
    dynamic var country : String = ""
}

