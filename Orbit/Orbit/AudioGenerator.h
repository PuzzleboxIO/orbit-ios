//
//  AudioGenerator.h
//  orbit
//
//  Copyright (c) 2013 Puzzlebox Productions, LLC. All rights reserved.
//  Originally created by Jonathon Horsman.
//
//  This code is released under the GNU Public License (GPL) version 2
//  For more information please refer to http://www.gnu.org/copyleft/gpl.html
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVFoundation.h>

@interface AudioGenerator : NSObject

@property int yaw, pitch, throttle;

- (void) playWithThrottle: (int)throttle yaw: (int)yaw pitch: (int)pitch;
- (void) stop;

@end
