//
//  UIView+MKAnnotationView.m
//  MapTest
//
//  Created by Oleksii Skutarenko on 17.01.14.
//  Copyright (c) 2014 Alex Skutarenko. All rights reserved.
//

#import "UIView+MKAnnotationView.h"
@import MapKit.MKAnnotationView;

@implementation UIView (MKAnnotationView)

- (MKAnnotationView *) superAnnotationView {
        if ([self isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView *)self;
    }
    if (!self.superview) {
        return nil;
    }
    return [self.superview superAnnotationView];
}
@end
