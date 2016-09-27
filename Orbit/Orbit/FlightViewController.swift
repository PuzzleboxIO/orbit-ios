//
//  FlightViewController.swift
//  Orbit
//
//  Created by Steve Castellotti on 9/17/16.
//  Copyright © 2016 Puzzlebox. All rights reserved.
//

import UIKit

private let defaultargetAttention:Float = 0.72
private let defaultargetMeditationT:Float = 0.0

private let STATUS_DEFAULT:Int = 0
private let STATUS_CONNECTING:Int = 1
private let STATUS_CONNECTED:Int = 2
private let STATUS_PROCESSING:Int = 3
private let STATUS_ACTIVE:Int = 4

class FlightViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, SynapseDelegate {
	
	let synapseProtocol:SynapseDelegate? = nil
	
	var currentImageStatus:Int = 0
	
	let minimumScoreTarget:Int = 40
	var scoreCurrent:Int = 0
	var scoreLast:Int = 0
	var scoreHigh:Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let transformProgress:CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 3.0)
		
		progressAttention.progressTintColor = UIColor.red
		progressAttention.transform = transformProgress
		sliderAttention.minimumTrackTintColor = UIColor.gray
		sliderAttention.value = defaultargetAttention
		progressMeditation.progressTintColor = UIColor.blue
		progressMeditation.transform = transformProgress
		sliderMeditation.minimumTrackTintColor = UIColor.gray
		sliderMeditation.value = defaultargetMeditationT
		progressSignal.progressTintColor = UIColor.green
		progressSignal.transform = transformProgress
		progressPower.progressTintColor = UIColor.yellow
		progressPower.transform = transformProgress
		
		setThresholds()
		sliderAttention.addTarget(self, action: #selector(FlightViewController.setThresholds), for: .valueChanged)
		sliderMeditation.addTarget(self, action: #selector(FlightViewController.setThresholds), for: .valueChanged)
		
		resetViews()
		
		
		// Synapse Manager
		SynapseManager.sharedInstance.synapseDelegate = self
		
		
		// Control Signal Manager
		//		NotificationCenter .default .addObserver(self, selector: #selector(FlightViewController.appStopped), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
		NotificationCenter .default .addObserver(self, selector: #selector(FlightViewController.appStopped), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
		
		
		print("INFO [FlightViewController]: isVolumeMax: \(ControlSignalManager.sharedInstance.isVolumeMax())")
		print("INFO [FlightViewController]: isHeadphoneJackPlugged: \(ControlSignalManager.sharedInstance.isHeadphoneJackPlugged())")
		
		
		devicePicker.delegate = self
		devicePicker.dataSource = self
		devicePicker.isHidden = true
		deviceToolbar.isHidden = true
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter .default .removeObserver(self)
	}
	
	func appStopped() {
		ControlSignalManager.sharedInstance.appStopped()
	}
	
	
	@IBOutlet weak var buttonConnect: UIBarButtonItem!
	@IBAction func buttonConnect(_ sender: UIBarButtonItem) {
		print("INFO [FlightViewController]: buttonConnect clicked")
		resetViews()
		SynapseManager.sharedInstance.connectSynapse()
	}
	
	@IBAction func buttonTest(_ sender: UIBarButtonItem) {
		print("INFO [FlightViewController]: buttonTest clicked")
		if (ControlSignalManager.sharedInstance.isPlaying){
			ControlSignalManager.sharedInstance.stopControlSignal()
		} else {
			ControlSignalManager.sharedInstance.playTestSignal()
		}
	}
	
	@IBOutlet weak var progressAttention: UIProgressView!
	@IBOutlet weak var labelAttentionPercent: UILabel!
	@IBOutlet weak var sliderAttention: UISlider!
	@IBOutlet weak var progressMeditation: UIProgressView!
	@IBOutlet weak var labelMeditationPercent: UILabel!
	@IBOutlet weak var sliderMeditation: UISlider!
	@IBOutlet weak var progressSignal: UIProgressView!
	@IBOutlet weak var labelSignalPercent: UILabel!
	@IBOutlet weak var progressPower: UIProgressView!
	@IBOutlet weak var labelPowerPercent: UILabel!
	@IBOutlet weak var labelScores: UILabel!
	@IBOutlet weak var imageViewStatus: UIImageView!
	
	@IBOutlet weak var devicePicker: UIPickerView!
	@IBOutlet weak var deviceToolbar: UIToolbar!
	
	@IBAction func buttonCancelDevice(_ sender: AnyObject) {
		deviceToolbar.isHidden = true
		devicePicker.isHidden = true
		SynapseManager.sharedInstance.nTGBleManager.candidateStopScan()
		SynapseManager.sharedInstance.resetDevices()
	}
	
	@IBAction func buttonSelectDevice(_ sender: AnyObject) {
		print("INFO [FlightViewController]: buttonSelectDevice()")
		
		deviceToolbar.isHidden = true
		devicePicker.isHidden = true
		
		SynapseManager.sharedInstance.nTGBleManager.candidateStopScan()
		
		if (SynapseManager.sharedInstance.devicesArray.count < 1) {
			return
		}
		
		let rowNumber:Int = devicePicker.selectedRow(inComponent: 0)
		
		if (rowNumber < 0) {
			print("WARNING [FlightViewController]: devicesArray row number: \(rowNumber)")
		} else {
			
			let deviceName:String = SynapseManager.sharedInstance.devicesArray[rowNumber]
			SynapseManager.sharedInstance.nTGBleManager.candidateConnect(deviceName)
			
			// now release the lists so that they are empty and prepared for the next time.
			
			SynapseManager.sharedInstance.devicesArray = []
			
			// put picker into a good state
			devicePicker.isUserInteractionEnabled = false
			devicePicker.reloadAllComponents()
			
		}
		
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		// only 1 scrollable list
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return SynapseManager.sharedInstance.devicesArray.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
		print ("INFO [FlightViewController]: pickerView(): titleForRow: \(row)")
		//		let listItem:String = SynapseManager.sharedInstance.devicesArray[row]
		
		//		let listItem:String = "MindWave Mobile Plus - Test"
		
		if (SynapseManager.sharedInstance.devicesArray.count <= 0) {
			print ("INFO [FlightViewController]: pickerView: No compatible EEG devices found")
			return "No compatible EEG devices found"
		}
		
		
		let listItem:String = "\(SynapseManager.sharedInstance.mfgIDArray[row]):\(SynapseManager.sharedInstance.devNameArray[row]):\(SynapseManager.sharedInstance.rssiArray[row])"
		
		print ("INFO [FlightViewController]: pickerView adding listItem: \(listItem)")
		
		return listItem
	}
	
	func updateDevices() {
		print ("INFO [FlightViewController]: updateDevicePicker()")
		DispatchQueue.global(qos: .background).async {
			DispatchQueue.main.async {
				self.devicePicker.reloadAllComponents()
				
				if (SynapseManager.sharedInstance.devicesArray.count > 0) {
					self.devicePicker.isUserInteractionEnabled = true
					self.devicePicker.isHidden = false
					self.deviceToolbar.isHidden = false
				} else {
					self.devicePicker.isUserInteractionEnabled = false
					self.devicePicker.isHidden = true
					self.deviceToolbar.isHidden = true
				}
				
			}
		}
	}
	
	func resetViews() {
		print("INFO [FlightViewController]: resetViews()")
		progressAttention.progress = 0
		labelAttentionPercent.text = "0%"
		progressMeditation.progress = 0
		labelMeditationPercent.text = "0%"
		progressSignal.progress = 0
		labelSignalPercent.text = "0%"
		progressPower.progress = 0
		labelPowerPercent.text = "0%"
		updateStatusImage(status: STATUS_DEFAULT)
	}
	
	func updateStatusImage(status: Int){
		print("INFO [FlightViewController]: updateStatusImage(): \(status)")
		if (status != currentImageStatus) {
			imageViewStatus.image = UIImage(named: "status_\(status)")
			currentImageStatus = status
		}
	}
	
	func setThresholds(){
		print("New Attention: \(sliderAttention.value)")
		print("New Meditation: \(sliderMeditation.value)")
		
		SynapseManager.sharedInstance.updatePowerTargets(attention: sliderAttention.value, meditation: sliderMeditation.value)
		SynapseManager.sharedInstance.updatePowerLevel()
		
	}
	
	//// MARK: Synapse delegate
	//extension FlightViewController: SynapseProtocol {
	func updateData() {
		//		print("INFO [FlightViewController]: updateData()")
		//
		//		print("INFO [FlightViewController]: onDataReceived: datatype: CODE_POOR_SIGNAL: \(SynapseManager.sharedInstance.signalLevel)")
		//		print("INFO [FlightViewController]: onDataReceived: datatype: CODE_ATTENTION: \(SynapseManager.sharedInstance.attentionLevel)")
		//		print("INFO [FlightViewController]: onDataReceived: datatype: CODE_MEDITATION: \(SynapseManager.sharedInstance.meditationLevel)")
		
		DispatchQueue.global(qos: .background).async {
			// This section is run on the background queue
			
			DispatchQueue.main.async {
				// This section is run on the main queue, after any previous code in outer block
				
				// Set Attention and Meditation to zero if we've lost signal
				if (SynapseManager.sharedInstance.signalLevel < 100) {
					SynapseManager.sharedInstance.attentionLevel = 0
					SynapseManager.sharedInstance.meditationLevel = 0
					SynapseManager.sharedInstance.updatePowerLevel()
					if (self.currentImageStatus != STATUS_CONNECTED) {
						self.updateStatusImage(status: STATUS_CONNECTED)
					}
					
				} else if (SynapseManager.sharedInstance.signalLevel == 100) {
					
					if (SynapseManager.sharedInstance.powerLevel <= 0) {
						if (self.currentImageStatus != STATUS_PROCESSING) {
							self.updateStatusImage(status: STATUS_PROCESSING)
						}
					} else if (self.currentImageStatus != STATUS_ACTIVE) {
						self.updateStatusImage(status: STATUS_ACTIVE)
					}
					
				}
				
				self.progressSignal.setProgress(Float(SynapseManager.sharedInstance.signalLevel) / 100, animated: true)
				self.labelSignalPercent.text = "\(SynapseManager.sharedInstance.signalLevel)%"
				self.progressAttention.setProgress(Float(SynapseManager.sharedInstance.attentionLevel) / 100, animated: true)
				self.labelAttentionPercent.text = "\(SynapseManager.sharedInstance.attentionLevel)%"
				self.progressMeditation.setProgress(Float(SynapseManager.sharedInstance.meditationLevel) / 100, animated: true)
				self.labelMeditationPercent.text = "\(SynapseManager.sharedInstance.meditationLevel)%"
				self.progressPower.setProgress(Float(SynapseManager.sharedInstance.powerLevel) / 100, animated: true)
				self.labelPowerPercent.text = "\(SynapseManager.sharedInstance.powerLevel)%"
				
				self.updateScores()
				
			}
		}
	}
	
	func updateStatus() {
		print("INFO [FlightViewController]: updateStatus()")
		DispatchQueue.global(qos: .background).async {
			
			DispatchQueue.main.async {
				switch SynapseManager.sharedInstance.tgConnectionState {
					
				case .STATE_INIT:
					//					self.updateStatusImage(status: STATUS_DEFAULT)
					self.updateStatusImage(status: STATUS_CONNECTING)
				case .STATE_CONNECTING:
					self.updateStatusImage(status: STATUS_CONNECTING)
				case .STATE_CONNECTED:
					self.updateStatusImage(status: STATUS_CONNECTING)
				case .STATE_WORKING:
					self.buttonConnect.title = "Disconnect"
					self.updateStatusImage(status: STATUS_CONNECTED)
				case .STATE_STOPPED:
					self.buttonConnect.title = "Connect"
					self.updateStatusImage(status: STATUS_DEFAULT)
				case .STATE_DISCONNECTED:
					self.buttonConnect.title = "Connect"
					self.updateStatusImage(status: STATUS_DEFAULT)
					self.resetViews()
				case .STATE_COMPLETE:
					break
				case .STATE_RECORDING_START:
					break
				case .STATE_RECORDING_END:
					break
				case .STATE_FAILED:
					break
				case .STATE_ERROR:
					break
				}
			}
		}
	}
	
	func updateDeviceConnection(connected:Bool) {
		print("INFO [FlightViewController]: updateDeviceConnection(): connected: \(connected)")
		if (connected) {
			self.buttonConnect.title = "Disconnect"
		} else {
			self.buttonConnect.title = "Connect"
			resetViews()
		}
	}
	
	func updateScores() {
		
		/**
		* Score points based on target slider levels
		* If you pass your goal with either Attention or Meditation
		* the higher target of the two will counts as points per second.
		*
		* Minimum threshold for points is set as "minimumScoreTarget"
		*
		* For example, assume minimumScoreTarget is 40%.
		* If your target Attention is 60% and you go past to reach 80%
		* you will receive 20 points per second (60-40). If your
		* target is 80% and you reach 80% you will receive 40
		* points per second (80-40).
		*
		* You can set both Attention and Meditation targets at the
		* same time. Reaching either will fly the helicopter but you
		* will only receive points for the higher-scoring target of
		* the two.
		*
		*/
		
		print("INFO [FlightViewController]: updateScores()")
		
		var eegAttentionScore:Int = 0
		let eegAttention:Int = Int(progressAttention.progress * 100)
		let eegAttentionTarget:Int = Int(sliderAttention.value * 100)
		
		var eegMeditationScore:Int = 0
		let eegMeditation:Int = Int(progressMeditation.progress * 100)
		let eegMeditationTarget:Int = Int(sliderMeditation.value * 100)
		
		if ((eegAttention >= eegAttentionTarget) &&
			(eegAttentionTarget > minimumScoreTarget)) {
			eegAttentionScore = eegAttentionTarget - minimumScoreTarget
		}
		
		if ((eegMeditation >= eegMeditationTarget) &&
			(eegMeditationTarget > minimumScoreTarget)) {
			eegMeditationScore = eegMeditationTarget - minimumScoreTarget
		}
		
		if (eegAttentionScore > eegMeditationScore) {
			scoreCurrent = scoreCurrent + eegAttentionScore
		} else {
			scoreCurrent = scoreCurrent + eegMeditationScore
		}
		
		// High score
		if (scoreCurrent > scoreHigh) {
			scoreHigh = scoreCurrent
		}
		
		// Reset score
		if (progressPower.progress == 0) {
			resetCurrentScore()
		}
		
		// Catch anyone gaming the system with one slider
		// below the minimum threshold and the other over.
		// For example, setting Meditation to 1% will keep helicopter
		// activated even if Attention is below target
		if ((eegAttention < eegAttentionTarget) && (eegMeditation < minimumScoreTarget)) {
			resetCurrentScore()
		}
		
		if ((eegMeditation < eegMeditationTarget) && (eegAttention < minimumScoreTarget)) {
			resetCurrentScore()
		}
		
		if ((eegAttention < minimumScoreTarget) && (eegMeditation < minimumScoreTarget)) {
			resetCurrentScore()
		}
		
		displayScore()
		
	}
	
	func displayScore() {
		
		print("INFO [FlightViewController]: displayScore()")
		
		var newScore:String = "Scores      Current: \(scoreCurrent)    Last: \(scoreLast)    High: \(scoreHigh)"
		
		if (newScore.characters.count >= 50) {
			newScore = "Scores  Current: \(scoreCurrent)  Last: \(scoreLast)  High: \(scoreHigh)"
		}
		
		if (newScore.characters.count >= 50) {
			newScore = "Scores Current: \(scoreCurrent) Last: \(scoreLast) High: \(scoreHigh)"
		}
		
		print("INFO [FlightViewController]: newScore: \(newScore)")
		
		if (labelScores.text != newScore) {
			self.labelScores.text = newScore
		}
		
	}
	
	func resetCurrentScore() {
		
		print("INFO [FlightViewController]: resetCurrentScore()")
		
		if (scoreCurrent > 0) {
			scoreLast = scoreCurrent
		}
		
		scoreCurrent = 0
		
	}
	
	
}

