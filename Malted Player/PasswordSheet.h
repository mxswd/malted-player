//
//  PasswordSheet.h
//  Malted Player
//
//  Created by Maxwell on 15/07/20.
//  Copyright © 2020 Maxwell Swadling. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PasswordSheet : NSViewController

@property (weak) ViewController *delegate;

@end

NS_ASSUME_NONNULL_END
