//
//  UIView+MKAnnotationView.h
//  MapTest
//
//  Created by Oleksii Skutarenko on 17.01.14.
//  Copyright (c) 2014 Alex Skutarenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKAnnotationView;

@interface UIView (MKAnnotationView)

- (MKAnnotationView*) superAnnotationView;

@end
