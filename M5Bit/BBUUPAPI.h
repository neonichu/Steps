//
//  BBUUPAPI.h
//  Steps
//
//  Created by Boris Bügling on 15.12.13.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UPPlatformSDK/UPPlatformSDK.h>

@interface BBUUPAPI : NSObject

+ (instancetype)sharedAPI;

- (BOOL)running;

-(void)loginWithCompletionHandler:(UPPlatformSessionCompletion)completion;

- (void)getStepsForDaysAgo:(NSInteger)daysAgo :(void (^)(id JSON))onComplete failure:(void (^)(NSError *error))onFailure;
- (void)setSteps:(NSInteger)steps forDaysAgo:(NSInteger)daysAgo :(void (^)(id JSON))onComplete failure:(void (^)(NSError *error))onFailure;

@end
