//
//  ViewController.m
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBMapViewController.h"
#import "MBNetworkManager.h"
@import MapKit;
@import CoreLocation;
#import "MBPin.h"
#import "WYPopoverController.h"
#import "MBContentPopoverViewController.h"

@interface MBMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, WYPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *bookmarks;
@property (strong, nonatomic) WYPopoverController *popover;


@end

@implementation MBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    self.bookmarks = [NSMutableArray new];
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

#pragma mark - Draw route methods

- (void)showRouteFromUserTo:(MBPin *)pin {
    [self.mapView removeOverlays:self.mapView.overlays];
    CLLocationCoordinate2D coordinateArray[2];
    coordinateArray[0] = self.mapView.userLocation.coordinate;
    coordinateArray[1] = pin.coordinate;
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinateArray count:2];
    [self.mapView addOverlay:polyline];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor purpleColor];
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

#pragma mark - HandleEvents

- (IBAction)userDidAddPin:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        return;
    } else {
        MBPin *pin = [MBPin new];
        CGPoint touchPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D location = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        pin.coordinate = location;
        [self.bookmarks addObject:pin];
        [MBNetworkManager downloadNearbyPlacesUsingLatitude:pin.coordinate.latitude andLongitude:pin.coordinate.longitude];
        [self.mapView addAnnotation:pin];
    }
}

- (IBAction)routeButtonDidTap:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Clear"]) {
        [self.mapView removeOverlays:self.mapView.overlays];
        sender.title = @"Route";
        [self.mapView addAnnotations:self.bookmarks];
    } else {
    MBContentPopoverViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MBContentViewController"];
    controller.preferredContentSize = CGSizeMake(self.view.bounds.size.width /2, self.view.bounds.size.height /2);
    controller.modalInPopover = NO;
    controller.pins = [self.bookmarks copy];
    controller.drawRouteBlock = ^(MBPin *pin) {
        [self showRouteFromUserTo:pin];
        [self.popover dismissPopoverAnimated:YES];
        sender.title = @"Clear";
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
