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
    
    let categoryImages = ["car", "house", "case", "chair.lounge", "laptopcomputer.and.ipad", "tshirt", "leaf", "bird", "teddybear", "basketball", "airpodspro", "dollarsign"]

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell", for: indexPath)
        let conf = UIImage.SymbolConfiguration(scale: .large)
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = "\(items.count) ads"
            cell.imageView?.image = UIImage(systemName: "cart", withConfiguration: conf)
        } else {
            cell.detailTextLabel?.text = "\(items.filter {$0.category == "\(categories[indexPath.row])"}.count) ads"
            cell.imageView?.image = UIImage(systemName: categoryImages[indexPath.row - 1], withConfiguration: conf)
        }
        
        cell.textLabel?.text = categories[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
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
        
        if currentFilters["Search"] != nil {
            filteredItems = filteredItems.filter {$0.title.lowercased().contains(currentFilters["Search"]!.lowercased())}
            Utilities.manageFilters(currentFilters)
        } else if currentFilters["Search"] == nil {
            Utilities.manageFilters(currentFilters)
        }
        
        currentFilters["Category"] = word
        Utilities.saveFilters(currentFilters)
        navigationController?.popToRootViewController(animated: true)
    }

}
