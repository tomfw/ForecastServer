//
//  WeatherList.m
//  ForecastServer
//
//  Created by Thomas Williams on 12/4/17.
//  Copyright © 2017 Thomas Williams. All rights reserved.
//

#import "WeatherList.h"

#define API_KEY @""

@interface WeatherList () {
	dispatch_queue_t _updateQueue;
}
@end

@implementation WeatherList


-(void)updateData {
	//run once every updateInterval minutes...
	//loop over keys and request info for that city/state
	for(id key in self.forecasts) {
		NSArray *location = key;
		[self updateDataForCity:location[0] state:location[1]];
	}
}

-(void)updateDataForCity:(NSString *)city state:(NSString *)state {
	//make the call and update the dictionary
	dispatch_async(_updateQueue, ^{
		NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/hourly/q/%@/%@.json", API_KEY, state, city];
		NSError *error;
		NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:urlString]];
		if(data) {
			NSLog(@"Updated: %@, %@", city, state);
			NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
			[self.forecasts setObject:json forKey:@[city, state]];
		}

	});
}

-(id)init {
	if(self = [super init ]) {
		_forecasts = [NSMutableDictionary dictionary];
		[_forecasts setObject:@"nada" forKey:@[@"lebanon", @"in"]];
		//[_forecasts setObject:@"nada" forKey:@[@"jacksonville", @"fl"]];
		//[_forecasts setObject:@"nada" forKey:@[@"miami", @"fl"]];
		//[_forecasts setObject:@"nada" forKey:@[@"cairo", @"ga"]];
		
		_updateQueue = dispatch_queue_create("updateQueue", NULL);
		_updateTimer = [NSTimer scheduledTimerWithTimeInterval:9*60.0f
														target:self
													  selector:@selector(updateData)
													  userInfo:nil
													   repeats:YES];
		
	}
	return self;
}

@end
