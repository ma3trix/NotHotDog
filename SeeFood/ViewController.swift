//
//  ViewController.swift
//
//  Created by Malik Adebiyi on 2020-04-25.
//  Copyright © 2020 dot.sandbox. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Convert UIimage to CIImage
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
            
            guard let convertedCIImage = CIImage(image: selectedImage)  else {
                fatalError("could not convert to CIImage")
            }
            
            // pass CI Image into detect function for clasifcation
            
            detect(image: convertedCIImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        // load inceptionV3 model
        guard let model =  try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        // request data to be classified by model
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            print(results)
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "hotdog!".capitalized
                } else {
                    self.navigationItem.title = "not hotdog!".capitalized
                }
            }
        }
        // define data passed to model as handler
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            // use handler to perform the request of classifiying the image
            try handler.perform([request])
        }catch{
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}

