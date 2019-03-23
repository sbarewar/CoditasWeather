//
//  SelectionView.swift
//  CoditasWeather
//
//  Created by kipl on 23/03/19.
//  Copyright © 2019 shilendra. All rights reserved.
//

import UIKit

protocol SelectionDelegate  {
    func updateListAccordingToSelection(Value : String, selectedTag: Int)
}

class SelectionView: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var selectionTable: UITableView!
    var setDelegate : SelectionDelegate?
    var list : [String] = []
    var selectedTag : Int = 0
    var titleValue : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.topItem?.title = titleValue
        selectionTable.delegate = self
        selectionTable.dataSource = self
        selectionTable.reloadData()
    }
    
}
//MARK:- Table view Methods
extension SelectionView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = selectionTable.dequeueReusableCell(withIdentifier: "selectionCell", for: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text  = list[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectString = list[indexPath.row]
        setDelegate?.updateListAccordingToSelection(Value: selectString, selectedTag: selectedTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
