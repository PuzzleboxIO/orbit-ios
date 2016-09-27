//
//  AudioGenerator.m
//  orbit
//
//  Copyright (c) 2013 Puzzlebox Productions, LLC. All rights reserved.
//  Originally created by Jonathon Horsman.
//
//  This code is released under the GNU Public License (GPL) version 2
//  For more information please refer to http://www.gnu.org/copyleft/gpl.html
//

#import "AudioGenerator.h"



#define SAMPLE_RATE_F 48000.f
#define SIGNAL_WAVE_FREQUENCY 100.f


/**
 * Half periods in the audio code, in seconds.
 */



//#define longHIGH 0.000829649
//#define longLOW 0.000797027
//#define shortHIGH 0.000412649
//#define shortLOW 0.000378351

#define longHIGH 0.00089583333
#define longLOW 0.00070833333
#define shortHIGH 0.00045833333
#define shortLOW 0.0003125

#define USEFUL_BIT_SIZE 29

#define IDLE_TIME_MS 84


volatile BOOL g_refreshCtrCode = NO;

//22 = 0.00045833333
//15 = 0.0003125
//
//43 = 0.00089583333
//34 = 0.00070833333
//
//14 = 0.00029166667
//131 = 0.0027291667
//16 = 0.00033333333
//12 = 0.00025
//3 = 0.0000625
//18 = 0.000375
//3998 = 0.083291667
//4049 = 0.084354167

#define INIT_CODE_DATA_SIZE 202


double     g_initCodeTime[INIT_CODE_DATA_SIZE] = {
    
    0.00089583333, 0.0003125,
    0.00089583333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    
    0.083291667,
    
    0.00089583333, 0.0003125,
    0.00089583333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    0.00089583333, 0.00070833333,
    0.00045833333, 0.0003125,
    0.00089583333, 0.00070833333,
    
    0.083291667,
    
    0.00029166667, 0.0027291667,
    0.00029166667, 0.0027291667,
    0.00029166667, 0.00033333333,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    
    0.084354167,
    
    0.00029166667, 0.0027291667,
    0.00029166667, 0.0027291667,
    0.00029166667, 0.00033333333,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    
    0.084354167,
    
    0.00029166667, 0.0027291667,
    0.00029166667, 0.0027291667,
    0.00025, 0.000375,
    0.00025, 0.000375,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    
    0.084354167,
    
    0.00029166667, 0.0027291667,
    0.00029166667, 0.0027291667,
    0.00025, 0.000375,
    0.00025, 0.000375,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    0.00025, 0.0000625,
    
    0.084354167
    
};


BOOL     g_initCodeUD[INIT_CODE_DATA_SIZE] = {
    
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    
    NO,
    
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    
    NO,
    
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    
    NO,
    
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    
    NO,
    
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    
    NO,
    
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    YES, NO,
    
    NO,
    
};


@interface AudioGenerator()
{
    
    int         m_initCodeLen[INIT_CODE_DATA_SIZE];
    
    AudioUnit   m_audioUnit;
    Float32     m_sampleRate;
    BOOL        m_isPlaying;
    double      m_signalPhaseCur;

    
    int         waveBit_01_len[2];
    Float32     *waveBit_01[2];
    
    int         ctrWaveMaxLen;
    int         ctrWaveDataLen;
    Float32     *ctrWave;
    
    int         ctrWaveHeadLen;
    Float32     *ctrWaveHead;
    
    int         ctrWaveReadIdx;
    
    int         idleWaveLen;
    int         idleWaveReadIdx;
    
    
    
    BOOL        sendInitWave;
    
    int         initWaveSendLenIdx;
    int         initWaveSendLenIdxLenMax;
    int         initWaveSendLenIdxLenCur;
    
    Float32     initWaveCurAngle;
}

@end


@implementation AudioGenerator {
    
    float sampleTime;
    int longHighLength, shortHighLength, longZeroLength, longLowLength, mediumLowLength, shortLowLength, waveBitLength;
    float *waveLongHigh, *waveShortHigh, *waveLongZero, *waveLongLow, *waveMediumLow, *waveShortLow, *waveBit;
    
    
    
    int MAX_BUFFER_SIZE;

}

@synthesize yaw, pitch, throttle;

- (id) init
{
    self = [super init];
    if (self) {
        sampleTime = 1.0f / SAMPLE_RATE_F;
        
        [self prepareStaticArrays];
    }
    return self;
}

#pragma mark - ---- interface ----

- (void) playWithThrottle: (int)t yaw: (int)y pitch: (int)p
{
    self.yaw = y;
    self.pitch = p;
    self.throttle = t;
    
    [self audioUnitStart];
    
}


- (void) stop
{
    [self audioUnitStop];
}


#pragma mark - ---- Audio Unit func ----

- (void) audioUnitStart
{

    if (m_audioUnit == nil) {
        [self prepareAudioUnit];
        
        sendInitWave = YES;
        initWaveSendLenIdx = 0;
        initWaveSendLenIdxLenMax = m_initCodeLen[0];
        initWaveSendLenIdxLenCur = 0;
        initWaveCurAngle = 0.f;
    }
    
    if (!m_isPlaying) {
        
        [self updateCtrCode:NO];
        
        OSStatus status = AudioUnitInitialize(m_audioUnit);
        
        if (status != noErr) {
            NSLog(@"AudioUnitInitialize - error");
        }

        
        status = AudioOutputUnitStart(m_audioUnit);
        if (status != noErr) {
            NSLog(@"AudioOutputUnitStart - error");
        }
        
        m_isPlaying = YES;
    }
    else {
        [self updateCtrCode:YES];
    }

    
}


- (void) audioUnitStop
{
    
    if (m_isPlaying) {
        OSStatus status = AudioOutputUnitStop(m_audioUnit);
        if (status != noErr) {
            NSLog(@"AudioOutputUnitStop - error");
        }
        
        m_isPlaying = NO;
    }
    
    if (m_audioUnit) {
        OSStatus status = AudioUnitUninitialize(m_audioUnit);
        if (status != noErr) {
            NSLog(@"AudioUnitUninitialize - error");
        }
        
        status = AudioComponentInstanceDispose(m_audioUnit);
        if (status != noErr) {
            NSLog(@"AudioComponentInstanceDispose - error");
        }
        
        m_audioUnit = nil;
    }
    
    
}



- (void) prepareAudioUnit
{
    m_sampleRate = SAMPLE_RATE_F;
    m_isPlaying = NO;
    m_signalPhaseCur = 0.0;
    
    OSStatus status = noErr;
    
    AudioComponentDescription au_cd;
    au_cd.componentType = kAudioUnitType_Output;
    au_cd.componentSubType = kAudioUnitSubType_RemoteIO;
    au_cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    au_cd.componentFlags = 0;
    au_cd.componentFlagsMask = 0;
    
    AudioComponent component = AudioComponentFindNext(NULL, &au_cd);
    if (component == NULL) {
        NSLog(@"AudioComponentFindNext - error");
    }
    
    
    status = AudioComponentInstanceNew(component, &m_audioUnit);
    if (status != noErr) {
        NSLog(@"AudioComponentInstanceNew - error");
    }
    
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderAudioUnitCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
    status = AudioUnitSetProperty(m_audioUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         0,
                         &callbackStruct,
                         sizeof(AURenderCallbackStruct));
    
    if (status != noErr) {
        NSLog(@"kAudioUnitProperty_SetRenderCallback - error");
    }
    
    
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate         = m_sampleRate;
	streamFormat.mFormatID           = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags        = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mChannelsPerFrame   = 2;
	streamFormat.mBytesPerPacket     = sizeof(Float32);
	streamFormat.mBytesPerFrame      = sizeof(Float32);
	streamFormat.mFramesPerPacket    = 1;
	streamFormat.mBitsPerChannel     = 8 * sizeof(Float32);
    
	status = AudioUnitSetProperty(m_audioUnit,
						 kAudioUnitProperty_StreamFormat,
						 kAudioUnitScope_Input,
						 0,
						 &streamFormat,
						 sizeof(AudioStreamBasicDescription));
    
    if (status != noErr) {
        NSLog(@"kAudioUnitProperty_StreamFormat - error");
    }
    
}


OSStatus renderAudioUnitCallback(void*                       inRefCon,
                                   AudioUnitRenderActionFlags* ioActionFlags,
                                   const AudioTimeStamp*       inTimeStamp,
                                   UInt32                      inBusNumber,
                                   UInt32                      inNumberFrames,
                                   AudioBufferList*            ioData)
{
    AudioGenerator *generator = (__bridge AudioGenerator*)inRefCon;
    
    Float32 *ctr_buffer = ioData->mBuffers[0].mData;
    [generator writeCtrWaveToBuffer:ctr_buffer maxSize:inNumberFrames];
    
    Float32 *signal_buffer = ioData->mBuffers[1].mData;
    [generator writeSignalWaveToBuffer:signal_buffer maxSize:inNumberFrames];
    
    return noErr;
}


- (void)writeCtrWaveToBuffer:(Float32*)buffer maxSize:(UInt32)frames
{
    
    for (int i=0; i < frames; ++i) {
        
        if (g_refreshCtrCode) {
            ctrWaveReadIdx = 0;
            idleWaveReadIdx = 0;
            g_refreshCtrCode = NO;
            break;
        }
        
        if (sendInitWave) {
            
            double increment = M_PI/(g_initCodeTime[initWaveSendLenIdx] * SAMPLE_RATE_F);
            
            if (g_initCodeUD[initWaveSendLenIdx]) {
                *buffer++ = sinf(initWaveCurAngle);
                initWaveCurAngle += increment;
            }
            else {
                *buffer++ = 0.0f;
            }
            
            initWaveSendLenIdxLenCur++;
            
            if (initWaveSendLenIdxLenCur >= initWaveSendLenIdxLenMax) {
                initWaveSendLenIdx++;
                
                if (initWaveSendLenIdx >= INIT_CODE_DATA_SIZE) {
                    sendInitWave = NO;
                    continue;
                }
                else {
                    initWaveSendLenIdxLenMax = m_initCodeLen[initWaveSendLenIdx];
                    initWaveSendLenIdxLenCur = 0;
                    initWaveCurAngle = 0.f;
                }
                
                
            }
            
            
        }
        else {
            if (ctrWaveReadIdx < ctrWaveDataLen && idleWaveReadIdx == 0) {
                *buffer++ = ctrWave[ctrWaveReadIdx++];
            }
            else if (ctrWaveReadIdx >= ctrWaveDataLen && idleWaveReadIdx < idleWaveLen)
            {
                *buffer++ = 0.0f;
                idleWaveReadIdx++;
            }
            else if (ctrWaveReadIdx >= ctrWaveDataLen && idleWaveReadIdx >= idleWaveLen)
            {
                ctrWaveReadIdx = 0;
                idleWaveReadIdx = 0;
                *buffer++ = ctrWave[ctrWaveReadIdx++];
            }
        }
        
        
    }
}

- (void)writeSignalWaveToBuffer:(Float32*)buffer maxSize:(UInt32)frames
{
    double phase_step = SIGNAL_WAVE_FREQUENCY * 2.0 * M_PI / SAMPLE_RATE_F;
	
	for (int i = 0; i < frames; ++i){
		float wave = sin(m_signalPhaseCur);
		*buffer++ = wave;
        m_signalPhaseCur += phase_step;
        
        if (m_signalPhaseCur > 2.0 * M_PI) {
            m_signalPhaseCur -= 2.0 * M_PI;
        }
    }
}



#pragma mark - ---- Audio Generator func ----



- (void) prepareStaticArrays
{
    
    waveLongHigh = [self generateHalfSine:true halfPeriod:longHIGH];
    longHighLength = [self arraySizeWithHalfPeriod:longHIGH];
    waveLongLow = [self generateHalfSine:false halfPeriod:longLOW];
    longLowLength = [self arraySizeWithHalfPeriod:longLOW];
    waveShortHigh = [self generateHalfSine:true halfPeriod:shortHIGH];
    shortHighLength = [self arraySizeWithHalfPeriod:shortHIGH];
    waveShortLow = [self generateHalfSine:false halfPeriod:shortLOW];
    shortLowLength = [self arraySizeWithHalfPeriod:shortLOW];
    
    float mediumLow = 0.0005 - sampleTime;
    waveMediumLow = [self generateHalfSine:false halfPeriod:mediumLow];
    mediumLowLength = [self arraySizeWithHalfPeriod:mediumLow];
    
    
    longZeroLength = (int)floor((0.002 + 1 / SAMPLE_RATE_F) * SAMPLE_RATE_F);
    waveLongZero = malloc(longZeroLength);
    
    [self generateWaveBit];
    
    
    [self initCodeWaveLen];
    
    [self generateCtrWaveHead];
    [self generateWaveBit_01];
    
    [self setupCtrWave];
}

- (void)initCodeWaveLen
{
    //int initCodeDataLen = sizeof(g_initCodeTime) / sizeof(double);
    
    for (int i=0; i < INIT_CODE_DATA_SIZE; ++i) {
        m_initCodeLen[i] = [self arraySizeWithHalfPeriod:g_initCodeTime[i]];
    }
    
    initWaveSendLenIdx = 0;
    initWaveSendLenIdxLenMax = m_initCodeLen[0];
    initWaveSendLenIdxLenCur = 0;
    initWaveCurAngle = 0.f;
}

- (void)setupCtrWave
{
    ctrWaveMaxLen = ctrWaveHeadLen +
                USEFUL_BIT_SIZE * (waveBit_01_len[0] > waveBit_01_len[1] ? waveBit_01_len[0] : waveBit_01_len[1]) +
                longHighLength;
    
    idleWaveLen = (int)floor(IDLE_TIME_MS * 0.001f * SAMPLE_RATE_F);
    
    ctrWave = malloc(sizeof(Float32) * ctrWaveMaxLen);
    
    memcpy(ctrWave, ctrWaveHead, sizeof(Float32) * ctrWaveHeadLen);
    
    ctrWaveReadIdx = 0;
    idleWaveReadIdx = 0;
}



- (void)generateCtrWaveHead
{
    int ctr_longH_len = [self arraySizeWithHalfPeriod:longHIGH];
    int ctr_shortL_len = [self arraySizeWithHalfPeriod:shortLOW];
    
    ctrWaveHeadLen = 2 * ctr_longH_len + 2 * ctr_shortL_len;
    ctrWaveHead = malloc(sizeof(Float32) * ctrWaveHeadLen);
    
    int idx = 0;
    
    double increment = M_PI/((longHIGH - sampleTime * 2) * SAMPLE_RATE_F);
    double angle = 0;
    
    for (int i=0; i < ctr_longH_len; ++i) {
        Float32 value = sinf(angle);
        ctrWaveHead[idx + ctr_longH_len + ctr_shortL_len] = value;
        ctrWaveHead[idx++] = value;
        angle += increment;
    }
    
    memset(ctrWaveHead + idx, 0, sizeof(Float32) * ctr_shortL_len);
    memset(ctrWaveHead + (idx + ctr_longH_len + ctr_shortL_len), 0, sizeof(Float32) * ctr_shortL_len);

}

- (void) generateWaveBit_01
{
    waveBit_01_len[0] = shortHighLength + shortLowLength;
    waveBit_01_len[1] = longHighLength + longLowLength;
    
    waveBit_01[0] = malloc(sizeof(Float32) * waveBit_01_len[0]);
    waveBit_01[1] = malloc(sizeof(Float32) * waveBit_01_len[1]);
    
    int idx = 0;
    for (int i=0; i < shortHighLength; ++i) {
        waveBit_01[0][idx++] = waveShortHigh[i];
    }
    for (int i=0; i < shortLowLength; ++i) {
        waveBit_01[0][idx++] = waveShortLow[i];
    }
    
    idx = 0;
    for (int i=0; i < longHighLength; ++i) {
        waveBit_01[1][idx++] = waveLongHigh[i];
    }
    for (int i=0; i < longLowLength; ++i) {
        waveBit_01[1][idx++] = waveLongLow[i];
    }
    
}

- (void) generateWaveBit
{
    waveBitLength = longHighLength + longLowLength + shortHighLength + shortLowLength;
    waveBit = malloc(sizeof(waveBit) * waveBitLength);
    int c = 0;
    for (int i = 0; i < longHighLength; i++) {
        waveBit[c++] = waveLongHigh[i];
    }
    for (int i = 0; i < longLowLength; i++) {
        waveBit[c++] = waveLongLow[i];
    }
    for (int i = 0; i < shortHighLength; i++) {
        waveBit[c++] = waveShortHigh[i];
    }
    for (int i = 0; i < shortLowLength; i++) {
        waveBit[c++] = waveShortLow[i];
    }
}



// calculate the checksum for the generated code used to generate the WAV array
- (int) codeChecksum:(int)code
{
    int checksum = 0;
    for (int i = 0; i < 7; i++) {
        checksum += (code >> 4*i) & 15;
    }
    return 16 - (checksum & 15);
}

// Generate the code used to create the WAV file based on the given throttle, yaw and pitch.
// Copied from AudioService.java in the Android app (command2code method)
// throttle: 0~127, nothing will happen if this value is below 30.
// yaw: 0~127, normally 78 will keep orbit from rotating.
// pitch: 0~63, normally 31 will stop the top propeller.
// channel: 1=Channel A, 0=Channel B 2= Channel C, depend on which channel you want to pair to the orbit. You can fly at most 3 orbit in a same room.
- (int) generateCode
{
    int channel = 1;
    int code = throttle << 21;
    code += 1 << 20;
    code += yaw << 12;
    code += pitch << 4;
    code += ((channel >> 1) & 1) << 19;
    code += (channel & 1) << 11;
    code += [self codeChecksum:code];
    
    return (code << 1) + 1;
}

- (void)updateCtrCode:(BOOL)refresh
{
    int ctr_code = [self generateCode];
    
    //1110110111010011001001111101101
    
    //ctr_code = 0B00010110111010011001001111101101;
    //ctr_code = 0x0000FFFF;
    
    [self codeToWave:ctr_code];
    
    if (refresh) {
        g_refreshCtrCode = YES;
    }
    
}

- (void)codeToWave:(int)code
{
    Float32 *pos = ctrWave + ctrWaveHeadLen;
    
    for (int i=USEFUL_BIT_SIZE-1; i >= 0 ; --i) {
        int bit = (code >> i) & 1;
        memcpy(pos, waveBit_01[bit], sizeof(Float32) * waveBit_01_len[bit]);
        pos += waveBit_01_len[bit];
    }
    
    memcpy(pos, waveLongHigh, sizeof(Float32) * longHighLength);
    pos += longHighLength;
    
    ctrWaveDataLen = pos - ctrWave;
    int lost_len = ctrWaveMaxLen - ctrWaveDataLen;
    
    memset(pos, 0, sizeof(Float32) * lost_len);
}




- (int) writeBytesToBuffer:(Float32 *) buffer maxSize:(UInt32) frames
{
    MAX_BUFFER_SIZE = sizeof(buffer) * frames;
    int position = 0;
    [self writeWaveToBuffer:buffer        at:&position];
    [self writeInitialWaveToBuffer:buffer at:&position];
    
    return position;
}

- (void) writeInitialWaveToBuffer:(Float32 *) buffer at: (int *) position
{
    [self writeWave123To: buffer at: position];
    [self writeWave123To: buffer at: position];
    [self writeWave456To: buffer at: position];
    [self writeWave456To: buffer at: position];
    [self writeWave456To: buffer at: position];
}

- (void) writeWave123To:(Float32 *) buffer at:(int *) position
{
    [self writeOriginalTo:buffer at: position];
    [self writeArray:waveMediumLow to:buffer length:mediumLowLength at:position];
    for (int i = 0; i < 4; i++) {
        [self writeShortHShortLTo:buffer at:position];
    }
    [self writeArray:waveShortHigh to:buffer length:shortHighLength at:position];
    [self writeMediumLShortHTo:buffer at:position];
    [self writePauseInSamplesTo:buffer at:position];
}

- (void) writeWave456To:(Float32 *) buffer at:(int *) position
{
    [self writeOriginalTo:buffer at:position];
    [self writeArray:waveShortLow to:buffer length:shortLowLength at:position];
    for (int i = 0; i < 4; i++) {
        [self writeShortHShortLTo:buffer at:position];
    }
    [self writeArray:waveShortHigh to:buffer length:shortHighLength at:position];
    [self writeMediumLShortHTo:buffer at:position];
    [self writePauseInSamplesTo:buffer at:position];
}


- (void) writeOriginalTo:(Float32 *) buffer at:(int *) position
{
    [self writeLongHLongZeroTo: buffer at: position];
    [self writeLongHLongZeroTo: buffer at: position];
    [self writeArray:waveLongHigh to:buffer length:longHighLength at:position];
    [self writeMediumLShortHTo:buffer at:position];
}

- (void) writeLongHLongZeroTo:(Float32 *) buffer at:(int *) position
{
    [self writeArray:waveLongHigh to:buffer length:longHighLength at:position];
    [self writeArray:waveLongZero to:buffer length:longZeroLength at:position];
}

- (void) writeMediumLShortHTo:(Float32 *) buffer at:(int *) position
{
    [self writeArray:waveMediumLow to:buffer length:mediumLowLength at:position];
    [self writeArray:waveShortHigh to:buffer length:shortHighLength at:position];
}

- (void) writeShortHShortLTo:(Float32 *) buffer at:(int *) position
{
    [self writeArray:waveShortHigh to:buffer length:shortHighLength at:position];
    [self writeArray:waveShortLow to:buffer length:shortLowLength at:position];
}

- (void) writePauseInSamplesTo:(Float32 *) buffer at:(int *) position
{
    int length = (int)floor(0.010 * SAMPLE_RATE_F); // length of pause to insert
    float arr[length];
    [self writeArray:arr to:buffer length:length at:position];
}

- (void) writeArray:(float *) array to:(Float32 *) buffer length: (int)length at:(int *) position
{
    for (int i = 0; i < length; i++) {
        if (*position < MAX_BUFFER_SIZE) buffer[(*position)++] = array[i];
    }
}

- (void) writeWaveToBuffer:(Float32 *) buffer at: (int *) position
{
    [self halfSineGen: false halfPeriod: longLOW                   toBuffer:buffer at:position];
    [self halfSineGen: true  halfPeriod: longHIGH - sampleTime * 2 toBuffer:buffer at:position];
    [self halfSineGen: false halfPeriod: shortLOW + sampleTime * 2 toBuffer:buffer at:position];
    [self halfSineGen: true  halfPeriod: longHIGH - sampleTime * 2 toBuffer:buffer at:position]; // duplicate?
    [self halfSineGen: false halfPeriod: shortLOW + sampleTime * 2 toBuffer:buffer at:position]; // duplicate?
    
    int code = [self generateCode];
    for (int i=0; i < 27; i++) {
        buffer[(*position)++] = waveBit[((code >> (27 - i)) & 1)];
    }
    for (int i = 0; i < longHighLength; i++) {
        buffer[(*position)++] = waveLongHigh[i];
    }
    
}

/**
 * Generate half sine signal.
 * Copied from AudioService.java in the AndroidApp
 * @param upper, means it's the upper half or lower half or sine wave.
 * @param halfPeriod: half of the period of sine wave, in seconds
 * @param toBuffer the buffer (float array) to write to
 * @param position the position in the array to start writing to
 */
- (void) halfSineGen:(BOOL)upper halfPeriod: (double)halfPeriod toBuffer:(Float32 *) buffer at:(int *) position
{
   
   // TODO - testing
   //halfPeriod =true;
   
    int sampleCount = [self arraySizeWithHalfPeriod:halfPeriod];
    double increment = M_PI/(halfPeriod * SAMPLE_RATE_F);
    double angle = upper ? 0 : M_PI;
        
    for (int i = 0; i < sampleCount; i++) {
        buffer[(*position)++] = sinf(angle);
        angle += increment;
    }
}

- (int) arraySizeWithHalfPeriod: (double)halfPeriod
{
    return (int)floor(halfPeriod * SAMPLE_RATE_F);
}

/**
 * Generate half sine signal.
 * Copied from AudioService.java in the AndroidApp
 * @param upper, means it's the upper half or lower half of sine wave.
 * @param halfPeriod: half of the period of sine wave, in seconds
 * @return the length of the array
 */
- (float *) generateHalfSine:(BOOL)upper halfPeriod: (double)halfPeriod
{
    int sampleCount = [self arraySizeWithHalfPeriod:halfPeriod];
    Float32 *array = malloc(sizeof(Float32) * sampleCount);
    double increment = M_PI/(halfPeriod * SAMPLE_RATE_F);
    double angle = 0;
    
    for (int i = 0; i < sampleCount; i++) {
        if (upper) {
            array[i] = sinf(angle);
            angle += increment;
        }
        else {
            array[i] = 0.0f;
        }
        
    }
    return array;
}

@end