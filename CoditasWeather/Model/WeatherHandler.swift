//
//  WeatherHandler.swift
//  CoditasWeather
//
//  Created by kipl on 23/03/19.
//  Copyright © 2019 shilendra. All rights reserved.
//

import Foundation
import RealmSwift

class WeatherHandler {
    
    let realm = try! Realm()
    
    func insertAndUpdate(weatherData : WeatherObject) {
        
        do {
            try realm.write {
                realm.add(weatherData, update: false)
            }
        } catch {
            post(error)
            
        }
    }
    func search(temp: String, country: String, year: Int) -> [WeatherObject] {
        var listOfWeather = [WeatherObject]()
        var combinePredicate = NSCompoundPredicate()
        if year != 0 {
            let predicateOne = NSPredicate(format: "tempType CONTAINS[cd] %@","\(temp)")
            let predicateTwo = NSPredicate(format: "country CONTAINS[cd] %@","\(country)")
            let predicateThree = NSPredicate(format: "year == %i",year)
            combinePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateOne, predicateTwo, predicateThree])
        }else {
            let predicateOne = NSPredicate(format: "tempType CONTAINS[cd] %@","\(temp)")
            let predicateTwo = NSPredicate(format: "country CONTAINS[cd] %@","\(country)")
            combinePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateOne, predicateTwo])
        }
        print(combinePredicate)
        let weatherList = realm.objects(WeatherObject.self).filter(combinePredicate)
        if weatherList.count > 0
        {
            listOfWeather.removeAll()
            for data in weatherList {
                 let weatherObj = WeatherObject()
                weatherObj.country = data.country
                weatherObj.tempType = data.tempType
                weatherObj.value = data.value
                weatherObj.month = data.month
                weatherObj.year = data.year
                listOfWeather.append(weatherObj)
            }
        }
        return listOfWeather
    }
    func delete() {
        
        let details = realm.objects(WeatherObject.self)
        if details.count > 0
        {
            for data in details
            {
                do {
                    try realm.write {
                        realm.delete(data)
                    }
                }catch {
                    post(error)
                }
            }
        }
    }

    func post(_ error: Error) {
        NotificationCenter.default.post(name: NSNotification.Name("RealmError"), object: error)
    }
    
    func observeRealmErrors(in vc: UIViewController, completion: @escaping (Error?) -> Void) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("RealmError"),
                                               object: nil,
                                               queue: nil) { (notification) in
                                                completion(notification.object as? Error)
        }
    }
    
    func stopObservingErrors(in vc: UIViewController) {
        NotificationCenter.default.removeObserver(vc, name: NSNotification.Name("RealmError"), object: nil)
    }
}
