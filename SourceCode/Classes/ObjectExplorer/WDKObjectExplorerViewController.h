//
//  WDKObjectExplorerViewController.h
//  WCDebugKit
//
//  Created by wesley_chen on 23/03/2018.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FLEXObjectExplorerSection) {
    FLEXObjectExplorerSectionDescription,
    FLEXObjectExplorerSectionCustom,
    FLEXObjectExplorerSectionProperties,
    FLEXObjectExplorerSectionIvars,
    FLEXObjectExplorerSectionMethods,
    FLEXObjectExplorerSectionClassMethods,
    FLEXObjectExplorerSectionSuperclasses,
    FLEXObjectExplorerSectionReferencingInstances
};

@interface WDKObjectExplorerViewController : UIViewController

@property (nonatomic, strong) id object;

@end
