//
//  PasswordSheet.m
//  Malted Player
//
//  Created by Maxwell on 15/07/20.
//  Copyright © 2020 Maxwell Swadling. All rights reserved.
//

#import "PasswordSheet.h"

@interface PasswordSheet ()
@property (weak) IBOutlet NSTextField *passwordField;

@end

@implementation PasswordSheet

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)cancel:(id)sender {
    [self dismissController:nil];
    [self.delegate.view.window close];
}

- (IBAction)ok:(id)sender {
    self.delegate.password = self.passwordField.stringValue;
    [self dismissController:nil];
    [self.delegate playFile:nil];
    
}

@end
