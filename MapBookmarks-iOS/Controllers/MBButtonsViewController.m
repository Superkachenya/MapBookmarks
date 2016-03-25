//
//  MBButtonsViewController.m
//  MapBookmarks-iOS
//
//  Created by Danil on 25.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBButtonsViewController.h"
#import "MBStoryboardConstants.h"
#import "MBNearbyPlacesViewController.h"

@interface MBButtonsViewController ()

@end

@implementation MBButtonsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)centerButtonDidPress:(id)sender {
}

- (IBAction)drawRouteDidPress:(id)sender {
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:toMBNearbyPlacesVC]) {
        MBNearbyPlacesViewController *placesVC = [segue destinationViewController];
        placesVC.pin = self.pin;
    }
}

@end
