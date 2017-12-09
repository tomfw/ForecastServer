//
//  WeatherList.h
//  ForecastServer
//
//  Created by Thomas Williams on 12/4/17.
//  Copyright © 2017 Thomas Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherList : NSObject
@property (strong, nonatomic) NSMutableDictionary *forecasts; //key by @[city, state].. maptable?
@property (nonatomic) double updateInterval;
@property (strong, nonatomic) NSTimer *updateTimer;
-(void)updateData;
-(void)updateDataForCity:(NSString*)city state:(NSString*)state;
-(id)init;
@end
