//
//  KMCGeigerCounter.h
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KMCGeigerCounterPosition) {
    KMCGeigerCounterPositionLeft,
    KMCGeigerCounterPositionMiddle,
    KMCGeigerCounterPositionRight
};

@interface KMCGeigerCounter : NSObject

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

// Draws over the status bar. Set it manually if your own custom windows obscure it.
@property (nonatomic, assign) UIWindowLevel windowLevel;
@property (nonatomic, assign) KMCGeigerCounterPosition position;

@property (nonatomic, readonly, getter = isRunning) BOOL running;
@property (nonatomic, readonly) NSInteger droppedFrameCountInLastSecond;

// -1 until one second of frames have been collected
@property (nonatomic, readonly) NSInteger drawnFrameCountInLastSecond;

+ (instancetype)sharedGeigerCounter;

@end
