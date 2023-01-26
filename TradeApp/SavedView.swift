//
//  SavedView.swift
//  TradeApp
//
//  Created by deathlezz on 26/11/2022.
//

import UIKit

class SavedView: UICollectionViewController {
    
    var savedItems = [Item]()
    
    var selectButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    
    var selectedCells = [UICollectionViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectTapped))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped))
        
        navigationItem.rightBarButtonItems = [selectButton]
        
        // pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        collectionView.refreshControl = refreshControl
        
        DispatchQueue.global().async { [weak self] in
            self?.savedItems = Utilities.loadItems()
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    // number of sections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // set number of items in section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedItems.count
    }
    
    // set collection view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("Unable to dequeue itemCell")
        }
        
        let img = UIImage(data: savedItems[indexPath.item].photos[0]!)
        
        cell.image.image = img
        cell.title.text = savedItems[indexPath.item].title
        cell.price.text = "£\(savedItems[indexPath.item].price)"
        cell.location.text = savedItems[indexPath.item].location
        cell.date.text = savedItems[indexPath.item].date.formatDate()
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .white
        
        return cell
    }
    
    // set action for selected cell
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if navigationItem.rightBarButtonItems == [selectButton] {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "detailView") as? DetailView {
                vc.imgs = savedItems[indexPath.item].photos.map {UIImage(data: $0!)}
                vc.item = savedItems[indexPath.item]
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
            
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            
            if cell.isSelected {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.layer.borderWidth = 1
                    cell.layer.borderColor = UIColor.systemRed.cgColor
                    cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }) { finished in
                    self.deleteButton.isEnabled = true
                    self.selectedCells.append(cell)
                    self.showButton()
                }
            }
        }
    }
    
    // set action for deselected cell
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        if !cell.isSelected {
            UIView.animate(withDuration: 0.1, animations: {
                cell.layer.borderWidth = 0
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.transform = .identity
            }) { finished in
                guard let index = self.selectedCells.firstIndex(of: cell) else { return }
                self.selectedCells.remove(at: index)
                self.showButton()
            }
        }
    }
    
    // set action for "pull to refresh"
    @objc func refresh(refreshControl: UIRefreshControl) {
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // refresh collection view before view appeared
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.isToolbarHidden = true
        savedItems = Utilities.loadItems()
        collectionView.reloadData()
    }

    // set action for select button
    @objc func selectTapped() {
        guard !savedItems.isEmpty else { return }
        collectionView.allowsMultipleSelection = true
        navigationItem.rightBarButtonItems = [cancelButton, deleteButton]
        deleteButton.isEnabled = false
    }
    
    // set action for cancel button
    @objc func cancelTapped() {
        collectionView.allowsMultipleSelection = false
        navigationItem.rightBarButtonItems = [selectButton]
        
        guard let selected = collectionView.indexPathsForSelectedItems else { return }
        
        for indexPath in selected {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        for cell in selectedCells {
            UIView.animate(withDuration: 0.1, animations: {
                cell.layer.borderWidth = 0
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.transform = .identity
            }) { finished in
                self.selectedCells.removeAll()
            }
        }
    }
    
    // set action for delete button
    @objc func deleteTapped() {
        guard let selected = collectionView.indexPathsForSelectedItems else { return }
        guard selected.count > 0 else { return }
        
        let indexes = selected.map { $0.item }
        
        collectionView.allowsMultipleSelection = false
        navigationItem.rightBarButtonItems = [selectButton]
        
        for indexPath in selected {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        savedItems = self.savedItems.enumerated().filter {!indexes.contains($0.offset)}.map {$0.element}
        collectionView.deleteItems(at: selected)
        
        for cell in selectedCells {
            UIView.animate(withDuration: 0.1, animations: {
                cell.layer.borderWidth = 0
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.transform = .identity
            }) { finished in
                self.selectedCells.removeAll()
                Utilities.saveItems(self.savedItems)
            }
        }
    }
    
    // set show/hide delete button
    func showButton() {
        guard let selected = collectionView.indexPathsForSelectedItems else { return }
        
        if selected.count > 0 {
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
        }
    }
    
}
