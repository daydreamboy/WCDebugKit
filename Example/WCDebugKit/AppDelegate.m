//
//  WCAppDelegate.m
//  WCDebugKit
//
//  Created by wesley chen on 10/04/2017.
//  Copyright (c) 2017 wesley chen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) ViewController *viewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    NSLog(@"screenSize: %@", NSStringFromCGSize(screenSize));
    
    NSLog(@"app: %@", [NSBundle mainBundle].bundlePath);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] init];
    self.window.rootViewController = self.viewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
