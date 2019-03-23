//
//  Support.swift
//  CoditasWeather
//
//  Created by Shailendra Barewar on 23/03/19.
//  Copyright © 2019 Shailendra. All rights reserved.
//

import Foundation

 class Support : NSObject {
    
    func findParamerterForTemp(temp: String) -> String{
        
        switch temp {
        case "Tmax (max temperature)":
            return "Tmax"
        case "Tmin (min temperature)":
            return "Tmin"
        case "Rainfall (mm)":
            return "Rainfall"
        default:
            return ""
        }
    }
    func findMonthName(monthNum: Int) -> String{
        switch monthNum {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
            
        default:
            return "N/A"
        }
    }

}
