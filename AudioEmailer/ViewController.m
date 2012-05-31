//
//  ViewController.m
//  Audio
//
//  Created by Jean-Pierre Simard on 12-05-30.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//

#import "ViewController.h"
#define kdBOffset       40
#define kMeterRefresh   0.03

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)record:(id)sender {
    [recorder pause];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    [recorder record];
    [recorder updateMeters];
    levelTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.0] interval:kMeterRefresh target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:levelTimer forMode:NSDefaultRunLoopMode];
}

- (IBAction)play:(id)sender {
	NSError *error;
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:&error];
    [player play];
}

- (IBAction)stopRecording:(id)sender {
    [recorder stop];
    [levelTimer invalidate];
}

- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    levelMeter.value = ([recorder averagePowerForChannel:0]+kdBOffset)/kdBOffset;
}

- (IBAction)emailRecording:(id)sender {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Attach an image to the email
    NSData *myData = [NSData dataWithContentsOfURL:recorder.url];
    [picker addAttachmentData:myData mimeType:@"audio/mp4a-latm" fileName:@"recording.m4a"];
    
    // Fill out the email body text
    [picker setMessageBody:@"" isHTML:NO];
    [self presentModalViewController:picker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
