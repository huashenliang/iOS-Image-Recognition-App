//
//  ViewController.swift
//  SeeFood
//
//  Created by huashen liang on 2019-06-02.
//  Copyright © 2019 huashen liang. All rights reserved.
//

import UIKit
import CoreML
import Vision

//UIImagePickerControllerDelegate relies on UINavigationControllerDelegate
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    //create imagePicker object
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        //brings up a imagepicer that contains the camera module so allows the user to take an image
        imagePicker.sourceType = .camera
        
        //boolean - whether the user is allowed to edit a selected image or movie
        imagePicker.allowsEditing = false
    }

    //delegate method -> tells the delegate that user has picked an image or movie
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        //orignal unedited image selected by the user, the image that user selected or tooked
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        
            imageView.image = userPickedImage
            
            //convert user picked UIimage to CIImage, then able to use the Vision framework and coreML
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //use Inceptionv3 model
    func detect(image: CIImage) {
        //VNCoreModel container, creating a new ojbect of Inceptionv3 and getting its model property
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading coreML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            //VNClassificationObservation -> a class that holds classification observations after the models
            //been processed
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            //the first result
            if let firstResult = results.first {
                //get the first word in the string, separted by ","
                let resultItem = firstResult.identifier.components(separatedBy: ",")[0]
                //let percentage = Float(firstResult.confidence)
                let percentage = String(format: "%.2f", Float(firstResult.confidence) * 100)
                self.navigationItem.title = ("\(percentage)%  \(resultItem)")
                
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }catch{
            print(error)
        }
    }
    
    
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)

//        present(imagePicker, animated: true, completion: nil)
    }

    func openCamera() {

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

