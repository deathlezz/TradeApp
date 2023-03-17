//
//  CollectionTableViewCell.swift
//  TradeApp
//
//  Created by deathlezz on 10/12/2022.
//

import UIKit

protocol ImagePicker {
    func addNewPhoto()
    func editPhoto()
    func pushIndex(indexPath: Int)
}

class CollectionTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var delegate: ImagePicker?
    
    override func awakeFromNib() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name("reload"), object: nil)
        
        for _ in 0...7 {
            AddItemView.shared.images.append(UIImage(systemName: "plus")!)
        }
    }
    
    // set number of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    // set collection view cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotosCell {
            
            cell.layer.cornerRadius = 10
            cell.imageView.image = AddItemView.shared.images[indexPath.item]
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // set action for tapped cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.pushIndex(indexPath: indexPath.item)
        
        if AddItemView.shared.images[indexPath.item] == UIImage(systemName: "plus") {
            delegate?.addNewPhoto()
        } else {
            delegate?.editPhoto()
        }
    }
    
    // item has been dragged
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard AddItemView.shared.images.filter({$0 != UIImage(systemName: "plus")}).count > 1 else { return [] }
        let item = AddItemView.shared.images[indexPath.item]
        guard item != UIImage(systemName: "plus") else { return [] }
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    // item is moving
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    // item has been dropped
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        let numberOfPhotos = AddItemView.shared.images.filter {$0 != UIImage(systemName: "plus")}.count
        
        if let indexPath = coordinator.destinationIndexPath {
            if indexPath.item < numberOfPhotos {
                destinationIndexPath = indexPath
            } else {
                let row = numberOfPhotos
                destinationIndexPath = IndexPath(item: row - 1, section: 0)
            }
        } else {
            let row = numberOfPhotos
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move {
            reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
            reloadView()
        }
    }
    
    // set action for drag and drop
    func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        if let item = coordinator.items.first,
           let sourceIndexPath = item.sourceIndexPath {
            
            collectionView.performBatchUpdates({
                AddItemView.shared.images.remove(at: sourceIndexPath.item)
                AddItemView.shared.images.insert(item.dragItem.localObject as! UIImage, at: destinationIndexPath.item)
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            })
            
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
    // reload collection view
    @objc func reloadView() {
        UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.collectionView.reloadData()
        }) { finished in
            print("collection view reloaded")
        }
    }
    
}
