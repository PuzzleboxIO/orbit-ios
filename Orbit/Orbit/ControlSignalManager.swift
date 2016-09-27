//
//  ControlSignalManager.swift
//  Orbit
//
//  Created by Steve Castellotti on 9/19/16.
//  Copyright © 2016 Puzzlebox. All rights reserved.
//

import Foundation
import AVFoundation

private let USE_AUDIO_GENERATOR:Bool = true
private var audioPlayer: AVFoundation.AVAudioPlayer? = nil

private let defaultThrottle:Int = 80
private let defaultYaw:Int = 47 // 0.78 is the actual setting required, but 47 is the inverse (125 - 78)
private let defaultPitch:Int = 31

class ControlSignalManager: NSObject, SynapseDelegate {
	
	var audioPlayer: AudioGenerator
	
	let defaultThrottleHover:Int = defaultThrottle
	let defaultYawHover:Int = defaultYaw
	let defaultPitchHover:Int = defaultPitch
	
	let defaultThrottleForward:Int = defaultThrottle
	let defaultYawForward:Int = defaultYaw
	let defaultPitchForward:Int = defaultPitch + 20
	
	let defaultThrottleLeft:Int = defaultThrottle
	let defaultYawLeft:Int = defaultYaw - 50
	let defaultPitchLeft:Int = defaultPitch
	
	let defaultThrottleRight:Int = defaultThrottle
	let defaultYawRight:Int = defaultYaw + 30
	let defaultPitchRight:Int = defaultPitch
	
	var throttle:Int = defaultThrottle
	var yaw:Int = defaultYaw
	var pitch:Int = defaultPitch
	
	var isPlaying:Bool = false
	
	// MARK: Shared Instance
	
	static let sharedInstance : ControlSignalManager = {
		let instance = ControlSignalManager()
		return instance
	}()
	
	private override init() {
		audioPlayer = AudioGenerator.init()
		super.init()
	}
	
	func appStopped() {
		print("INFO [ControlSignalManager]: appStopped()")
		audioPlayer.stop()
	}
	
	func isVolumeMax() -> Bool {
		let volume = AVAudioSession.sharedInstance().outputVolume
		print("INFO [ControlSignalManager]: Output volume: \(volume)")
		return (volume.isEqual(to: 1.0))
	}
	
	func isHeadphoneJackPlugged() -> Bool {
		let route = AVAudioSession.sharedInstance().currentRoute
		return (route.outputs).filter({ $0.portType == AVAudioSessionPortHeadphones }).count > 0
	}
	
	func playTestSignal() {
		isPlaying = true
		audioPlayer.play(withThrottle: Int32(defaultThrottle), yaw: Int32(defaultYaw), pitch: Int32(defaultPitch))
	}
	
	func playControlSignal() {
		isPlaying = true
		audioPlayer.play(withThrottle: Int32(throttle), yaw: Int32(yaw), pitch: Int32(pitch))
	}
	
	func updateControlSignal() {
		if (isPlaying) {
			audioPlayer.play(withThrottle: Int32(throttle), yaw: Int32(yaw), pitch: Int32(pitch))
		}
	}
	
	func stopControlSignal(){
		audioPlayer.stop()
		isPlaying = false
	}
	
	func updatePower(powerLevel: Int){
		if (powerLevel > 0) && !(isPlaying) {
			playControlSignal()
		} else if (powerLevel == 0) && (isPlaying) {
			stopControlSignal()
		}
	}
	
	// MARK: SynapseDelegate
	
	func updateData() {
		print("INFO [ControlSignalManager]: updateData")
	}
	
	func updateStatus(){
		print("INFO [ControlSignalManager]: updateStatus")
	}
	
	func updateDevices(){
		print("INFO [ControlSignalManager]: updateDevices")
	}
	
	func updateDeviceConnection(connected:Bool) {
		print("INFO [ControlSignalManager]: updateDeviceConnection: connected: \(connected)")
	}
	
}
