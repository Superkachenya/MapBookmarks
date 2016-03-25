//
//  ViewController.m
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import MapKit;
@import CoreLocation;
@import CoreData;
#import "MBMapViewController.h"
#import "MBPin.h"
#import "WYPopoverController.h"
#import "MBRouteViewController.h"
#import "MBBookmarksTableViewController.h"
#import "MBNearbyPlacesViewController.h"
#import "MBButtonsViewController.h"
#import "MBStoryboardConstants.h"
#import "MBCoreDataStack.h"
#import "NSManagedObjectContext+MBSave.h"

NSString *const kRoute   = @"Route";
NSString *const kClean   = @"Clean Route";
NSString *const kUnnamed = @"Unnamed";

@interface MBMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, WYPopoverControllerDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) WYPopoverController *popover;
@property (weak, nonatomic) MBPin *transitPin;
@property (strong, nonatomic) MKDirections *directions;
@property (strong, nonatomic)NSFetchedResultsController *fetchResults;

@end

@implementation MBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fetchResults = [MBPin fetchedResultsFromStore];
    [self.fetchResults performFetch:nil];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    [self.mapView addAnnotations:self.fetchResults.fetchedObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:userLocation.coordinate
                                                     fromEyeCoordinate:CLLocationCoordinate2DMake(userLocation.coordinate.latitude,
                                                                                                  userLocation.coordinate.longitude)
                                                           eyeAltitude:kCLLocationAccuracyKilometer];
    [self.mapView setCamera:camera];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MBPin class]]) {
        MBPin *myPin = (MBPin *)annotation;
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"MBPin"];
        if (!annotationView) {
            annotationView = [myPin annotationView];
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    } else {
        return nil;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor orangeColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

#pragma mark - WYPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    self.popover.delegate = nil;
    self.popover = nil;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"LookAtMe");
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:toMBBookmarksVC]) {
        MBBookmarksTableViewController *bookmarksVC = [segue destinationViewController];
        bookmarksVC.bookmarks = self.fetchResults.fetchedObjects;
    } else if ([segue.identifier isEqualToString:toMBNearbyVCFromPin]) {
        MBNearbyPlacesViewController *nearVC = [segue destinationViewController];
        nearVC.pin = self.transitPin;
    } else if ([segue.identifier isEqualToString:toMBButtonsVCFromPin]) {
        MBButtonsViewController *buttonsVC = [segue destinationViewController];
        buttonsVC.pin = self.transitPin;
    }
}

#pragma mark - Draw route

- (void)showRouteFromUserTo:(MBPin *)pin {
        if (!pin) {
            return;
        }
        if ([self.directions isCalculating]) {
            [self.directions cancel];
        }
        CLLocationDegrees latitude = pin.coordinate.latitude;
        CLLocationDegrees longitude = pin.coordinate.longitude;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        for (id<MKAnnotation> annotation in self.mapView.annotations) {
            if ([annotation isKindOfClass:[MBPin class]] && annotation.coordinate.latitude != coordinate.latitude) {
                MKAnnotationView* anView = [self.mapView viewForAnnotation: annotation];
                anView.hidden = YES;
            }
        }
        MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
        request.source = [MKMapItem mapItemForCurrentLocation];
        MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark:placemark];
        request.destination = destination;
        request.transportType = MKDirectionsTransportTypeWalking;
        request.requestsAlternateRoutes = NO;
        self.directions = [[MKDirections alloc] initWithRequest:request];
        [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                //[self showAlertWithTitle:@"Error" andMessage:[error localizedDescription]];
            } else if ([response.routes count] == 0) {
                //[self showAlertWithTitle:@"Error" andMessage:@"No routes found"];
            } else {
                [self.mapView removeOverlays:[self.mapView overlays]];
                NSMutableArray* array = [NSMutableArray array];
                for (MKRoute* route in response.routes) {
                    [array addObject:route.polyline];
                }
                [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
            }
        }];
}

#pragma mark - HandleEvents

- (IBAction)userDidAddPin:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        return;
    } else {
        NSManagedObjectContext *context = [MBCoreDataStack sharedManager].mainContext;
        MBPin *pin = [NSEntityDescription insertNewObjectForEntityForName:@"MBPin" inManagedObjectContext:context];
        __weak MBPin *weakPin = pin;
        CGPoint touchPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D location = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        pin.title = kUnnamed;
        pin.coordinate = location;
        pin.detailButton = ^{
            self.transitPin = weakPin;
            if (![self.transitPin.title isEqualToString:kUnnamed]) {
                [self performSegueWithIdentifier:toMBButtonsVCFromPin sender:self];
            } else {
            [self performSegueWithIdentifier:toMBNearbyVCFromPin sender:self];
            }
        };
        [self.mapView addAnnotation:pin];
        [context saveContext];
    }
}

- (IBAction)routeButtonDidTap:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:kClean]) {
        [self.mapView removeOverlays:self.mapView.overlays];
        for (id<MKAnnotation> annotation in self.mapView.annotations) {
            if ([annotation isKindOfClass:[MBPin class]]) {
                MKAnnotationView* anView = [self.mapView viewForAnnotation: annotation];
                anView.hidden = NO;
            }
        }
        sender.title = kRoute;
    } else {
        MBRouteViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:IDMBContentViewController];
        controller.preferredContentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height /2);
        controller.modalInPopover = NO;
        controller.pins = self.fetchResults.fetchedObjects;
        controller.drawRouteBlock = ^(MBPin *pin) {
            [self showRouteFromUserTo:pin];
            [self.popover dismissPopoverAnimated:YES];
            sender.title = kClean;
        };
        self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
        self.popover.delegate = self;
        self.popover.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        self.popover.wantsDefaultContentAppearance = NO;
        [self.popover presentPopoverFromBarButtonItem:sender
                             permittedArrowDirections:WYPopoverArrowDirectionDown
                                             animated:YES];
    }
}

@end
