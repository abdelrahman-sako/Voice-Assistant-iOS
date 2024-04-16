//
//  ImageViewController.swift
//  VoiceAssistant
//
//  Created by Osama Hasan on 21/03/2024.
//

import UIKit

class ImageViewController: UIViewController {

    var imageUrl:String?
    
    @IBOutlet weak var selectedImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let urlString = imageUrl, let url = URL(string: urlString) {
            selectedImageView.load(url: url)

        }
        
        setupIconNavigationBar()
    }


    
    @objc func backAction(){
        self.dismiss(animated: true)
    }

    
    func setupIconNavigationBar(){
        let image =  UIImage(named: "close")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem?.tintColor = .white
    }

    


}
