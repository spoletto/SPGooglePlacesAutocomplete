//
//  SPGooglePlacesAutocompletePlaceDetails.m
//  SPGooglePlacesAutocomplete
//
//  Created by Michael Vosseller on 6/30/13.
//  Copyright (c) 2013 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompletePlaceDetails.h"

@interface SPGooglePlacesAutocompletePlaceDetails()
@property (nonatomic, retain, readwrite) NSDictionary *dictionary;
@end


@implementation SPGooglePlacesAutocompletePlaceDetails

@synthesize dictionary;

+ (SPGooglePlacesAutocompletePlaceDetails *)placeDetailsFromDictionary:(NSDictionary *)placeDetailsDictionary {
    SPGooglePlacesAutocompletePlaceDetails *placeDetails = [[[SPGooglePlacesAutocompletePlaceDetails alloc] init] autorelease];
    placeDetails.dictionary = placeDetailsDictionary;
    return placeDetails;
}

- (void) dealloc {
    [super dealloc];
    [dictionary release];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"Name: %@, Reference: %@, Identifier: %@, Location: %@",
            self.name, self.reference, self.identifier, self.location];
}

- (NSString *) name {
    return self.dictionary[@"name"];
}

- (NSString *) reference {
    return self.dictionary[@"reference"];
}

- (NSString *) identifier {
    return self.dictionary[@"id"];
}

- (NSString*) formattedAddress {
    return self.dictionary[@"formatted_address"];
}

- (CLLocation*) location {
    
    CLLocation *location = nil;
    
    NSDictionary *locationDictionary = [self locationDictionary];
    NSNumber *latitudeAsNumber = locationDictionary[@"lat"];
    NSNumber *lonitudeAsNumber = locationDictionary[@"lng"];
    
    if (latitudeAsNumber && lonitudeAsNumber) {
        CLLocationDegrees latitudeDegrees = [latitudeAsNumber doubleValue];
        CLLocationDegrees longitudeDegrees = [lonitudeAsNumber doubleValue];
        location = [[[CLLocation alloc] initWithLatitude:latitudeDegrees longitude:longitudeDegrees] autorelease];    
    }
    
    return location;
}

- (NSDictionary*) geometryDictionary {
    return self.dictionary[@"geometry"];
}

- (NSDictionary*) locationDictionary {
    return [self geometryDictionary][@"location"];
}

@end
