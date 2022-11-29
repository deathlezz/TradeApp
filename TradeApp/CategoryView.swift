//
//  CategoryTableView.swift
//  TradeApp
//
//  Created by deathlezz on 17/11/2022.
//

import UIKit

class CategoryView: UITableViewController {
    
    var categories = [String]()
    var currentFilters = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Categories"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
        
        DispatchQueue.global().async { [weak self] in
            self?.currentFilters = Utilities.loadFilters()
        }
    }

    // number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // number of row in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row]
        cell.textLabel?.font = UIFont(name: "System", size: 30)
        
        return cell
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = categories[indexPath.row]
        
        if word == categories[0] {
            filteredItems = items
        } else if word != categories[0] {
            filteredItems = items.filter {$0.category == word}
        }
        
        if isSearchApplied {
            filteredItems = filteredItems.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
            Utilities.manageFilters(currentFilters)
        } else if !isSearchApplied {
            Utilities.manageFilters(currentFilters)
        }
        
        isCategoryApplied = true
        currentFilters["Category"] = word
        Utilities.saveFilters(currentFilters)
        navigationController?.popToRootViewController(animated: true)
    }

}
