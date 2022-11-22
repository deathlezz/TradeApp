//
//  FilterView.swift
//  TradeApp
//
//  Created by deathlezz on 22/11/2022.
//

import UIKit

class FilterView: UITableViewController {
    
    var filterCells = [FilterCell]()
    var priceCell: PriceCell!
    
    let sectionTitles = ["Sort", "Category", "Location", "Price"]
    
    var applyButton: UIBarButtonItem!
    var clearButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Filter"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        applyButton = UIBarButtonItem(title: "Apply", style: .plain, target: self, action: #selector(applyTapped))
        
        clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        
        navigationItem.rightBarButtonItems = [clearButton, applyButton]
    }

    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // set title for every section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
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
                cell.filterTextField.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                filterCells.append(cell)
                return cell
            case "Category":
                cell.filterTextField.placeholder = "None"
                cell.filterTextField.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                filterCells.append(cell)
                return cell
            case "Location":
                cell.filterTextField.placeholder = "None"
                cell.selectionStyle = .none
                cell.filterTextField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
                filterCells.append(cell)
                return cell
            default:
                break
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as? PriceCell {
            cell.firstTextField.placeholder = "From"
            cell.secondTextField.placeholder = "To"
            cell.selectionStyle = .none
            priceCell = cell
            return cell
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

}
