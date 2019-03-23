//
//  ViewController.swift
//  NetwinWeather
//
//  Created by kipl on 04/02/19.
//  Copyright © 2019 shilendra. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, SelectionDelegate, UIPopoverPresentationControllerDelegate  {
   
    @IBOutlet weak var tempfield: UITextField!
    @IBOutlet weak var countryfield: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searhBtn: UIButton!
    var dimView = UIView()
    let country = ["UK", "England", "Scotland", "Wales"]
    let temp = ["Tmax (max temperature)","Tmin (min temperature)", "Rainfall (mm)"]
    let baseURL = "https://s3.eu-west-2.amazonaws.com/interview-question-data/metoffice/" //{metric}-{location}.json"
    let countryTempHandler = CountryTempHandler()
    let weatherHandler = WeatherHandler()
    var weatherList = [WeatherObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Weather Data"
        dimView.frame = CGRect(x:0, y:0, width: self.view.frame.width, height: self.view.frame.height)
        dimView.backgroundColor = UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 0.5)
        tableView.dataSource = self
        tableView.delegate = self
        self.setStyling()
    }
    
    func setStyling() {
        var tap  = MyTapGesture()
        
        tap = MyTapGesture(target: self, action: #selector(self.handleTap(_:)))
        tempfield.addGestureRecognizer(tap)
        tap.value = 1
        tempfield.isUserInteractionEnabled = true
        
        tap = MyTapGesture(target: self, action: #selector(self.handleTap(_:)))
        countryfield.addGestureRecognizer(tap)
        tap.value = 2
        countryfield.isUserInteractionEnabled = true
        
//        tap = MyTapGesture(target: self, action: #selector(self.handleTap(_:)))
//        yearField.addGestureRecognizer(tap)
//        tap.value = 3
//        yearField.isUserInteractionEnabled = true
        
    }
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: MyTapGesture) {
        view.endEditing(true)
        if sender.value ==  1 {
            self.getSelectValue(values: temp, selectedTag: 1)
        }else if sender.value == 2 {
            self.getSelectValue(values: country, selectedTag: 2)
        }else if sender.value == 3 {
           // self.getSelectValue(values: country, selectedTag: 3)
        }
        
    }
    func getSelectValue(values: [String], selectedTag: Int) {
        
        let popupController = self.storyboard?.instantiateViewController(withIdentifier: "selectionview") as! SelectionView
        popupController.modalPresentationStyle = .popover
        
        //popupController.preferredContentSize = CGSize(width:300, height: 270)
        if let popoverController = popupController.popoverPresentationController
        {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX , y: self.view.bounds.midY, width:  0,height:0)
            popupController.list = values
            popupController.selectedTag = selectedTag
            popupController.setDelegate = self
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: UInt(0))
            popoverController.delegate = self
            
        }
        self.present(popupController, animated: true, completion: nil)
    }
    // Make sure you add this method of UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        
        return UIModalPresentationStyle.none
    }
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.dimView.removeFromSuperview()
        return true
    }
    
    func updateListAccordingToSelection(Value: String, selectedTag : Int) {
        self.dimView.removeFromSuperview()
        switch selectedTag {
        case 1:
            print("update list")
            self.tempfield.text =  Value
        case 2:
            print("update list")
            self.countryfield.text = Value
        case 3:
            print("update list")
            self.yearField.text = Value
        default:
            print("error")
        }
        
    }
    
    @IBAction func searchDataAction(_ sender: Any) {
        guard let temp = self.tempfield.text, temp != ""  else {
            self.showAlert(title: "Weather", message: "select temperature")
            return
        }
        let paraTemp = self.findParamerterForTemp(temp: temp)
        guard let countryName = self.countryfield.text, countryName != "" else {
            self.showAlert(title: "Weather", message: "select country")
            return
        }
        print("\(temp) \(countryName) \(self.yearField.text!)")
        if  self.yearField.text! != "" {
            self.searchDataInLocalDB(temp: paraTemp, country: countryName, year: Int(self.yearField.text!) ?? 0)
        }else {
            self.searchDataInLocalDB(temp: paraTemp, country: countryName, year: 0)
        }
        
    }
    
    
    func searchDataInLocalDB(temp: String, country: String, year: Int) {
        
        let presentInDB = self.countryTempHandler.search(temp: temp, country: country)
        if presentInDB {
            print("present in db")
            weatherList.removeAll()
         weatherList = self.weatherHandler.search(temp: temp, country: country, year: year)
            if weatherList.count > 0 {
            tableView.reloadData()
            }else {
                self.saveCountryAndTemp(temp: temp, country: country, year: year)
            }
        }else {
            print("not available")
            self.saveCountryAndTemp(temp: temp, country: country, year: year)
        }
    
      
        
    }
    private func saveCountryAndTemp(temp: String, country: String,year: Int) {
        print("working inside save coutry")
        let contTempObj = CountryTempObject()
        contTempObj.tempType = temp
        contTempObj.country = country
        self.countryTempHandler.insertAndUpdate(chatData: contTempObj)
        self.getWeatherData(temp: temp, country: country, year: year)
    }
    
    func getWeatherData(temp: String, country: String,year: Int) {
        
        let completUrl = baseURL.appending("\(temp)-\(country).json")
        print(completUrl)
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        Alamofire.request(completUrl, method: .get, headers: nil)
            .responseJSON { response in
            activityIndicator.removeFromSuperview()
                print(response)
                guard let weatherList = response.result.value as? Array<Any> else {
                    print("responce found nil")
                    return
                }
                for i in 0 ..< weatherList.count {
                    guard let weather = weatherList[i] as? Dictionary<String , AnyObject> else {
                        print("Movie data not available")
                        return
                    }
                    let weatherObj = WeatherObject()
                    if let value = weather["value"] as? Double {
                        weatherObj.value = value
                    }
                    if let year = weather["year"] as? Int {
                        weatherObj.year = year
                    }
                    if let month = weather["month"] as? Int {
                        weatherObj.month = month
                    }
                    weatherObj.tempType = temp
                    weatherObj.country = country
                    self.weatherHandler.insertAndUpdate(weatherData: weatherObj)
                    
                }
                
               self.searchDataInLocalDB(temp: temp, country: country, year: year)
            
        }
        
    }
    
    
    
    //MARK: Alert view
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
        }))
        present(alertController, animated: true, completion: nil)
    }
    
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
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        <#code#>
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        let wetherData = weatherList[indexPath.row]
        cell.textLabel?.text = "\(wetherData.value)"
        let month = self.findMonthName(monthNum: wetherData.month)
        cell.detailTextLabel?.text = "\(month) \(wetherData.year)"
        return cell
    }
    
    
    
}

class MyTapGesture: UITapGestureRecognizer {
    var value = Int()
}
