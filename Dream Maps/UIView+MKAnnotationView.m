//
//  MKAnnotationView.m
//  Dream Maps
//
//  Created by Yura Yasinskyy on 25.07.16.
//  Copyright © 2016 Yura Yasinskyy. All rights reserved.
//

#import "UIView+MKAnnotationView.h"
#import <MapKit/MKAnnotationView.h>

@implementation UIView (MKAnnotationView)

- (MKAnnotationView*) superAnnotationView {
    
    if ([self isKindOfClass:[MKAnnotationView class]]) {
        
        return (MKAnnotationView*)self.superview;
    }
    
    if (!self.superview) {
        return nil;
    }
    
    return [self.superview superAnnotationView];
    
}

@end
