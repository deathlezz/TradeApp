//
//  SearchHistoryTableView.swift
//  TradeApp
//
//  Created by deathlezz on 18/11/2022.
//

import UIKit

class SearchView: UITableViewController {
    
    var categories = [String]()
    
    var recentlySearched = [String]()
    var currentFilters = [String: String]()
        
    var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.hidesBarsOnSwipe = false
        
        setUpSearchBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "historyCell")
        
        DispatchQueue.global().async { [weak self] in
            self?.currentFilters = Utilities.loadFilters()
            self?.loadHistory()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set section title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        recentlySearched.count == 0 ? nil : "Recently searched"
    }

    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentlySearched.count
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = recentlySearched[indexPath.row]
        return cell
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textField.text = recentlySearched[indexPath.row]
        returnTapped()
    }
    
    // set action for "return" keyboard button
    @objc func returnTapped() {
        let currentCategory = currentFilters["Category"]
        
        let word = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // category filter
        if currentCategory != nil {
            if currentCategory == categories[0] {
                filteredItems = items
            } else if currentCategory != categories[0] {
                filteredItems = items.filter {$0.category == currentCategory}
            }
        }
        
        if !word.isEmpty && currentFilters["Category"] != nil {
            filteredItems = filteredItems.filter {$0.title.lowercased().contains(word.lowercased())}
            Utilities.manageFilters(currentFilters)
            isUnique(word)
            currentFilters["Search"] = word

        } else if !word.isEmpty && currentFilters["Category"] == nil {
            filteredItems = items.filter {$0.title.lowercased().contains(word.lowercased())}
            Utilities.manageFilters(currentFilters)
            isUnique(word)
            currentFilters["Category"] = categories[0]
            currentFilters["Search"] = word

        } else if word.isEmpty && currentFilters["Category"] != nil {
            Utilities.manageFilters(currentFilters)
            currentFilters["Search"] = nil

        } else if word.isEmpty && currentFilters["Category"] == nil {
            filteredItems = recentlyAdded
            currentFilters.removeAll()
        }
        
        Utilities.saveFilters(currentFilters)
        textField.resignFirstResponder()
        navigationController?.popToRootViewController(animated: true)
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            recentlySearched.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveHistory()
        }
    }
    
    // start editing textfield after view appeared
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // set textfield.text before view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = currentFilters["Search"]
    }
    
    // finish editing texfield before view disappeared
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
    }

    // add unique word to recently searched array
    func isUnique(_ word: String) {
        if !recentlySearched.contains(word) {
            let indexPath = IndexPath(row: 0, section: 0)
            recentlySearched.insert(word, at: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            
            if recentlySearched.count > 10 {
                recentlySearched.removeLast()
            }
            
            saveHistory()
        }
    }
    
    // save search history
    func saveHistory() {
        let defaults = UserDefaults.standard
        defaults.set(recentlySearched, forKey: "recentlySearched")
    }
    
    // load search history
    func loadHistory() {
        let defaults = UserDefaults.standard
        recentlySearched = defaults.object(forKey: "recentlySearched") as? [String] ?? [String]()
    }
    
    // set up search bar
    func setUpSearchBar() {
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: (navigationController?.navigationBar.frame.width)!, height: 30))
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Find something for yourself"
        textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
        textField.returnKeyType = .search
        textField.leftViewMode = .always
        textField.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        textField.leftView?.tintColor = .systemGray4
        navigationItem.titleView = textField
    }
    
}
