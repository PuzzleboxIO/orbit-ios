//
//  SynapseManager.swift
//  Orbit
//
//  Created by Steve Castellotti on 9/20/16.
//  Copyright © 2016 Puzzlebox. All rights reserved.
//

import Foundation

//	private let enableSDKLog: Bool = true
private let enableSDKLog: Bool = false

protocol SynapseDelegate {
	func updateData()
	func updateStatus()
	func updateDevices()
	func updateDeviceConnection(connected:Bool)
}

class SynapseManager: NSObject, TGStreamDelegate, MWMDeviceDelegate, TGBleManagerDelegate {
	
	var synapseDelegate: SynapseDelegate?
	
	// Stream SDK
	let tgStream:TGStream = TGStream.sharedInstance()
	var tgConnectionState: ConnectionStates = .STATE_DISCONNECTED
	
	// MWM SDK
	let mDevice:MWMDevice = MWMDevice.sharedInstance()
	let nTGBleManager:TGBleManager = TGBleManager.sharedTGBleManager(DeviceType.MWM)
	var devicesArray:[String] = []
	var rssiArray:[NSNumber] = []
	var devNameArray:[String] = []
	var mfgIDArray:[String] = []
	
	// Local
	var attentionLevel: Int = 0
	var meditationLevel: Int = 0
	var signalLevel: Int = 0
	var powerLevel: Int = 0
	
	//	var targetAttention:Float = 0.72
	//	var targetMeditation:Float = 0.0
	var targetAttention:Int = 72
	var targetMeditation:Int = 0
	
	// MARK: Shared Instance
	
	static let sharedInstance : SynapseManager = {
		let instance = SynapseManager()
		return instance
	}()
	
	// MARK: Local Variable
	
	var emptyStringArray : [String]? = nil
	
	// MARK: Init
	
	//	private convenience override init() {
	//		print("INFO [SynapseManager]: private convenience override init()")
	//		self.init(array : [])
	//	}
	//
	//	// MARK: Init Array
	//
	//	//	init( array : [String]) {
	//	private init( array : [String]) {
	//		print("INFO [SynapseManager]: private init( array : [String])")
	//		emptyStringArray = array
	//
	//		// StreamSDK Delegate
	//		super.init()
	//		self.init()
	
	private override init() {
		super.init()
		
		// StreamSDK Delegate
		tgStream.delegate = self
		tgStream.enableLog(enableSDKLog)
		print("INFO [SynapseManager]: Stream SDK version: \(tgStream.getVersion())")
		
		// MWM SDK Delegate
		mDevice.delegate = self
		//		nTGBleManager.enableLogging() // enable enhanced log messages
		nTGBleManager.setupManager(true) // manualMode enabled
		nTGBleManager.stopLogging() // disable enhanced log messages
		nTGBleManager.delegate = self
	}
	
	func test(command: String) {
		print("INFO [SynapseManager]: test: \(command)")
	}
	
	func updatePowerTargets(attention: Float, meditation: Float) {
		targetAttention = Int(attention * 100)
		targetMeditation = Int(meditation * 100)
	}
	
	func updatePowerLevel() {
		var powerLevel:Int = 0
		
		if (attentionLevel >= targetAttention) && (targetAttention > 0) {
			powerLevel += attentionLevel
		}
		
		if (meditationLevel >= targetMeditation) && (targetMeditation > 0) {
			powerLevel += meditationLevel
		}
		
		if powerLevel > 100 {
			powerLevel = 100
		}
		
		self.powerLevel = powerLevel
		print("INFO [updatePowerLevel]: powerLevel: \(powerLevel)")
		
		ControlSignalManager.sharedInstance.updatePower(powerLevel: powerLevel)
	}
	
	func connectSynapse() {
		
		print("INFO [SynapseManager]: connectSynapse()")
		
		resetDevices()
		
		switch tgConnectionState {
		case .STATE_INIT:
			connectToThinkGearDevice()
		case .STATE_CONNECTING:
			break
		case .STATE_CONNECTED:
			connectToThinkGearDevice()
		case .STATE_WORKING:
			disconnectFromThinkGearDevice()
		case .STATE_STOPPED:
			connectToThinkGearDevice()
		case .STATE_DISCONNECTED:
			connectToThinkGearDevice()
		case .STATE_COMPLETE:
			connectToThinkGearDevice()
		case .STATE_RECORDING_START:
			disconnectFromThinkGearDevice()
		case .STATE_RECORDING_END:
			disconnectFromThinkGearDevice()
		case .STATE_FAILED:
			connectToThinkGearDevice()
		case .STATE_ERROR:
			connectToThinkGearDevice()
		}
		
	}
	
	func connectToMindWaveMobilePlus() {
		print ("INFO [SynapseManager]: connectToMindWaveMobilePlus()")
		
		let nameList = ["SEAGULL", "Seagull", "WAT Phase 2", "SG DEV", "Pelican", "MindWave Mobile"]
		
		nTGBleManager.candidateScan(nameList)
	}
	
	
	//}
	//
	//// MARK: ThinkGear accessory delegate
	//extension SynapseManager: NSObject, TGStreamDelegate {
	
	func onDataReceived(_ datatype: Int, data: Int32, obj: NSObject!, deviceType: DEVICE_TYPE) {
		
		//		print("INFO [SynapseManager]: onDataReceived")
		
		switch datatype {
		case Int(MindDataType.CODE_POOR_SIGNAL.rawValue):
			print("INFO [SynapseManager]: onDataReceived: datatype: CODE_POOR_SIGNAL: \(data)")
			signalLevel = Int(data)
			
			if (signalLevel == 0) {
				signalLevel = 100
			} else {
				if (signalLevel >= 200) {
					signalLevel = 0
					//				} else {
					//					signalLevel = 100 - signalLevel
				}
			}
			
		case Int(MindDataType.CODE_ATTENTION.rawValue):
			print("INFO [SynapseManager]: onDataReceived: datatype: CODE_ATTENTION: \(data)")
			attentionLevel = Int(data)
		case Int(MindDataType.CODE_MEDITATION.rawValue):
			print("INFO [SynapseManager]: onDataReceived: datatype: CODE_MEDITATION: \(data)")
			meditationLevel = Int(data)
			
			updatePowerLevel()
			
			// Update delegates when Meditation value received because it always seems to be issued last from ThinkGear Stream
			synapseDelegate?.updateData()
			
		case Int(MindDataType.CODE_EEGPOWER.rawValue):
			break
		case Int(MindDataType.CODE_RAW.rawValue):
			break
		default:
			break
		}
		
	}
	
	func onStatesChanged(_ connectionState: ConnectionStates) {
		print("INFO [SynapseManager]: onStatesChanged")
		
		self.tgConnectionState = connectionState
		
		switch connectionState {
			
		case .STATE_INIT:
			print("INFO [SynapseManager]: 0 - STATE_INIT")
		case .STATE_CONNECTING:
			print("INFO [SynapseManager]: 1 - STATE_CONNECTING")
		case .STATE_CONNECTED:
			print("INFO [SynapseManager]: 2 - STATE_CONNECTED")
		// This will be reached when a legacy MindWave Mobile auto-connects via Bluetooth
		case .STATE_WORKING:
			print("INFO [SynapseManager]: 3 - STATE_WORKING")
		case .STATE_STOPPED:
			print("INFO [SynapseManager]: 4 - STATE_STOPPED")
			ControlSignalManager.sharedInstance.stopControlSignal()
		case .STATE_DISCONNECTED:
			print("INFO [SynapseManager]: 5 - STATE_DISCONNECTED")
			ControlSignalManager.sharedInstance.stopControlSignal()
		case .STATE_COMPLETE:
			print("INFO [SynapseManager]: 6 - STATE_COMPLETE")
		case .STATE_RECORDING_START:
			print("INFO [SynapseManager]: 7 - STATE_RECORDING_START")
		case .STATE_RECORDING_END:
			print("INFO [SynapseManager]: 8 - STATE_RECORDING_END")
		case .STATE_FAILED:
			print("INFO [SynapseManager]: 100 - STATE_FAILED")
		case .STATE_ERROR:
			print("INFO [SynapseManager]: 101 - STATE_ERROR")
			
			
			connectToMindWaveMobilePlus()
			
			
			disconnectFromThinkGearDevice()
			ControlSignalManager.sharedInstance.stopControlSignal()
			//			print("WARN [FlightViewController]: Re-initializing ThinkGear Stream")
			//			tgStream = TGStream.init()
			
		}
		
		synapseDelegate?.updateStatus()
		
	}
	
	func connectToThinkGearDevice() {
		print("INFO [SynapseManager]: Connecting to ThinkGear device")
		//		tgStream.tearDownAccessorySession()
		tgStream.initConnectWithAccessorySession()
		//		updateStatusImage(status: STATUS_CONNECTING)
		//
		//		//		let filePath:String = Bundle.main.path(forResource: "sample_data", ofType: "txt")!
		//		//		tgStream.initConnect(withFile: filePath)
		
		
	}
	
	func disconnectFromThinkGearDevice() {
		print("INFO [SynapseManager]: Disconnecting from ThinkGear device")
		tgStream.tearDownAccessorySession()
		//		mDevice.teardownManager() TODO
		//		updateStatusImage(status: STATUS_DEFAULT)
		//		resetViews()
		//		//		tgStream.initConnectWithAccessorySession()
	}
	
	
	// MARK: MWM SDK delegate
	func eegStarting(_ time: Date!, sampleRate: Int32, realTime rt: Bool, comment: String!) {
		print("INFO [SynapseManager]: eegStarting: time: \(time) sampleRate: \(sampleRate) realTime: \(rt) comment: \(comment)")
	}
	
	func eegStop(_ result: TGeegResult) {
		
		var message:String
		
		if (result == TGeegResult.terminatedNormally) {
			message = "EEG Recording Ended Normally"
		}
		else if (result == TGeegResult.terminatedNoData) {
			message = "No Data Received, Try Again, You must touch the Sensor"
		}
		else if (result == TGeegResult.terminatedDataStopped) {
			message = "Data Stopped, you must maintain contact with the finger Sensor"
		}
		else if (result == TGeegResult.terminatedLostConnection) {
			message = "BLE Connection has been lost"
		}
		else {
			message = "Unexpected result, code: \(result)"
		}
		
		print("INFO [SynapseManager]: eegStop: \(message)")
	}
	
	func eegPowerLowBeta(_ lowBeta: Int32, highBeta: Int32, lowGamma: Int32, midGamma: Int32) {
		print("INFO [SynapseManager]: eegPowerLowBeta(): lowBeta: \(lowBeta) highBeta: \(highBeta) lowGamma: \(lowGamma) midGamma: \(midGamma)")
	}
	
	func eegPowerDelta(_ delta: Int32, theta: Int32, lowAlpha lowAplpha: Int32, highAlpha: Int32) {
		print("INFO [SynapseManager]: eegPowerDelta(): \(delta) theta: \(theta) lowAlpha: \(lowAplpha) highAlpha: \(highAlpha)")
	}
	
	func eSense(_ poorSignal: Int32, attention: Int32, meditation: Int32) {
		print("INFO [SynapseManager]: eSense(): poorSignal: \(eSense) attention: \(attention) meditation: \(meditation)")
		
		signalLevel = Int(poorSignal)
		
		if (signalLevel == 0) {
			signalLevel = 100
		} else {
			if (signalLevel >= 200) {
				signalLevel = 0
			}
		}
		
		attentionLevel = Int(attention)
		meditationLevel = Int(meditation)
		
		updatePowerLevel()
		
		synapseDelegate?.updateData()
		
	}
	
	func mwmBaudRate(_ baudRate: Int32, notchFilter: Int32) {
		print("INFO [SynapseManager]: mwmBaudRate(): baudRate: \(baudRate) notchFilter: \(notchFilter)")
	}
	
	func candidateFound(_ devName: String!, rssi: NSNumber!, mfgID: String!, candidateID: String!) {
		//		print("INFO [SynapseManager]: candidateFound(): devName: \(devName) rssi: \(rssi) mfgID: \(mfgID) rssi: \(rssi)")
		
		if mfgID == nil || mfgID == "" {
			return
		}
		
		if !(devicesArray.contains(candidateID)) {
			
			print("INFO [SynapseManager]: candidateFound(): devName: \(devName) rssi: \(rssi) mfgID: \(mfgID) rssi: \(rssi)")
			
			devicesArray.append(candidateID)
			rssiArray.append(rssi)
			devNameArray.append(devName)
			mfgIDArray.append(mfgID)
			
			synapseDelegate?.updateDevices()
		}
	}
	
	func bleDidConnect() {
		print("INFO [SynapseManager]: bleDidConnect()")
		mDevice.tryStartESense()
		synapseDelegate?.updateDeviceConnection(connected: true)
	}
	
	func bleDidDisconnect() {
		print("INFO [SynapseManager]: bleDidDisconnect()")
		ControlSignalManager.sharedInstance.stopControlSignal()
		mDevice.tryStopESense()
		synapseDelegate?.updateDeviceConnection(connected: false)
	}
	
	func bleLostConnect() {
		print("INFO [SynapseManager]: bleLostConnect()")
		ControlSignalManager.sharedInstance.stopControlSignal()
		mDevice.tryStopESense()
		synapseDelegate?.updateDeviceConnection(connected: false)
	}
	
	func exceptionMessage(_ eventType: TGBleExceptionEvent) {
		
		var message:String = ""
		
		if (eventType == TGBleExceptionEvent.configurationModeCanNotBeChanged) {
			message = "Exception Message - Ble Connection Mode CAN NOT be changed"
		}
		else if (eventType == TGBleExceptionEvent.failedOtherOperationInProgress) {
			message = "Exception Message - Another Operation is Already in Progress"
		}
			
		else if (eventType == TGBleExceptionEvent.connectFailedSuspectKeyMismatch) {
			message = "Exception Message - Device appears to be paired, possible encryption key mismatch, hold side button for 10 seconds to reboot"
		}
		else if (eventType == TGBleExceptionEvent.storedConnectionInvalid) //stored connection
		{
			//			[self onSCandidateClicked:nil];
			message = "Exception Detected, code: \(eventType)"
		}
		else
		{
			message = "Exception Detected, code: \(eventType)"
		}
		
		print("INFO [SynapseManager]: exceptionMessage(): \(message)")
	}
	
	func resetDevices() {
		print("INFO [SynapseManager]: resetDevices()")
		devicesArray = []
		rssiArray = []
		devNameArray = []
		mfgIDArray = []
	}
	
}
