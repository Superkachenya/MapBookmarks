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
#import "UIView+MKAnnotationView.h"
#import "MBCoreDataStack.h"
#import "NSManagedObjectContext+MBSave.h"
#import "UIViewController+MBErrorAlert.h"

NSString *const kRoute = @"Route";
NSString *const kClean = @"Clean Route";
NSString *const kUnnamed = @"Unnamed";
NSString *const kPinIdentifier = @"kPinIdentifier";

@interface MBMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, WYPopoverControllerDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *routeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookmarksButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) WYPopoverController *popover;
@property (strong, nonatomic) NSFetchedResultsController *fetchResults;
@property (strong, nonatomic) MBPin *transitPin;
@property (strong, nonatomic) MBPin *routePin;
@property (assign, nonatomic) BOOL isInRouteMode;
@property (assign, nonatomic) BOOL isCenterToUser;


@end

@implementation MBMapViewController

#pragma mark - UIViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fetchResults = [MBPin fetchedResultsFromStore];
    self.fetchResults.delegate = self;
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    [self.mapView addAnnotations:self.fetchResults.fetchedObjects];
    [self changeRouteModeTypeTo:NO];
    self.isCenterToUser = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self checkMapForPins];
    if (self.isInRouteMode) {
        self.bookmarksButton.enabled = NO;
    } else {
        self.bookmarksButton.enabled = YES;
        
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.isInRouteMode) {
        [self.mapView removeOverlays:self.mapView.overlays];
        if (self.isCenterToUser) {
            MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:userLocation.coordinate
                                                             fromEyeCoordinate:CLLocationCoordinate2DMake(userLocation.coordinate.latitude,
                                                                                                          userLocation.coordinate.longitude)
                                                                   eyeAltitude:kCLLocationAccuracyKilometer];
            [self.mapView setCamera:camera animated:YES];
            self.isCenterToUser = NO;
        }
    } else {
        [self redrawRoute];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MBPin class]]) {
        MBPin *myPin = (MBPin *)annotation;
        MKPinAnnotationView* annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kPinIdentifier];
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:myPin reuseIdentifier:kPinIdentifier];
        annotationView.pinTintColor = [MKPinAnnotationView greenPinColor];
        annotationView.animatesDrop = YES;
        annotationView.canShowCallout = YES;
        UIButton* descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [descriptionButton addTarget:self action:@selector(detailButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = descriptionButton;
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

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    if ([anObject isKindOfClass:[MBPin class]]) {
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.mapView addAnnotation:anObject];
                [self checkMapForPins];
                break;
            case NSFetchedResultsChangeDelete:
                [self.mapView removeAnnotation:anObject];
                break;
            case NSFetchedResultsChangeUpdate:
                break;
            case NSFetchedResultsChangeMove:
                if ([self.routeButton.title isEqualToString:kClean]) {
                    [self redrawRoute];
                }
                break;
        }
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:toMBButtonsVCFromPin]) {
        MBButtonsViewController *buttonsVC = [segue destinationViewController];
        buttonsVC.pin = self.transitPin;
        buttonsVC.isInRouteMode = self.isInRouteMode;
        buttonsVC.routeButton = ^(MBPin *pin) {
            [self drawRouteFromUserToPin:pin WithZoom:YES];
        };
        buttonsVC.centerButton = ^(MBPin *pin) {
            [self centerOnPin:pin];
        };
    }
}

- (IBAction)prepareForUnwindToMap:(UIStoryboardSegue *)segue {
    
}

#pragma mark - MapManipulations

- (void)zoomToPolyLine:(MKMapView *)map polyline:(MKPolyline*)polyline animated: (BOOL)animated {
    [map setVisibleMapRect:[polyline boundingMapRect] edgePadding:UIEdgeInsetsMake(25.0, 25.0, 25.0, 25.0) animated:animated];
}

- (void)drawRouteFromUserToPin:(MBPin *)pin WithZoom:(BOOL)zoom {
    [self changeRouteModeTypeTo:YES];
    self.routePin = pin;
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
    request.transportType = MKDirectionsTransportTypeAutomobile;
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            [self createAlertForError:error InViewController:self];
            [self.mapView removeOverlays:self.mapView.overlays];
            [self changeRouteModeTypeTo:NO];
        } else {
            [self.mapView removeOverlays:[self.mapView overlays]];
            MKRoute *route = response.routes.firstObject;
            [self.mapView addOverlays:@[route.polyline] level:MKOverlayLevelAboveLabels];
            if (zoom) {
                [self zoomToPolyLine:self.mapView polyline:route.polyline animated:YES];
            }
        }
    }];
}

- (void)redrawRoute {
    [self drawRouteFromUserToPin:self.routePin WithZoom:NO];
}

- (void)centerOnPin:(MBPin *)pin {
    [self.mapView setCenterCoordinate:pin.coordinate animated:YES];
}

#pragma mark - HandleEvents

- (IBAction)userDidAddPin:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        return;
    } else if ([self.routeButton.title isEqualToString:kClean]) {
        return;
    } else {
        NSManagedObjectContext *context = [MBCoreDataStack sharedManager].mainContext;
        MBPin *pin = [NSEntityDescription insertNewObjectForEntityForName:@"MBPin"
                                                   inManagedObjectContext:context];
        CGPoint touchPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D location = [self.mapView convertPoint:touchPoint
                                                toCoordinateFromView:self.mapView];
        pin.title = kUnnamed;
        pin.coordinate = location;
        [context saveContext];
    }
}

- (IBAction)routeButtonDidTap:(UIBarButtonItem *)sender {
    if (self.isInRouteMode) {
        [self.mapView removeOverlays:self.mapView.overlays];
        [self changeRouteModeTypeTo:NO];
        [self makeAnnotationsVisible];
    } else {
        MBRouteViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:IDMBContentViewController];
        controller.preferredContentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height /2);
        controller.modalInPopover = NO;
        controller.drawRouteBlock = ^(MBPin *pin) {
            [self drawRouteFromUserToPin:pin WithZoom:YES];
            [self.popover dismissPopoverAnimated:YES];
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

- (void)detailButtonDidPress:(UIButton *)sender {
    MKAnnotationView *annotationView = [sender superAnnotationView];
    self.transitPin = (MBPin *)annotationView.annotation;
    [self performSegueWithIdentifier:toMBButtonsVCFromPin sender:self];
}

#pragma mark - Helpers

- (void)checkMapForPins {
    if (!self.fetchResults.fetchedObjects.count) {
        self.routeButton.enabled = NO;
        self.bookmarksButton.enabled = NO;
    } else {
        self.routeButton.enabled = YES;
        self.bookmarksButton.enabled = YES;
    }
}

- (void)changeRouteModeTypeTo:(BOOL)type {
    self.isInRouteMode = type;
    self.bookmarksButton.enabled = !type;
    self.routeButton.title = type ? kClean : kRoute;
}

- (void) makeAnnotationsVisible {
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[MBPin class]]) {
            MKAnnotationView* anView = [self.mapView viewForAnnotation: annotation];
            anView.hidden = NO;
        }
    }
}

@end
