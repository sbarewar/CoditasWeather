//
//  CountryTempObject.swift
//  CoditasWeather
//
//  Created by kipl on 23/03/19.
//  Copyright © 2019 shilendra. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class CountryTempObject: Object {
    
    dynamic var tempType : String = ""
    dynamic var country : String = ""
}
