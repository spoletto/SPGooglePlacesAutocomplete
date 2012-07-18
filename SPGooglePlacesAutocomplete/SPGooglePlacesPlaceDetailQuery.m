//
//  SPGooglePlacesPlaceDetailQuery.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/18/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesPlaceDetailQuery.h"

@interface SPGooglePlacesPlaceDetailQuery()
@property (nonatomic, copy, readwrite) SPGooglePlacesPlaceDetailResultBlock resultBlock;
@end

@implementation SPGooglePlacesPlaceDetailQuery

@synthesize reference, sensor, key, language, resultBlock;

+ (SPGooglePlacesPlaceDetailQuery *)query {
    return [[[self alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    if (self) {
        // Setup default property values.
        self.sensor = YES;
        self.key = kGoogleAPIKey;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Query URL: %@", [self googleURLString]];
}

- (void)dealloc {
    [googleConnection release];
    [responseData release];
    [reference release];
    [key release];
    [language release];
    [super dealloc];
}

- (NSString *)googleURLString {
    NSMutableString *url = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=%@&key=%@",
                            reference, SPBooleanStringForBool(sensor), key];
    if (language) {
        [url appendFormat:@"&language=%@", language];
    }
    return url;
}

- (void)cleanup {
    [googleConnection release];
    [responseData release];
    googleConnection = nil;
    responseData = nil;
    self.resultBlock = nil;
}

- (void)cancelOutstandingRequests {
    [googleConnection cancel];
    [self cleanup];
}

- (void)fetchPlaceDetail:(SPGooglePlacesPlaceDetailResultBlock)block {
    if (!SPEnsureGoogleAPIKey()) {
        return;
    }
    
    [self cancelOutstandingRequests];
    self.resultBlock = block;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self googleURLString]]];
    googleConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    responseData = [[NSMutableData alloc] init];
}

#pragma mark -
#pragma mark NSURLConnection Delegate

- (void)failWithError:(NSError *)error {
    if (self.resultBlock != nil) {
        self.resultBlock(nil, error);
    }
    [self cleanup];
}

- (void)succeedWithPlace:(NSDictionary *)placeDictionary {
    if (self.resultBlock != nil) {
        self.resultBlock(placeDictionary, nil);
    }
    [self cleanup];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == googleConnection) {
        [responseData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connnection didReceiveData:(NSData *)data {
    if (connnection == googleConnection) {
        [responseData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == googleConnection) {
        [self failWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == googleConnection) {
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        if (error) {
            [self failWithError:error];
            return;
        }
        if ([[response objectForKey:@"status"] isEqualToString:@"OK"]) {
            [self succeedWithPlace:[response objectForKey:@"result"]];
        }
                
        // Must have received a status of UNKNOWN_ERROR, ZERO_RESULTS, OVER_QUERY_LIMIT, REQUEST_DENIED or INVALID_REQUEST.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[response objectForKey:@"status"] forKey:NSLocalizedDescriptionKey];
        [self failWithError:[NSError errorWithDomain:@"com.spoletto.googleplaces" code:kGoogleAPINSErrorCode userInfo:userInfo]];
    }
}

@end
