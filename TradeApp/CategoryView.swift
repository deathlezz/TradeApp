//
//  CategoryTableView.swift
//  TradeApp
//
//  Created by deathlezz on 17/11/2022.
//

import UIKit

class CategoryView: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Categories"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "itemCell")
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
        filteredItems.removeAll()
        
        if word == categories[0] {
            filteredItems = items
        } else {
            for item in items {
                if item.category.contains(word) {
                    filteredItems.append(item)
                }
            }
        }
        
        isFilterApplied = true
        currentFilters["Category"] = word
        navigationController?.popToRootViewController(animated: true)
    }

}
