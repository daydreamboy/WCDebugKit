//
//  WDKIntegratedTools.h
//  Pods
//
//  Created by wesley chen on 16/11/15.
//
//

#import <Foundation/Foundation.h>

#define RTCall_JSONObjectWithUserHomeFileName(userHomeFileName) ([NSClassFromString(@"WDKApplicationTool") performSelector:@selector(JSONObjectWithUserHomeFileName:) withObject:(userHomeFileName)])
