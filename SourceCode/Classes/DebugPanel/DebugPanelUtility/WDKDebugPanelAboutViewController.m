//
//  WDKDebugPanelAboutViewController.m
//  Pods
//
//  Created by wesley chen on 16/10/19.
//
//

#import "WDKDebugPanelAboutViewController.h"

#import "WDKDebugPanelPod.h"
#import "WDKNavBackButtonItem.h"

@interface WDKDebugPanelAboutViewController ()

@end

@implementation WDKDebugPanelAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"About";
    
    WDKNavBackButtonItem *backItem = [[WDKNavBackButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(backItemClicked:)];
    self.navigationItem.leftBarButtonItems = @[[WDKNavBackButtonItem navBackButtonLeadingSpaceItem], backItem];
}

- (void)dealloc {
    NSLog(@"dealloc: %@", self);
}

#pragma mark - Actions

- (void)backItemClicked:(id)sender {
    
    // @sa http://stackoverflow.com/questions/18982724/flip-transition-uinavigationcontroller-push
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self.navigationController popToRootViewControllerAnimated:NO];
                    }
                    completion:nil];
}

@end
