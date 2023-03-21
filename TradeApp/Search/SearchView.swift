//
//  SearchHistoryTableView.swift
//  TradeApp
//
//  Created by deathlezz on 18/11/2022.
//

import UIKit

class SearchView: UITableViewController {

    var sections = [String]()
    var categories = [String]()
    
    var recentlySearched = [String]()
    var currentFilters = [String: String]()
        
    var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.hidesBarsOnSwipe = false
        
        setUpSearchBar()
        
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 20
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
        return sections.count
    }

    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentlySearched.count
    }
    
    // set table view header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
        let label = UILabel()
        
        label.frame = CGRect.init(x: 20, y: -20, width: headerView.frame.width - 10, height: headerView.frame.height)
        
        label.text = recentlySearched.count == 0 ? nil : sections[section]
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .systemGray
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = recentlySearched[indexPath.row]
        cell.imageView?.image = UIImage(systemName: "clock")
        cell.imageView?.tintColor = .systemBlue
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
                Storage.shared.filteredItems = Storage.shared.items
            } else if currentCategory != categories[0] {
                Storage.shared.filteredItems = Storage.shared.items.filter {$0.category == currentCategory}
            }
        }
        
        if !word.isEmpty && currentFilters["Category"] != nil {
            Storage.shared.filteredItems = Storage.shared.filteredItems.filter {$0.title.lowercased().contains(word.lowercased())}
            Utilities.manageFilters(currentFilters)
            isUnique(word)
            currentFilters["Search"] = word

        } else if !word.isEmpty && currentFilters["Category"] == nil {
            Storage.shared.filteredItems = Storage.shared.items.filter {$0.title.lowercased().contains(word.lowercased())}
            Utilities.manageFilters(currentFilters)
            isUnique(word)
            currentFilters["Category"] = categories[0]
            currentFilters["Search"] = word

        } else if word.isEmpty && currentFilters["Category"] != nil {
            Utilities.manageFilters(currentFilters)
            currentFilters["Search"] = nil

        } else if word.isEmpty && currentFilters["Category"] == nil {
            Storage.shared.filteredItems = Storage.shared.recentlyAdded
            currentFilters.removeAll()
        }
        
        Utilities.saveFilters(currentFilters)
        textField.resignFirstResponder()
        navigationController?.popToRootViewController(animated: true)
    }
    
    // swipe to delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if recentlySearched.count > 1 {
                recentlySearched.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                saveHistory()
            } else {
                let indexSet = IndexSet(integer: 0)
                recentlySearched.remove(at: indexPath.row)
                sections.removeAll()
                tableView.deleteSections(indexSet, with: .fade)
                saveHistory()
            }
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
            
            if recentlySearched.count < 1 {
                let indexSet = IndexSet(integer: 0)
                recentlySearched.insert(word, at: 0)
                sections.append("Recently searched")
                tableView.insertSections(indexSet, with: .fade)
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                recentlySearched.insert(word, at: 0)
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
            
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
        sections = recentlySearched.count > 0 ? ["Recently searched"] : []
    }
    
    // set up search bar
    func setUpSearchBar() {
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: (navigationController?.navigationBar.frame.width)!, height: 30))
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Find something for yourself"
        textField.addTarget(self, action: #selector(returnTapped), for: .primaryActionTriggered)
        textField.returnKeyType = .search
        
        navigationItem.titleView = textField
        
        let imageView = UIImageView(frame: CGRect(x: 6, y: 4, width: 22, height: 22))
        let image = UIImage(systemName: "magnifyingglass")
        imageView.image = image
        imageView.tintColor = .systemGray4
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 30))
        view.addSubview(imageView)
        view.backgroundColor = .clear
        
        textField.leftViewMode = .always
        textField.leftView?.tintColor = .systemGray4
        textField.leftView = view
    }
    
}
