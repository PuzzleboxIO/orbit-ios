//
//  SupportViewController.swift
//  Orbit
//
//  Created by Steve Castellotti on 9/18/16.
//  Copyright © 2016 Puzzlebox. All rights reserved.
//

import UIKit

class SupportViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		webViewSupport.delegate = self
		
		loadSupportSite()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBOutlet weak var webViewSupport: UIWebView!
	@IBOutlet weak var buttonRetry: UIButton!
	@IBOutlet weak var labelSupport: UILabel!
	
	func loadSupportSite(){
		let localfilePath = Bundle.main.url(forResource: "support", withExtension: "html");
		let myRequest = NSURLRequest(url: localfilePath!);
		webViewSupport.loadRequest(myRequest as URLRequest);
	}
	
	@IBAction func buttonRetry(_ sender: AnyObject) {
		buttonRetry.isHidden = true
		labelSupport.text = "Contacting support..."
		loadSupportSite()
	}
	
}


// MARK: UIWebView delegate
extension SupportViewController: UIWebViewDelegate {
	
	func webViewDidFinishLoad(_ webView: UIWebView) {
		buttonRetry.isHidden = true
		labelSupport.isHidden = true
	}
	
	func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		switch navigationType {
		case .linkClicked:
			// Open links in Safari
			UIApplication.shared.openURL(request.url!)
			return false
		default:
			// Handle other navigation types...
			return true
		}
	}
	
	func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
		let myAlert = UIAlertController(title: "Not Connected", message: "Unable to contact support without internet connection", preferredStyle: UIAlertControllerStyle.alert)
		myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		//cancelButtonTitle: "OK"
		
		self.present(myAlert, animated: true, completion: nil)
		
		buttonRetry.isHidden = false
		labelSupport.isHidden = false
		labelSupport.text = "Unabled to contact support"
	}
	
}
