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
	
	var zoom = EasyZoom()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		
		self.view.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
		
		catPicture = UIImage(named: "cat.jpg")
		self.zoom.zoomForImageView(catImageView, image: catPicture, superView: self.catHolder)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

