//
//  RAFormViewControllerDelegate.h
//  Red Ant
//
//  Copyright (c) 2012 Red Ant. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RAFormViewControllerDelegate<NSObject>

@optional


/**
 *  @@optional
 *
 */
- (void)submitWithArray:(NSArray *)array;

@end
