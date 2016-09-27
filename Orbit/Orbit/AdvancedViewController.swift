//
//  AdvancedViewController.swift
//  Orbit
//
//  Created by Steve Castellotti on 9/20/16.
//  Copyright © 2016 Puzzlebox. All rights reserved.
//

import UIKit
import CoreMotion

class AdvancedViewController: UIViewController {
	
	var referenceTiltX:Float = 0
	var referenceTiltY:Float = 0
	//	let tiltSensorMinimumThreshold:Float = 0.01
	let tiltSensorMinimumThreshold:Float = 0.001
	
	lazy var motionManager: CMMotionManager = {
		let motion = CMMotionManager()
		motion.accelerometerUpdateInterval = 2.0 / 10.0 // means update every 2 / 10 second
		motion.gyroUpdateInterval = 2.0 / 10.0
		//		motion.accelerometerUpdateInterval = 1.0 / 10.0 // means update every 1 / 10 second
		//		motion.gyroUpdateInterval = 1.0 / 10.0
		return motion
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print("INFO [AdvancedViewController]: viewDidLoad()")
		
		sliderThrottle.addTarget(self, action: #selector(AdvancedViewController.updateThrottle), for: .valueChanged)
		sliderYaw.addTarget(self, action: #selector(AdvancedViewController.updateYaw), for: .valueChanged)
		sliderPitch.addTarget(self, action: #selector(AdvancedViewController.updatePitch), for: .valueChanged)
		
		switchTiltControl.addTarget(self, action: #selector(AdvancedViewController.updateTiltControl), for: .valueChanged)
		switchThrottleOnly.addTarget(self, action: #selector(AdvancedViewController.updateThrottleOnly), for: .valueChanged)
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBOutlet weak var sliderThrottle: UISlider!
	func updateThrottle() {
		print("INFO [AdvancedViewController: updateThrottle(): \(sliderThrottle.value)")
		ControlSignalManager.sharedInstance.throttle = Int(sliderThrottle.value * 100)
		ControlSignalManager.sharedInstance.updateControlSignal()
	}
	
	@IBOutlet weak var sliderYaw: UISlider!
	func updateYaw() {
		print("INFO [AdvancedViewController: updateYaw(): \(sliderYaw.value)")
//		ControlSignalManager.sharedInstance.yaw = Int(sliderYaw.value * 100)
		
		// We subtract the current Yaw position from the maximum slider value
		// because smaller values instruct the helicopter to spin to the right
		// (clockwise if looking down from above) whereas intuitively moving
		// the slider to the left should cause it to spin left
		
		ControlSignalManager.sharedInstance.yaw = Int(round((sliderYaw.maximumValue - sliderYaw.value) * 100))
		ControlSignalManager.sharedInstance.updateControlSignal()
	}
	
	@IBOutlet weak var sliderPitch: UISlider!
	func updatePitch() {
		print("INFO [AdvancedViewController: updatePitch(): \(sliderPitch.value)")
		ControlSignalManager.sharedInstance.pitch = Int(sliderPitch.value * 100)
		ControlSignalManager.sharedInstance.updateControlSignal()
	}
	
	@IBOutlet weak var buttonHover: UIButton!
	@IBAction func buttonHover(_ sender: AnyObject) {
		print("INFO [AdvancedViewController]: buttonHover()")
		sliderThrottle.setValue(Float(ControlSignalManager.sharedInstance.defaultThrottleHover) / 100, animated: true)
		sliderYaw.setValue(Float(ControlSignalManager.sharedInstance.defaultYawHover) / 100, animated: true)
		sliderPitch.setValue(Float(ControlSignalManager.sharedInstance.defaultPitchHover) / 100, animated: true)
		referenceTiltX = 0
		referenceTiltY = 0
		ControlSignalManager.sharedInstance.updateControlSignal()
	}
	
	@IBOutlet weak var buttonForward: UIButton!
	@IBAction func buttonForward(_ sender: AnyObject) {
		print("INFO [AdvancedViewController]: buttonForward()")
		sliderThrottle.setValue(Float(ControlSignalManager.sharedInstance.defaultThrottleForward) / 100, animated: true)
		sliderYaw.setValue(Float(ControlSignalManager.sharedInstance.defaultYawForward) / 100, animated: true)
		sliderPitch.setValue(Float(ControlSignalManager.sharedInstance.defaultPitchForward) / 100, animated: true)
		referenceTiltX = 0
		referenceTiltY = 0
		ControlSignalManager.sharedInstance.updateControlSignal()
	}
	
	@IBOutlet weak var buttonLeft: UIButton!
	@IBAction func buttonLeft(_ sender: AnyObject) {
		print("INFO [AdvancedViewController]: buttonLeft()")
		sliderThrottle.setValue(Float(ControlSignalManager.sharedInstance.defaultThrottleLeft) / 100, animated: true)
		sliderYaw.setValue(Float(ControlSignalManager.sharedInstance.defaultYawLeft) / 100, animated: true)
		sliderPitch.setValue(Float(ControlSignalManager.sharedInstance.defaultPitchLeft) / 100, animated: true)
		referenceTiltX = 0
		referenceTiltY = 0
		ControlSignalManager.sharedInstance.updateControlSignal()
	}
	
	@IBOutlet weak var buttonRight: UIButton!
	@IBAction func buttonRight(_ sender: AnyObject) {
		print("INFO [AdvancedViewController]: buttonRight()")
		sliderThrottle.setValue(Float(ControlSignalManager.sharedInstance.defaultThrottleRight) / 100, animated: true)
		sliderYaw.setValue(Float(ControlSignalManager.sharedInstance.defaultYawRight) / 100, animated: true)
		sliderPitch.setValue(Float(ControlSignalManager.sharedInstance.defaultPitchRight) / 100, animated: true)
		referenceTiltX = 0
		referenceTiltY = 0
		ControlSignalManager.sharedInstance.updateControlSignal()
	}
	
	@IBOutlet weak var switchTiltControl: UISwitch!
	func updateTiltControl() {
		print("INFO [AdvancedViewController]: updateTiltControl(): \(switchTiltControl.isOn)")
		switchThrottleOnly.isEnabled = switchTiltControl.isOn
		if (switchTiltControl.isOn) {
			
			motionManager.startAccelerometerUpdates(to: OperationQueue()) { data, error in
				guard data != nil else {
					print("There was an error: \(error)")
					return
				}
				//			self.xAxisAcceleration = CGFloat(data!.acceleration.x)
				self.outputAccData(acceleration: (data?.acceleration)!)
			}
			
		} else {
			switchThrottleOnly.setOn(false, animated: true)
			self.motionManager.stopAccelerometerUpdates()
		}
	}
	
	@IBOutlet weak var switchThrottleOnly: UISwitch!
	func updateThrottleOnly() {
		print("INFO [AdvancedViewController]: updateThrottleOnly(): \(switchThrottleOnly.isOn)")
	}
	
	func outputAccData(acceleration: CMAcceleration) {
		print("INFO [AdvancedViewController]: outputAccData(): \(acceleration): \(UIDevice.current.orientation.rawValue)")
		
		//		print("INFO [AdvancedViewController]: orientation: \(UIDevice.current.orientation.rawValue)")
		
		if !(switchThrottleOnly.isOn) {
			
			// Pitch / Yaw Title Control
			
			var tiltX:Float = Float(acceleration.x)
			var tiltY:Float = Float(acceleration.y * -1)
			
			switch UIDevice.current.orientation{
			case .portrait:
				//				print("INFO [AdvancedViewController]: portrait: \(UIDevice.current.orientation.rawValue)")
				break
			case .portraitUpsideDown:
				//				print("INFO [AdvancedViewController]: portportraitUpsideDownrait: \(UIDevice.current.orientation.rawValue)")
				tiltX = Float(acceleration.x * -1)
				tiltY = Float(acceleration.y)
			case .landscapeLeft:
				//				print("INFO [AdvancedViewController]: landscapeLeft: \(UIDevice.current.orientation.rawValue)")
				tiltX = Float(acceleration.y * -1)
				tiltY = Float(acceleration.x * -1)
			case .landscapeRight:
				//				print("INFO [AdvancedViewController]: landscapeRight: \(UIDevice.current.orientation.rawValue)")
				tiltX = Float(acceleration.y)
				tiltY = Float(acceleration.x)
			default:
				//				print("INFO [AdvancedViewController]: default: \(UIDevice.current.orientation.rawValue)")
				// Abort if too flat to get orientation
				return
				//				break
			}
			
			if (referenceTiltX == 0.0) {
				referenceTiltX = tiltX
				referenceTiltY = tiltY
			}
			
			let newYaw:Float = Float(ControlSignalManager.sharedInstance.defaultYawHover) / 100 + (tiltX - referenceTiltX)
			let newPitch:Float = Float(ControlSignalManager.sharedInstance.defaultYawHover) / 100 - (tiltY - referenceTiltY)
			
			// Filter changes below titleSensorMinimumThreshold
			if (((Float(newYaw) > sliderYaw.value) && (Float(newYaw) - sliderYaw.value > tiltSensorMinimumThreshold)) ||
				((newYaw < sliderYaw.value) && (sliderYaw.value - newYaw > tiltSensorMinimumThreshold))) {
				
				// UI updates must happen on main thread
				DispatchQueue.global(qos: .background).async {
					DispatchQueue.main.async {
						self.sliderYaw.setValue(Float(newYaw), animated: true)
					}
				}
			}
			
			if (((newPitch > sliderPitch.value) && (newPitch - sliderPitch.value > tiltSensorMinimumThreshold)) ||
				((newPitch < sliderPitch.value) && (sliderPitch.value - newPitch > tiltSensorMinimumThreshold))) {
				
				DispatchQueue.global(qos: .background).async {
					DispatchQueue.main.async {
						self.sliderPitch.setValue(newPitch, animated: true)
					}
				}
			}
			
		} else {
			
			// Throttle Tilt Control
			
			let tiltY:Float = Float(acceleration.y * 1)  // invert the Y axis so that negative values equal forward
			
			if (referenceTiltY == 0) {
				referenceTiltY = tiltY;
			}
			
			let newThrottle:Float = Float(ControlSignalManager.sharedInstance.defaultThrottleHover) - (tiltY - referenceTiltY)
			
			if (((newThrottle > sliderThrottle.value) && (newThrottle - sliderThrottle.value > tiltSensorMinimumThreshold)) ||
				((newThrottle < sliderThrottle.value) && (sliderThrottle.value - newThrottle > tiltSensorMinimumThreshold))) {
				
				DispatchQueue.global(qos: .background).async {
					DispatchQueue.main.async {
						self.sliderThrottle.setValue(newThrottle, animated: true)
					}
				}
			}
			
		}
		
		ControlSignalManager.sharedInstance.updateControlSignal()
		
	}
	
	override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
		print("INFO [AdvancedViewController]: outputfromInterfaceOrientationAccData(): \(UIDevice.current.orientation.hashValue)")
		referenceTiltX = 0
		referenceTiltY = 0
	}
	
}
