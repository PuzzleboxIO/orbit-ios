//
//  TutorialViewController.swift
//  Orbit
//
//  Created by Steve Castellotti on 9/18/16.
//  Copyright © 2016 Puzzlebox. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let localfilePath = Bundle.main.url(forResource: "frame", withExtension: "html");
		let myRequest = NSURLRequest(url: localfilePath!);
		webViewTutorial.loadRequest(myRequest as URLRequest);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBOutlet weak var webViewTutorial: UIWebView!
	
}
