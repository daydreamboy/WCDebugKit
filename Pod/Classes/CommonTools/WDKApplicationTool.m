//
//  WDKApplicationTool.m
//  WCDebugKit
//
//  Created by wesley_chen on 2020/3/4.
//

#import "WDKApplicationTool.h"

@implementation WDKApplicationTool

#pragma mark > Get debug configuration (Only Simulator)

+ (nullable id)JSONObjectWithUserHomeFileName:(nullable NSString *)userHomeFileName {
#if TARGET_OS_SIMULATOR
    if (![userHomeFileName isKindOfClass:[NSString class]] || !userHomeFileName.length) {
        userHomeFileName = @"simulator_debug.json";
    }
    
    NSString *appHomeDirectoryPath = [@"~" stringByExpandingTildeInPath];
    NSArray *pathParts = [appHomeDirectoryPath componentsSeparatedByString:@"/"];
    if (pathParts.count < 2) {
        return nil;
    }
    
    NSMutableArray *components = [NSMutableArray arrayWithObject:@"/"];
    // Note: pathParts is @"", @"Users", @"<your name>", ...
    [components addObjectsFromArray:[pathParts subarrayWithRange:NSMakeRange(1, 2)]];
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
#else
#warning "JSONObjectWithUserHomeFileName method only available in simulator"
    return nil;
#endif
}

@end
