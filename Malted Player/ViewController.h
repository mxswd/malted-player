//
//  ViewController.h
//  Malted Player
//
//  Created by Maxwell on 14/07/20.
//  Copyright © 2020 Maxwell Swadling. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface ViewController : NSViewController

@property NSString *password;

@property (weak) IBOutlet AVPlayerView *avPlayer;

- (void)playFile:(id)sender;

@end

