//
//  ViewController.swift
//  VideoEditor
//
//  Created by Twinbit Limited on 3/1/23.
//

import UIKit
import AVKit
import PhotosUI
import ImageIO
class ViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var videoPlayView: UIView!
    @IBAction func btnVideoPick(_ sender: Any){
        do {
            
            var config = PHPickerConfiguration()
            config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            config.selectionLimit = 1
            config.filter = .videos
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            self.present(picker, animated: true)
        }
        
    }
    
    //MARK: Varriables
     
    
    
    //MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
}

//MARK: PHPickerViewControllerDelegate
extension ViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            print(Thread.isMainThread)
            guard let result = results.first else { return }
            // proving you don't get asset id unless you specified library
            let assetid = result.assetIdentifier
            print(assetid as Any)
            let prov = result.itemProvider
            let types = prov.registeredTypeIdentifiers
            print("types:", types)
            
            if prov.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                self.dealWithVideo(result)
            }
        }
    }
    
    fileprivate func dealWithVideo(_ result: PHPickerResult) {
        
        let movie = UTType.movie.identifier
        let prov = result.itemProvider
        // NB we could have a Progress here if we want one
        prov.loadFileRepresentation(forTypeIdentifier: movie) { url, err in
            if let url = url {
                
                DispatchQueue.main.sync {

                    print("normal movie")
                    self.showMovie(url: url)
                    
                }
            }
        }
    }
    
    func clearAll() {
        print("clearing interface")
        if self.children.count > 0 {
            let av = self.children[0] as! AVPlayerViewController
            av.willMove(toParent: nil)
            av.view.removeFromSuperview()
            av.removeFromParent()
        }
        self.videoPlayView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    
    func showMovie(url:URL) {
        self.clearAll()
        print("showing movie")
        let av = AVPlayerViewController()
        let player = AVPlayer(url:url)
        av.player = player
        self.addChild(av)
        av.view.frame = self.videoPlayView.bounds
        av.view.backgroundColor = self.videoPlayView.backgroundColor
        self.videoPlayView.addSubview(av.view)
        av.didMove(toParent: self)
        player.play()
    }
    
    
}

