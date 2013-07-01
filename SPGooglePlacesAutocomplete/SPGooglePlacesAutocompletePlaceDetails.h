//
//  SPGooglePlacesAutocompletePlaceDetails.h
//  SPGooglePlacesAutocomplete
//
//  Created by Michael Vosseller on 6/30/13.
//  Copyright (c) 2013 Stephen Poletto. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface SPGooglePlacesAutocompletePlaceDetails : NSObject {
    NSDictionary *dictionary;
}

+ (SPGooglePlacesAutocompletePlaceDetails *)placeDetailsFromDictionary:(NSDictionary *)placeDetailsDictionary;

@property (nonatomic, readonly) NSDictionary *dictionary;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *reference;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *formattedAddress;
@property (nonatomic, readonly) CLLocation *location;

@end
