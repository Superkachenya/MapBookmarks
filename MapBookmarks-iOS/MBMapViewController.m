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

@interface MBMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

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

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (IBAction)userDidAddPin:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.mapView removeGestureRecognizer:sender];
    } else {
    MBPin *pin = [MBPin new];
    CGPoint touchPoint = [sender locationInView:self.mapView];
    CLLocationCoordinate2D location = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    pin.title = @"Bamboleyo";
    pin.coordinate = location;
    [MBNetworkManager downloadNearbyPlacesUsingLatitude:pin.coordinate.latitude andLongitude:pin.coordinate.longitude];
    [self.mapView addAnnotation:pin];
    }
    [self.mapView addGestureRecognizer:sender];
}

@end
