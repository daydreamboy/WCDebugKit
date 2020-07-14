//
//  WDKApplicationTool.m
//  WCDebugKit
//
//  Created by wesley_chen on 2020/3/4.
//

#import "WDKApplicationTool.h"
#import <sys/utsname.h>

@implementation WDKApplicationTool

#pragma mark > Get debug configuration (Only Simulator)

+ (nullable id)JSONObjectWithUserHomeFileName:(nullable NSString *)userHomeFileName {
    if (![userHomeFileName isKindOfClass:[NSString class]] || !userHomeFileName.length) {
        userHomeFileName = @"simulator_debug.json";
    }

    NSMutableArray *components = [NSMutableArray array];
    
    if ([self deviceIsSimulator]) {
        NSString *appHomeDirectoryPath = [@"~" stringByExpandingTildeInPath];
        NSArray *pathParts = [appHomeDirectoryPath componentsSeparatedByString:@"/"];
        if (pathParts.count < 2) {
            return nil;
        }
        
        [components addObject:@"/"];
        // Note: pathParts is @"", @"Users", @"<your name>", ...
        [components addObjectsFromArray:[pathParts subarrayWithRange:NSMakeRange(1, 2)]];
        
    }
    else {
        [components addObject:NSHomeDirectory()];
        [components addObject:@"Documents"];
    }
    
    [components addObject:userHomeFileName];
    
    NSString *filePath = [NSString pathWithComponents:components];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:filePath options:kNilOptions error:&error];
    if (!data) {
        NSLog(@"[%@] an error occurred: %@", NSStringFromClass([self class]), error);
        return nil;
    }
    
    id JSONObject = nil;
    @try {
        NSError *error2;
        JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&error2];
        if (!JSONObject) {
            NSLog(@"[%@] error parsing JSON: %@", NSStringFromClass([self class]), error2);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"[%@] an exception occured:\n%@", NSStringFromClass([self class]), exception);
    }
    
    return JSONObject;
}

#pragma mark - Utility

+ (BOOL)deviceIsSimulator {
    // Set up a struct
    struct utsname dt;
    // Get the system information
    uname(&dt);
    // Set the device type to the machine type
    NSString *deviceType = [NSString stringWithFormat:@"%s", dt.machine];
    
    // Simulators
    if ([deviceType isEqualToString:@"i386"] || [deviceType isEqualToString:@"x86_64"]) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
