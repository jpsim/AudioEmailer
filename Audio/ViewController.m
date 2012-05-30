//
//  ViewController.m
//  Audio
//
//  Created by Jean-Pierre Simard on 12-05-30.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize levelMeter;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    
    if (err) { /* handle error */ }
    
    err = nil;
    
    [audioSession setActive:YES error:&err];
    
    if (err) { /* handle error */ }
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSLog(@"Documents directory: %@", 
//          [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil]);
    
    NSURL *url = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"recording.m4a"]];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt:1], AVNumberOfChannelsKey, nil];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url 
                                           settings:settings error:&err];
    
    if (!recorder) { /* handle error */ }
    
    [recorder setDelegate:self];
}

- (void)viewDidUnload
{
    [self setLevelMeter:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)record:(id)sender {
    NSLog(@"startRecording!");
    [recorder pause];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    [recorder record];
    [recorder updateMeters];
    levelTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.0] interval:0.03 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:levelTimer forMode:NSDefaultRunLoopMode];
}

- (IBAction)play:(id)sender {
    
	NSError *error;
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:&error];
//	player.numberOfLoops = -1;
    
    [player play];
}

- (IBAction)stopRecording:(id)sender {
    [recorder stop];
    [levelTimer invalidate];
}

- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    double avgPowerForChannel = pow(10, (0.05 * [recorder averagePowerForChannel:0]));
    NSLog(@"Avg. Power: %f (%.2f dB)", [recorder averagePowerForChannel:0],avgPowerForChannel);
    levelMeter.value = ([recorder averagePowerForChannel:0]+40)/40;
    levelMeter.holdPeak = TRUE;
}
@end
