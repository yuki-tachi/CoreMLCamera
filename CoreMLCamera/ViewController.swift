//
//  ViewController.swift
//  CoreMLCamera
//
//  Created by Yuki Tachi on 2020/08/08.
//  Copyright © 2020 Yuki Tachi. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var photoDisplay: UIImageView!
    @IBOutlet weak var photoInfoDisplay: UITextView!
    @IBAction func takePhoto(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
    }
    
    var imagePicker: UIImagePickerController!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        photoDisplay.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        imageInference(image: (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!)
    }

     func imageInference(image: UIImage) {
         guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
             fatalError("モデルをロードできません")
         }
     
         let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            let displayText = results.prefix(3).compactMap { "\($0.identifier) (\(Int($0.confidence * 100))%)" }.joined(separator: "\n")
            
             DispatchQueue.main.async {
                self?.photoInfoDisplay.text = displayText
             }
         }
     
         guard let ciImage = CIImage(image: image) else {
             fatalError("画像を変換できません")
         }

         let imageHandler = VNImageRequestHandler(ciImage: ciImage)
         
         DispatchQueue.global(qos: .userInteractive).async {
             do {
                 try imageHandler.perform([request])
             } catch {
                 print("エラー \(error)")
             }
         }
    }

}
