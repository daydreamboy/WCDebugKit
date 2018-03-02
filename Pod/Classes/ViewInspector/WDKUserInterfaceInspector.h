//
//  WDKUserInterfaceInspector.h
//  Pods
//
//  Created by wesley chen on 2017/4/26.
//
//

@import UIKit;
#import <Foundation/Foundation.h>

@interface WDKUserInterfaceInspector : NSObject

// Toggles
@property (nonatomic, assign) BOOL slowAnimationsEnabled;
@property (nonatomic, assign) BOOL colorizedViewBorderEnabled;

+ (instancetype)sharedInstance;

@end
