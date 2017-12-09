//
//  main.m
//  ForecastServer
//
//  Created by Thomas Williams on 12/4/17.
//  Copyright © 2017 Thomas Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerURLEncodedFormRequest.h"
#import "WeatherList.h"

WeatherList *forecaster;

NSArray *parseLocation(NSString *locationString) {
	char *c_loc = (char*)[locationString cStringUsingEncoding:NSUTF8StringEncoding];
	char *city = strtok(c_loc, "~");
	char *state = strtok(NULL, "~");
	return @[[NSString stringWithUTF8String:city].lowercaseString, [NSString stringWithUTF8String:state].lowercaseString];
}

GCDWebServerResponse *handleRequest(GCDWebServerURLEncodedFormRequest *req) {
	
	if(req.contentLength == 0) {
		return [GCDWebServerResponse responseWithStatusCode:500];
	}

	NSArray *key = parseLocation(req.jsonObject[@"data"]);
	NSString *city = key[0];
	NSString *state = key[1];
	if(forecaster.forecasts[key]) {
		//return the forecast
		id obj = forecaster.forecasts[key];
		if([obj isKindOfClass:[NSString class]]) {
			return [GCDWebServerResponse responseWithStatusCode:500];
		}
		GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithJSONObject:obj
																				  contentType:@"application/json"];
		return response;
	} else {
		[forecaster updateDataForCity:city state:state];
		return [GCDWebServerResponse responseWithStatusCode:404];
	}
	return [GCDWebServerResponse responseWithStatusCode:501];
}



int main(int argc, const char * argv[]) {
	@autoreleasepool {
		GCDWebServer *server = [[GCDWebServer alloc] init];
		forecaster = [[WeatherList alloc] init];
		[forecaster updateData];
		[server addHandlerForMethod:@"POST"
							   path:@"/weather"
					   requestClass:[GCDWebServerURLEncodedFormRequest class]
					   processBlock:^GCDWebServerResponse*(GCDWebServerRequest *req) {
			return handleRequest((GCDWebServerURLEncodedFormRequest*)req);
		}];
		
		[server runWithPort:8080 bonjourName:nil];
	}
    return 0;
}
