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
	var catPicture:UIImage!
	
	var zoom = EasyZoom()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		
		catPicture = UIImage(named: "cat.jpg")
		self.zoom.zoomForImageView(catImageView, image: catPicture, superView: self.view)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

