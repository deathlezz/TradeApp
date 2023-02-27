//
//  DistanceUnitView.swift
//  TradeApp
//
//  Created by deathlezz on 25/02/2023.
//

import UIKit

class DistanceUnitView: UITableViewController {
    
    let sections = ["Segment", "Unit"]
    
    var segment: SegmentedControlCell!
    var unit: UITableViewCell!
    
    var currentUnit: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Distance"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        
        DispatchQueue.global().async { [weak self] in
            self?.currentUnit = Utilities.loadDistanceUnit()
            
            DispatchQueue.main.async {
                self?.updateSegment()
            }
        }

    }
    
    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // set header title for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentedCell", for: indexPath) as? SegmentedControlCell {
            if sections[indexPath.section] == "Segment" {
                cell.selectionStyle = .none
                cell.segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
                cell.segment.addTarget(self, action: #selector(handleSegmentChange), for: .primaryActionTriggered)
                segment = cell
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DistanceUnitCell", for: indexPath)
        cell.selectionStyle = .none
        unit = cell
        return cell
    }
    
    // set action for segment change
    @objc func handleSegmentChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.transition(with: unit, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.unit.textLabel?.text = "1 mi = 1.609 km"
            }) { finished in
                self.setDistanceUnit("mi")
            }
            
        } else {
            UIView.transition(with: unit, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.unit.textLabel?.text = "1 km = 0.621 mi"
            }) { finished in
                self.setDistanceUnit("km")
            }
        }
    }
    
    // set distance measurement unit
    func setDistanceUnit(_ unit: String) {
        let defaults = UserDefaults.standard
        defaults.set(unit, forKey: "DistanceUnit")
    }
    
    // set segment control index
    func updateSegment() {
        if currentUnit == "mi" {
            segment.segment.selectedSegmentIndex = 0
            unit.textLabel?.text = "1 mi = 1.609 km"
        } else {
            segment.segment.selectedSegmentIndex = 1
            unit.textLabel?.text = "1 km = 0.621 mi"
        }
    }

}
