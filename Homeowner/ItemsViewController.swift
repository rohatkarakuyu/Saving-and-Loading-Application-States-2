//
//  ItemsViewController.swift
//  Homeowner
//
//  Created by Rohat Karakuyu on 10.11.2019.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class ItemsViewController: UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        
    }
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {

        let newItem = itemStore.createItem()
        if let index = itemStore.allItems.index(of: newItem) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    var itemStore: ItemStore!
    var imageStore: ImageStore!

    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return itemStore.allItems.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell",
                                                 for: indexPath) as! ItemCell
        
        let item = itemStore.allItems[indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.serialNumberLabel.text = item.serialNumber
        cell.valueLabel.text = "$\(item.valueInDollars)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        
        itemStore.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the triggered segue is the "showItem" segue
        switch segue.identifier {
        case "showItem"?:
            // Figure out which row was just tapped
            if let row = tableView.indexPathForSelectedRow?.row {
                // Get the item associated with this row and pass it along
                let item = itemStore.allItems[row]
                let detailViewController
                    = segue.destination as! DetailViewController
                detailViewController.item = item
                detailViewController.imageStore = imageStore
            } default:
                preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    override func tableView( _ tableView: UITableView,
                             commit EditingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if  EditingStyle == .delete {
            let item = itemStore.allItems[indexPath.row]
            
            let title = "Delete \(item.name)?"
            let message = "Are you sure you want to delete this item?"
            let basicAlert = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            basicAlert.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive,
                                             handler: { (action) -> Void in
                                                self.itemStore.removeItem(item)
                                                self.imageStore.deleteImage(forKey: item.itemKey)
                                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            
            basicAlert.addAction(deleteAction)
            
            present(basicAlert, animated: true, completion: nil)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }

}
