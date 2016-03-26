//
//  MBButtonsViewController.m
//  MapBookmarks-iOS
//
//  Created by Danil on 25.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBButtonsViewController.h"
@import CoreData;
#import "MBCoreDataStack.h"
#import "NSManagedObjectContext+MBSave.h"
#import "MBStoryboardConstants.h"
#import "MBNearbyPlacesViewController.h"
#import "MBPin.h"

@interface MBButtonsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *loadPlacesButton;

@end

@implementation MBButtonsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.pin.title isEqualToString:@"Unnamed"]) {
        [self.loadPlacesButton setHidden:YES];
        [self performSegueWithIdentifier:toMBNearbyPlacesVC sender:self];
    } else {
        [self.loadPlacesButton setHidden:NO];
    }
    self.TitleLabel.text = self.pin.title;
    self.locationLabel.text = [NSString stringWithFormat:@"%f, %f", self.pin.coordinate.latitude, self.pin.coordinate.longitude];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)centerButtonDidPress:(id)sender {
}

- (IBAction)drawRouteDidPress:(id)sender {
}

- (IBAction)trashButtonDidPress:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you shure?"
                                                                   message:@"You realy want to delete this pin?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [alert dismissViewControllerAnimated:YES
                                                                                 completion:nil];
                                                   }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   NSManagedObjectContext *context = [MBCoreDataStack sharedManager].mainContext;
                                                   [context deleteObject:self.pin];
                                                   [self.navigationController popViewControllerAnimated:YES];
                                                   [context saveContext];
                                               }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:toMBNearbyPlacesVC]) {
        MBNearbyPlacesViewController *placesVC = [segue destinationViewController];
        placesVC.pin = self.pin;
    }
}

@end
