//
//  MBPin.m
//  MapBookmarks-iOS
//
//  Created by Danil on 23.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MBPin.h"

@implementation MBPin

- (MKAnnotationView *)annotationView {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"MBPin"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.draggable = YES;
    annotationView.image = [UIImage imageNamed:@"pin"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = button;
    
    return annotationView;
}

- (void)didTapButton:(id)sender {
    NSLog(@"Success!!!");
}

@end
