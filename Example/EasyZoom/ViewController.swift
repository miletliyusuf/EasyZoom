//
//  ViewController.swift
//  EasyZoom
//
//  Created by miletliyusuf on 06/30/2015.
//  Copyright (c) 06/30/2015 miletliyusuf. All rights reserved.
//

import UIKit
import EasyZoom

class ViewController: UIViewController {

	@IBOutlet var catImageView:UIImageView!
	@IBOutlet var catHolder:UIView!
	var catPicture:UIImage!
	var zoom:EasyZoom!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		
		catPicture = UIImage(named: "cat.jpg")
		
		zoom = EasyZoom(imageView: catImageView, image: catPicture, superView: catHolder)
		zoom.fadeOutAnimationTime = 0.15
		zoom.zoomForImageView()
		zoom.mainView = self.view
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

