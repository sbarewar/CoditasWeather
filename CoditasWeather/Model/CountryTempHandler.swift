//
//  CountryTempHandler.swift
//  NetwinWeather
//
//  Created by kipl on 04/02/19.
//  Copyright © 2019 shilendra. All rights reserved.
//

import Foundation
import RealmSwift

class CountryTempHandler {
    
    let realm = try! Realm()
    
    func insertAndUpdate(chatData : CountryTempObject) {
        
        do {
            try realm.write {
                realm.add(chatData, update: false)
            }
        } catch {
            post(error)
            
        }
    }
    func search(temp : String, country: String) -> Bool {
        
        let predicateOne = NSPredicate(format: "tempType CONTAINS[cd] %@","\(temp)")
        let predicateTwo = NSPredicate(format: "country CONTAINS[cd] %@","\(country)")
        let combinePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicateOne, predicateTwo])
        
        let details = realm.objects(CountryTempObject.self).filter(combinePredicate)
        if details.count > 0
        {
            return true
        }else {
            return false
        }
        
    }
    
    func delete() {
        
        let details = realm.objects(CountryTempObject.self)
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
