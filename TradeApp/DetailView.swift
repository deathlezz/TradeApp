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
    
        let callFrame = UIButton(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width / 2) - 20, height: 50))
        let image = UIImage(systemName: "phone.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        callFrame.setImage(image, for: .normal)
        callFrame.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        callFrame.backgroundColor = .white
        callFrame.layer.cornerRadius = 7
        let callButton = UIBarButtonItem(customView: callFrame)
        
        let messageFrame = UIButton(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width / 2) - 20, height: 50))
        let message = UIImage(systemName: "ellipsis.message.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        messageFrame.setImage(message, for: .normal)
        messageFrame.addTarget(self, action: #selector(messageTapped), for: .touchUpInside)
        messageFrame.backgroundColor = .white
        messageFrame.layer.cornerRadius = 7
        let messageButton = UIBarButtonItem(customView: messageFrame)
        
        toolbarItems = [callButton, messageButton]
        navigationController?.isToolbarHidden = false
        
        navigationItem.backButtonTitle = " "
        navigationController?.hidesBarsOnSwipe = false
        
        actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        saveButton = UIBarButtonItem(image: .init(systemName: "heart"), style: .plain, target: self, action: #selector(saveTapped))
        
        removeButton = UIBarButtonItem(image: .init(systemName: "heart.fill"), style: .plain, target: self, action: #selector(removeTapped))
        
        navigationItem.rightBarButtonItems = [saveButton, actionButton]
        tableView.separatorStyle = .none
        
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
                let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction))
                leftSwipe.direction = .left
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(getSwipeAction))
                rightSwipe.direction = .right
                cell.addGestureRecognizer(leftSwipe)
                cell.addGestureRecognizer(rightSwipe)
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
            cell.textLabel?.text = item.description
            cell.textLabel?.numberOfLines = 0
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
        
        if savedItems.count > 50 {
            showAlert()
            savedItems.remove(at: 0)
        } else {
            navigationItem.rightBarButtonItems = [removeButton, actionButton]
        }
        
        Utilities.saveItems(savedItems)
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
        savedItems = Utilities.loadItems()
        navigationController?.isNavigationBarHidden = false
        
        if savedItems.contains(where: {$0.title == item.title}) {
            navigationItem.rightBarButtonItems = [removeButton, actionButton]
        } else {
            navigationItem.rightBarButtonItems = [saveButton, actionButton]
        }
    }
    
    // show save alert
    func showAlert() {
        let ac = UIAlertController(title: "You can't save more items.", message: "You've already saved 50 items.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
    
    // set action for call button
    @objc func callTapped() {
        let phoneNumber = 123456789
        guard let url = URL(string: "telprompt://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    // set action for message button
    @objc func messageTapped() {
        
    }
    
    // set swipe recognizer
    @objc func getSwipeAction(_ recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .left {
            print("Left swipe")
        } else if recognizer.direction == .right {
            print("Right swipe")
        }
    }

}
