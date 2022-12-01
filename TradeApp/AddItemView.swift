//
//  AddItemView.swift
//  TradeApp
//
//  Created by deathlezz on 01/12/2022.
//

import UIKit

class PhotosView: UICollectionView {

    override func numberOfItems(inSection section: Int) -> Int {
        return 8
    }
    
    override func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
        guard let cell = dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotosCell else {
            fatalError("Unable to dequeue photosCell")
        }
        
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
}

class AddItemView: UITableViewController {
    
    let sectionTitles = ["Photos", "Title", "Price", "Category", "Location", "Description"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Button", style: .plain, target: self, action: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? GalleryCell {
            return cell
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as? FilterCell {
            cell.filterTextField.placeholder = "Enter text"
            return cell
        }
        return UITableViewCell()
    }


}
