//
//  ViewController.h
//  Audio
//
//  Created by Jean-Pierre Simard on 12-05-30.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "F3BarGauge.h"
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController <AVAudioRecorderDelegate, MFMailComposeViewControllerDelegate> {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSTimer *levelTimer;
}
- (IBAction)record:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)stopRecording:(id)sender;
- (IBAction)emailRecording:(id)sender;
@property (weak, nonatomic) IBOutlet F3BarGauge *levelMeter;

@end
