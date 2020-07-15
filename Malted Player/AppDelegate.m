//
//  AppDelegate.m
//  Malted Player
//
//  Created by Maxwell on 14/07/20.
//  Copyright © 2020 Maxwell Swadling. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)openDocument:(id)sender {
    NSWindowController *wc = [[NSStoryboard mainStoryboard] instantiateInitialController];
    [wc showWindow:nil];
}

@end
