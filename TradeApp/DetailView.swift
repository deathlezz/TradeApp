//
//  DetailViewController.swift
//  TradeApp
//
//  Created by deathlezz on 21/11/2022.
//

import UIKit

class DetailView: UITableViewController {
    
    var savedItems = [Item]()
    
    var actionButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    var removeButton: UIBarButtonItem!
    
    var item: Item!
    let sectionTitles = ["Image", "Title", "Tags", "Description"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonTitle = " "
        
        actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        saveButton = UIBarButtonItem(image: .init(systemName: "heart"), style: .plain, target: self, action: #selector(saveTapped))
        
        removeButton = UIBarButtonItem(image: .init(systemName: "heart.fill"), style: .plain, target: self, action: #selector(removeTapped))
        
        navigationItem.rightBarButtonItems = [saveButton, actionButton]
        
        DispatchQueue.global().async { [weak self] in
            self?.savedItems = Utilities.loadItems()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    // set title for every section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sectionTitles[section] == "Description" || sectionTitles[section] == "Tags" {
            return sectionTitles[section]
        } else {
            return nil
        }
    }

    // set number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // set table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sectionTitles[indexPath.section] {
        case "Image":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Image") as? GalleryCell {
                // cell image here
                return cell
            }
            
        case "Title":
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubText", for: indexPath)
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = "£\(item.price)"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 30)
            cell.isUserInteractionEnabled = false
            return cell
            
        case "Tags":
            let cell = tableView.dequeueReusableCell(withIdentifier: "Text", for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "\(item.category) | \(item.location) | Added on \(item.date.formatDate())"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.isUserInteractionEnabled = false
            return cell
            
        case "Description":
            let cell = tableView.dequeueReusableCell(withIdentifier: "Text", for: indexPath)
            cell.textLabel?.text = "Description here"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.isUserInteractionEnabled = false
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "itemView") as? ItemView {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // set action for save item button
    @objc func saveTapped() {
        savedItems.insert(item, at: 0)
        Utilities.saveItems(savedItems)
        navigationItem.rightBarButtonItems = [removeButton, actionButton]
    }
    
    // set action for remove item button
    @objc func removeTapped() {
        guard let index = savedItems.firstIndex(where: {$0.title == item.title}) else { return }
        savedItems.remove(at: index)
        Utilities.saveItems(savedItems)
        navigationItem.rightBarButtonItems = [saveButton, actionButton]
    }
    
    // set action for action button
    @objc func shareTapped() {
        let title = item.title
        
        let vc = UIActivityViewController(activityItems: [title], applicationActivities: [])
        
        present(vc, animated: true)
    }
    
    // set save/remove button icon
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if savedItems.contains(where: {$0.title == item.title}) {
            navigationItem.rightBarButtonItems = [removeButton, actionButton]
        } else {
            navigationItem.rightBarButtonItems = [saveButton, actionButton]
        }
    }

}
