//
//  BBUUPAPI.m
//  Steps
//
//  Created by Boris Bügling on 15.12.13.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "BBUUPAPI.h"

NSString *const kAPIExplorerID = @"3ZYR1YjGd3Q";
NSString *const kAPIExplorerSecret = @"4dd5b10b3a3a16dbf3082c86d5faff09e11a682b";

@implementation BBUUPAPI

+ (instancetype)sharedAPI
{
    static BBUUPAPI *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark -

-(BOOL)running {
    return NO;
}

-(void)loginWithCompletionHandler:(UPPlatformSessionCompletion)completion {
    [[UPPlatform sharedPlatform] startSessionWithClientID:kAPIExplorerID
                                             clientSecret:kAPIExplorerSecret
                                                authScope:UPPlatformAuthScopeAll
                                               completion:completion];
}

-(void)getStepsForDaysAgo:(NSInteger)daysAgo :(void (^)(id))onComplete failure:(void (^)(NSError *))onFailure {
    NSDate* baseDate = [NSDate dateWithTimeIntervalSinceNow:-(daysAgo * 24 * 60 * 60)];
    NSDate* startTime = [self computeDateWithDate:baseDate hours:0 minutes:1];
    NSDate* endTime = [self computeDateWithDate:baseDate hours:23 minutes:59];
    
    [UPWorkoutAPI getWorkoutsFromStartDate:startTime
                                 toEndDate:endTime
                                completion:^(NSArray *results, UPURLResponse *response, NSError *error) {
                                    if (results) {
                                        if (onComplete) {
                                            NSInteger steps = 0;
                                            for (UPWorkout* workout in results) {
                                                steps += [workout.steps integerValue];
                                            }
                                            
                                            onComplete(@{ @"summary": @{ @"steps": @(steps) } });
                                        } else {
                                            onFailure(error);
                                        }
                                    }
                                }];
}

-(NSDate*)computeDateWithDate:(NSDate*)date hours:(NSInteger)hours minutes:(NSInteger)minutes {
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    
    [components setHour:hours];
    [components setMinute:minutes];
    
    return [calendar dateFromComponents:components];
}

-(void)setSteps:(NSInteger)steps forDaysAgo:(NSInteger)daysAgo :(void (^)(id))onComplete failure:(void (^)(NSError *))onFailure {
    NSDate* baseDate = [NSDate dateWithTimeIntervalSinceNow:-(daysAgo * 24 * 60 * 60)];
    NSDate* startTime = [self computeDateWithDate:baseDate hours:0 minutes:1];
    NSDate* endTime = [self computeDateWithDate:baseDate hours:23 minutes:59];
    
    UPWorkout* workout = [UPWorkout workoutWithType:UPWorkoutTypeWalk
                                          startTime:startTime
                                            endTime:endTime
                                          intensity:UPWorkoutIntensityModerate
                                     caloriesBurned:@0];
    
    workout.steps = @(steps);
    
    [UPWorkoutAPI postWorkout:workout completion:^(UPWorkout *workout, UPURLResponse *response, NSError *error) {
        if (response.code >= 200 && response.code < 400) {
            if (onComplete) {
                onComplete(workout);
            }
        } else {
            if (onFailure) {
                onFailure(error);
            }
        }
    }];
}

@end
