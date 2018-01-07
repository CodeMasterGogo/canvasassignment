//
//  ViewController.swift
//  canvas
//
//  Created by GOLDI LAKHMANI on 07/01/18.
//  Copyright © 2018 Abhishek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var primaryImageView: UIImageView!
    @IBOutlet weak var secondaryImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
   
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var ImageSecquenc = [Any]()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(primaryImageView.frame.size)
        primaryImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: 1.0)
        secondaryImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: opacity)
        let data = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext()!)
        if let imageData = data{
            ImageSecquenc.append(imageData)
        }
        //print(ImageSecquenc)
        primaryImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        secondaryImageView.image = nil
    }

    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        secondaryImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2
        context?.move(to: CGPoint(x:fromPoint.x, y:fromPoint.y))
        context?.addLine(to: CGPoint(x:toPoint.x, y:toPoint.y))
        
        // 3
        context?.setLineCap(.round)
        context!.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(.normal)
        
        // 4
        context?.strokePath()
        
        // 5
        secondaryImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        secondaryImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    @IBAction func saveBtnPressed(_ sender: Any) {
        saveImageDocumentDirectory()
    }
    
    func saveImageDocumentDirectory(){
        if(ImageSecquenc.count > 0)
        {
            let alertController = UIAlertController(title: "Canvas?", message: "Please Give Canvas Name:", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                let imageName = alertController.textFields![0].text! + ".jpg"
                let imageData: Data = self.ImageSecquenc.last as! Data
                let fileManager = FileManager.default
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
               // print(paths)
                fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alertController.addTextField { (textField) in
                textField.placeholder = "Canvas Name"
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func undoBtnPressed(_ sender: Any) {
        undoImage()
    }
    
    func undoImage()  {
        primaryImageView.image = nil
        var imageCount: Int = ImageSecquenc.count
        if imageCount > 0{
            ImageSecquenc.remove(at: imageCount - 1)
        }
        imageCount = ImageSecquenc.count
        if imageCount > 0{
            primaryImageView.image = UIImage.init(data: ImageSecquenc[imageCount - 1] as! Data)
        }
    }
    
    @IBAction func clearBtnPressed(_ sender: Any) {
       primaryImageView.image = nil
       ImageSecquenc.removeAll()
    }
    
}

