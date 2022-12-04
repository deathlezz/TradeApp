//
//  FilterView.swift
//  TradeApp
//
//  Created by deathlezz on 22/11/2022.
//

import UIKit

class FilterView: UITableViewController {
    
    var categories = [String]()
    var currentFilters = [String: String]()
    
    var filterCells = [FilterCell]()
    var priceCell: PriceCell!
    
    let sectionTitles = ["Sort", "Category", "Location", "Price", "Button"]
    
    var applyButton: UIBarButtonItem!
    var clearButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        title = "Filter"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        
        DispatchQueue.global().async { [weak self] in
            self?.currentFilters = Utilities.loadFilters()
        }
    }

    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // set title for every section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 4 ? " " : sectionTitles[section]
    }

    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath) as? FilterCell {
            switch sectionTitles[indexPath.section] {
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
                cell.filterTextField.placeholder = "None"
                cell.filterTextField.text = currentFilters["Location"]
                cell.filterTextField.clearButtonMode = .whileEditing
                cell.selectionStyle = .none
                cell.filterTextField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                filterCells.append(cell)
                return cell
            default:
                break
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as? PriceCell {
            if sectionTitles[indexPath.section] == "Price"{
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
            if sectionTitles[indexPath.section] == "Button" {
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
        if sectionTitles[indexPath.section] == "Sort" {
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
            
        } else if sectionTitles[indexPath.section] == "Category" {
            let ac = UIAlertController(title: "Categories", message: nil, preferredStyle: .actionSheet)
            for category in categories {
                ac.addAction(UIAlertAction(title: category, style: .default) { [weak self] _ in
                    self?.filterCells[1].filterTextField.text = category
                })
            }
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    // set action for apply button
    @objc func applyTapped() {
        let categoryText = filterCells[1].filterTextField.text ?? ""
        let locationText = filterCells[2].filterTextField.text ?? ""
        var priceFrom = priceCell.firstTextField.text ?? ""
        var priceTo = priceCell.secondTextField.text ?? ""
        let sortText = filterCells[0].filterTextField.text ?? ""
        
        if currentFilters["Search"] != nil && currentFilters["Category"] != nil {
            filteredItems = items.filter {$0.category == currentFilters["Category"]}
            filteredItems = filteredItems.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
        } else if currentFilters["Search"] != nil {
            filteredItems = items.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
        } else if currentFilters["Category"] != nil {
            filteredItems = items.filter {$0.category == currentFilters["Category"]}
        }
        
        // category filter
        if !categoryText.isEmpty {
            if categoryText == categories[0] && currentFilters["Search"] != nil {
                filteredItems = items.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
            } else if categoryText == categories[0] && currentFilters["Search"] == nil {
                filteredItems = items
            } else if categoryText != categories[0] && currentFilters["Search"] != nil {
                filteredItems = items.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
                filteredItems = filteredItems.filter {$0.category == categoryText}
            } else if categoryText != categories[0] && currentFilters["Search"] == nil {
                filteredItems = items.filter {$0.category == categoryText}
            }

            currentFilters["Category"] = categoryText
        } else {
            currentFilters["Search"] = nil
            currentFilters["Category"] = nil
        }
        
        // location filter
        if !locationText.isEmpty {
            filteredItems = filteredItems.filter {$0.location == locationText}
            currentFilters["Location"] = locationText
        } else {
            currentFilters["Location"] = nil
        }
        
        // price filter
        if !priceFrom.isEmpty && !priceTo.isEmpty {
            if Int(priceFrom)! > Int(priceTo)! {
                (priceFrom, priceTo) = (priceTo, priceFrom)
            }
            
            filteredItems = filteredItems.filter {$0.price >= Int(priceFrom)! && $0.price <= Int(priceTo)!}
            currentFilters["PriceFrom"] = priceFrom
            currentFilters["PriceTo"] = priceTo
        } else if !priceFrom.isEmpty {
            filteredItems = filteredItems.filter {$0.price >= Int(priceFrom)!}
            currentFilters["PriceFrom"] = priceFrom
            currentFilters["PriceTo"] = nil
        } else if !priceTo.isEmpty {
            filteredItems = filteredItems.filter {$0.price <= Int(priceTo)!}
            currentFilters["PriceTo"] = priceTo
            currentFilters["PriceFrom"] = nil
        } else {
            currentFilters["PriceFrom"] = nil
            currentFilters["PriceTo"] = nil
        }
        
        // sort filter
        if !sortText.isEmpty {
            if sortText == "Lowest price" {
                filteredItems.sort(by: {$0.price < $1.price})
            } else if sortText == "Highest price" {
                filteredItems.sort(by: {$0.price > $1.price})
            } else if sortText == "Date added" {
                filteredItems.sort(by: {$0.date < $1.date})
            }
            
            currentFilters["Sort"] = sortText
        } else {
            currentFilters["Sort"] = nil
        }
        
        if currentFilters["Category"] == nil && currentFilters["Search"] == nil {
            filteredItems = recentlyAdded
            currentFilters.removeAll()
            Utilities.saveFilters(currentFilters)
        }
        
        Utilities.saveFilters(currentFilters)
        navigationController?.popToRootViewController(animated: true)
    }
    
    // set action for clear button
    @objc func clearTapped() {
        for cell in filterCells {
            cell.filterTextField.text = nil
        }
        
        priceCell.firstTextField.text = nil
        priceCell.secondTextField.text = nil
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped(_ textField: UITextField) {
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

}
