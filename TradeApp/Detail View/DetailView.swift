//
//  DetailViewController.swift
//  TradeApp
//
//  Created by deathlezz on 21/11/2022.
//

import UIKit

class DetailView: UITableViewController, Index {
    
    var savedItems = [Item]()
    
    var imgs = [UIImage?]()
    var actionButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    var removeButton: UIBarButtonItem!
    var isPushed: Bool!
    
    var item: Item!
    let sectionTitles = ["Image", "Title", "Tags", "Description", "Location"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set toolbar "call" button
        let callFrame = UIButton(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width / 2) - 20, height: 50))
        let image = UIImage(systemName: "phone.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        callFrame.setImage(image, for: .normal)
        callFrame.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        callFrame.backgroundColor = .white
        callFrame.layer.cornerRadius = 7
        let callButton = UIBarButtonItem(customView: callFrame)
        
        // set toolbar "message" button
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
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 83, right: 0)
        
        DispatchQueue.global().async { [weak self] in
            self?.savedItems = Utilities.loadItems()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // set title for every section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sectionTitles[section] == "Description" || sectionTitles[section] == "Tags" || sectionTitles[section] == "Location" {
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "detailCollectionView") as? DetailViewCell {
                cell.imgs = imgs
                cell.delegate = self
                cell.selectionStyle = .none
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
            
        case "Location":
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as? MapViewCell {
                cell.cityLabel.text = item.location
                cell.distanceLabel.text = "N/A"
                cell.distanceLabel.numberOfLines = 0
                cell.mapView.layer.cornerRadius = 8
                cell.mapView.mapType = .standard
                cell.mapView.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                return cell
            }
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    // set action for tapped cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sectionTitles[indexPath.section] == "Location" {
            openMaps()
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
    
    // set location after view appeared
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("pushLocation"), object: nil, userInfo: ["location": item.location])
    }
    
    // set save/remove button icon
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isPushed = false
        NotificationCenter.default.post(name: NSNotification.Name("restoreMap"), object: nil)
        
        DispatchQueue.global().async { [weak self] in
            self?.savedItems = Utilities.loadItems()
        }
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = false
        
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
        guard let url = URL(string: "telprompt://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    // set action for message button
    @objc func messageTapped() {
        print("message will be send here")
    }

    // get current image index and push view controller
    func pushIndex(index: Int) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ItemView") as? ItemView {
            vc.currentImage = index
            vc.imgs = imgs
            isPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // remove mapView before view disappeared
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isPushed {
            NotificationCenter.default.post(name: NSNotification.Name("removeMap"), object: nil)
        }
    }
    
    // open google maps or apple maps
    func openMaps() {
        let appleMaps = URL(string: "maps://")!
        let googleMaps = URL(string: "comgooglemaps://")!
        
        if UIApplication.shared.canOpenURL(appleMaps) && UIApplication.shared.canOpenURL(googleMaps) {
            let ac = UIAlertController(title: "Maps", message: "Choose map provider", preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "Google Maps", style: .default) { _ in
                guard let url = URL(string: "comgooglemaps://?saddr=&daddr=55,-4") else { return }
                UIApplication.shared.open(url)
            })
            ac.addAction(UIAlertAction(title: "Apple Maps", style: .default) { _ in
                guard let url = URL(string: "maps://?saddr=&daddr=55,-4") else { return }
                UIApplication.shared.open(url)
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
            
        } else if UIApplication.shared.canOpenURL(appleMaps) {
            guard let url = URL(string: "maps://?saddr=&daddr=55,-4") else { return }
            UIApplication.shared.open(url)
        } else if UIApplication.shared.canOpenURL(googleMaps) {
            guard let url = URL(string: "comgooglemaps://?saddr=&daddr=55,-4") else { return }
            UIApplication.shared.open(url)
        }
    }
    
}
