//
//  FilterView.swift
//  TradeApp
//
//  Created by deathlezz on 22/11/2022.
//

import UIKit
import CoreLocation

class FilterView: UITableViewController {
    
    var radiusStages = [0, 1, 2, 3, 4, 5, 10, 15, 20, 25, 50, 75, 100, 125, 150, 175, 200]
    var radiusCounter = 0
    
    var currentUnit: String!
    
    var categories = [String]()
    var currentFilters = [String: String]()
    
    var filterCells = [FilterCell]()
    var priceCell: PriceCell!
    var radiusCell: RadiusCell!
    
    let sections = ["Sort", "Category", "Location", "Price", "Button"]
    
    var applyButton: UIBarButtonItem!
    var clearButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 20
        
        title = "Filter"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRadius), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        DispatchQueue.global().async { [weak self] in
            self?.currentUnit = Utilities.loadDistanceUnit()
            self?.currentFilters = Utilities.loadFilters()
            self?.radiusCounter = Int(self?.currentFilters["Radius"] ?? "0") ?? 0
        }
    }

    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 2 ? 2 : 1
    }
    
    // set table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
        let label = UILabel()
        
        if section == 0 {
            label.frame = CGRect.init(x: 20, y: 11, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        } else if section == 3 {
            label.frame = CGRect.init(x: 20, y: -19, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        } else {
            label.frame = CGRect.init(x: 20, y: -20, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        }
        
        label.text = section == 4 ? " " : sections[section]
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .systemGray
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    // set section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 45 : 15
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as? FilterCell {
            switch sections[indexPath.section] {
            case "Sort":
                cell.filterTextField.placeholder = "None"
                cell.filterTextField.text = currentFilters["Sort"]
                cell.filterTextField.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                filterCells.append(cell)
                return cell
            case "Category":
                cell.filterTextField.placeholder = "None"
                cell.filterTextField.text = currentFilters["Category"]
                cell.filterTextField.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                filterCells.append(cell)
                return cell
            case "Location":
                if indexPath.row == 0 {
                    cell.filterTextField.placeholder = "None"
                    cell.filterTextField.text = currentFilters["Location"]
                    cell.filterTextField.clearButtonMode = .whileEditing
                    cell.selectionStyle = .none
                    cell.filterTextField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                    filterCells.append(cell)
                    return cell
                }
            default:
                break
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "radiusCell", for: indexPath) as? RadiusCell {
            if sections[indexPath.section] == "Location" {
                if indexPath.row == 1 {
                    cell.radiusLabel.text = "+ \(radiusStages[radiusCounter]) \(currentUnit!)"
                    cell.minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
                    cell.plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
                    cell.selectionStyle = .none
                    radiusCell = cell
                    return cell
                }
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as? PriceCell {
            if sections[indexPath.section] == "Price"{
                cell.firstTextField.placeholder = "From"
                cell.firstTextField.text = currentFilters["PriceFrom"]
                cell.firstTextField.clearButtonMode = .whileEditing
                cell.secondTextField.placeholder = "To"
                cell.secondTextField.text = currentFilters["PriceTo"]
                cell.secondTextField.clearButtonMode = .whileEditing
                cell.selectionStyle = .none
                priceCell = cell
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as? ButtonCell {
            if sections[indexPath.section] == "Button" {
                cell.selectionStyle = .none
                cell.submitButton.setTitle("Apply", for: .normal)
                cell.submitButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sections[indexPath.section] == "Sort" {
            let ac = UIAlertController(title: "Sort items by", message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "Lowest price", style: .default) { [weak self] _ in
                self?.filterCells[0].filterTextField.text = "Lowest price"
            })
            ac.addAction(UIAlertAction(title: "Highest price", style: .default) { [weak self] _ in
                self?.filterCells[0].filterTextField.text = "Highest price"
            })
            ac.addAction(UIAlertAction(title: "Date added", style: .default) { [weak self] _ in
                self?.filterCells[0].filterTextField.text = "Date added"
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
            
        } else if sections[indexPath.section] == "Category" {
            let ac = UIAlertController(title: "Categories", message: nil, preferredStyle: .actionSheet)
            for category in categories {
                ac.addAction(UIAlertAction(title: category, style: .default) { [weak self] _ in
                    self?.filterCells[1].filterTextField.text = category
                })
            }
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }

        updateRadius()
    }
    
    // set action for apply button
    @objc func applyTapped() {
        updateRadius()
        
        let categoryText = filterCells[1].filterTextField.text ?? ""
        let locationText = filterCells[2].filterTextField.text?.capitalized ?? ""
        var priceFrom = priceCell.firstTextField.text ?? ""
        var priceTo = priceCell.secondTextField.text ?? ""
        let sortText = filterCells[0].filterTextField.text ?? ""
        let radius = radiusStages[radiusCounter]
        
        if currentFilters["Search"] != nil && currentFilters["Category"] != nil {
            Storage.shared.filteredItems = Storage.shared.items.filter {$0.category == currentFilters["Category"]}
            Storage.shared.filteredItems = Storage.shared.filteredItems.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
        } else if currentFilters["Search"] != nil {
            Storage.shared.filteredItems = Storage.shared.items.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
        } else if currentFilters["Category"] != nil {
            Storage.shared.filteredItems = Storage.shared.items.filter {$0.category == currentFilters["Category"]}
        }
        
        // category filter
        if !categoryText.isEmpty {
            if categoryText == categories[0] && currentFilters["Search"] != nil {
                Storage.shared.filteredItems = Storage.shared.items.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
            } else if categoryText == categories[0] && currentFilters["Search"] == nil {
                Storage.shared.filteredItems = Storage.shared.items
            } else if categoryText != categories[0] && currentFilters["Search"] != nil {
                Storage.shared.filteredItems = Storage.shared.items.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
                Storage.shared.filteredItems = Storage.shared.filteredItems.filter {$0.category == categoryText}
            } else if categoryText != categories[0] && currentFilters["Search"] == nil {
                Storage.shared.filteredItems = Storage.shared.items.filter {$0.category == categoryText}
            }

            currentFilters["Category"] = categoryText
        } else {
            currentFilters["Search"] = nil
            currentFilters["Category"] = nil
        }
        
        // price filter
        if !priceFrom.isEmpty && !priceTo.isEmpty {
            if Int(priceFrom)! > Int(priceTo)! {
                (priceFrom, priceTo) = (priceTo, priceFrom)
            }
            
            Storage.shared.filteredItems = Storage.shared.filteredItems.filter {$0.price >= Int(priceFrom)! && $0.price <= Int(priceTo)!}
            currentFilters["PriceFrom"] = priceFrom
            currentFilters["PriceTo"] = priceTo
        } else if !priceFrom.isEmpty {
            Storage.shared.filteredItems = Storage.shared.filteredItems.filter {$0.price >= Int(priceFrom)!}
            currentFilters["PriceFrom"] = priceFrom
            currentFilters["PriceTo"] = nil
        } else if !priceTo.isEmpty {
            Storage.shared.filteredItems = Storage.shared.filteredItems.filter {$0.price <= Int(priceTo)!}
            currentFilters["PriceTo"] = priceTo
            currentFilters["PriceFrom"] = nil
        } else {
            currentFilters["PriceFrom"] = nil
            currentFilters["PriceTo"] = nil
        }
        
        // sort filter
        if !sortText.isEmpty {
            if sortText == "Lowest price" {
                Storage.shared.filteredItems.sort(by: {$0.price < $1.price})
            } else if sortText == "Highest price" {
                Storage.shared.filteredItems.sort(by: {$0.price > $1.price})
            } else if sortText == "Date added" {
                Storage.shared.filteredItems.sort(by: {$0.date < $1.date})
            }
            
            currentFilters["Sort"] = sortText
        } else {
            currentFilters["Sort"] = nil
        }
        
        // reset filters
        if currentFilters["Category"] == nil && currentFilters["Search"] == nil {
            Storage.shared.filteredItems = Storage.shared.recentlyAdded
            currentFilters.removeAll()
            Utilities.saveFilters(currentFilters)
            navigationController?.popToRootViewController(animated: true)
            return
        }
        
        // location filter
        if !locationText.isEmpty {
            var matched = [Item]()
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            Utilities.isCityValid(locationText) { [weak self] valid in
                if valid {
                    Utilities.forwardGeocoding(address: locationText) { (lat, long) in
                        let cityLocation = CLLocation(latitude: lat, longitude: long)
                        
                        var unit: Double
                        
                        if self?.currentUnit == "mi" {
                            unit = 1609
                        } else {
                            unit = 1000
                        }
                        
                        for item in Storage.shared.filteredItems {
                            
                            let itemLocation = CLLocation(latitude: item.lat, longitude: item.long)
                            let distance = Int(cityLocation.distance(from: itemLocation) / unit)
                            
                            if Int(distance) <= radius {
                                matched.append(item)
                            }
                        }
                        
                        dispatchGroup.leave()
                    }
                    
                } else {
                    let ac = UIAlertController(title: "Wrong city name", message: "Please enter valid city name", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ac, animated: true)
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                Storage.shared.filteredItems = matched
                self.currentFilters["Location"] = locationText
                self.currentFilters["Radius"] = String(self.radiusCounter)
                
                Utilities.saveFilters(self.currentFilters)
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        } else {
            currentFilters["Location"] = nil
            currentFilters["Radius"] = nil
            
            Utilities.saveFilters(currentFilters)
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // set action for clear button
    @objc func clearTapped() {
        for cell in filterCells {
            cell.filterTextField.text = nil
        }
        
        priceCell.firstTextField.text = nil
        priceCell.secondTextField.text = nil
        updateUnit()
        radiusCounter = 0
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped(_ textField: UITextField) {
        if filterCells[2].filterTextField.text == "" {
            updateUnit()
            radiusCounter = 0
        }
        
        textField.resignFirstResponder()
    }
    
    // set "done" button for numeric keyboard
    func addDoneButtonToKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        let items = [spacer, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        priceCell.firstTextField.inputAccessoryView = doneToolbar
        priceCell.secondTextField.inputAccessoryView = doneToolbar
    }
    
    // add "done" button after view appeard
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addDoneButtonToKeyboard()
    }
    
    // set action for "done" button
    @objc func doneTapped() {
        if priceCell.firstTextField.isEditing {
            priceCell.firstTextField.resignFirstResponder()
        } else {
            priceCell.secondTextField.resignFirstResponder()
        }
    }
    
    // set action for tapped minus button
    @objc func minusTapped() {
        guard filterCells[2].filterTextField.text != "" else { return }
        
        radiusCounter -= 1
        
        if radiusCounter < 0 {
            radiusCounter = 0
        }
        
        if currentUnit == "mi" {
            radiusCell.radiusLabel.text = "+ \(radiusStages[radiusCounter]) mi"
        } else {
            radiusCell.radiusLabel.text = "+ \(radiusStages[radiusCounter]) km"
        }
        
    }
    
    // set action for tapped plus button
    @objc func plusTapped() {
        guard filterCells[2].filterTextField.text != "" else { return }
        
        radiusCounter += 1
        
        if radiusCounter > 16 {
            radiusCounter = 16
        }
        
        if currentUnit == "mi" {
            radiusCell.radiusLabel.text = "+ \(radiusStages[radiusCounter]) mi"
        } else {
            radiusCell.radiusLabel.text = "+ \(radiusStages[radiusCounter]) km"
        }
    }
    
    // update radius
    @objc func updateRadius() {
        if filterCells[2].filterTextField.text == "" {
            updateUnit()
            
            radiusCounter = 0
        }
    }
    
    // update distance unit
    func updateUnit() {
        if currentUnit == "mi" {
            radiusCell.radiusLabel.text = "+ 0 mi"
        } else {
            radiusCell.radiusLabel.text = "+ 0 km"
        }
    }

}
