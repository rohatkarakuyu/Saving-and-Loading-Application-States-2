//
//  DetailViewController.swift
//  Homeowner
//
//  Created by Rohat Karakuyu on 15.11.2019.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) { imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imageURL() -> URL {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent("MyImage")
    }
    
    func setImage(_ image: UIImage) {
        
        // Create a full URL for the image
        let url = imageURL()
        
        // Turn image into JPEG data
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            // Write it to full URL
            let _ = try? data.write(to: url, options: [.atomic])
        }
    }
    
    func image() -> UIImage? {
        
        let url = imageURL()
        
        guard let imageFromDisk = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        
        return imageFromDisk
    }
    
    func deleteImage() {
        
        let url = imageURL()
        
        do {
            try FileManager.default.removeItem(at: url)
        }
        catch let deleteError {
            print("Error removing the image from disk: \(deleteError)")
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Store the image in the ImageStore for the item's key
        imageStore.setImage(image, forKey: item.itemKey)
        
        imageView.image = image
        dismiss(animated: true, completion: nil)
        deleteImage()
        setImage(image)
    }
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var serialNumberField: UITextField!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    
    var item: Item! { didSet {
        navigationItem.title = item.name
        }
    }
    
    var imageStore: ImageStore!
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Image Editor"
        nameField.text = item.name
        serialNumberField.text = item.serialNumber
        valueField.text = numberFormatter.string(from: NSNumber(value: item.valueInDollars))
        dateLabel.text = dateFormatter.string(from: item.dateCreated)
        
        // If there is an associated image with the item
        // display it on the image view
        if let imageOnDisk = image() {
            imageView.image = imageOnDisk
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
        // "Save" changes to item
        item.name = nameField.text ?? ""
        item.serialNumber = serialNumberField.text
        if let valueText = valueField.text,
            let value = numberFormatter.number(from: valueText) {
            item.valueInDollars = value.intValue
        } else {
            item.valueInDollars = 0
        }
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
