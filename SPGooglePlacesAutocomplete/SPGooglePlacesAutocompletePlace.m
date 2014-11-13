//
//  SPGooglePlacesAutocompletePlace.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompletePlace.h"
#import "SPGooglePlacesPlaceDetailQuery.h"

#import <MapKit/MapKit.h>

@interface SPGooglePlacesAutocompletePlace()
@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, retain, readwrite) NSString *reference;
@property (nonatomic, retain, readwrite) NSString *identifier;
@property (nonatomic, readwrite) SPGooglePlacesAutocompletePlaceType type;
@end

@implementation SPGooglePlacesAutocompletePlace

@synthesize name, reference, identifier, type;

+ (SPGooglePlacesAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary {
    SPGooglePlacesAutocompletePlace *place = [[[self alloc] init] autorelease];
    place.name = [placeDictionary objectForKey:@"description"];
    place.reference = [placeDictionary objectForKey:@"reference"];
    place.identifier = [placeDictionary objectForKey:@"place_id"];
    place.type = SPPlaceTypeFromDictionary(placeDictionary);
    return place;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, Reference: %@, Identifier: %@, Type: %@",
            name, reference, identifier, SPPlaceTypeStringForPlaceType(type)];
}

- (CLGeocoder *)geocoder {
    if (!geocoder) {
        geocoder = [[CLGeocoder alloc] init];
    }
    return geocoder;
}

- (void)resolveReferenceIdentifierToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    SPGooglePlacesPlaceDetailQuery *query = [SPGooglePlacesPlaceDetailQuery query];
    query.placeIdentifier = self.identifier;
    [query fetchPlaceDetail:^(NSDictionary *placeDictionary, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            if (placeDictionary) {
                NSString *placeAddress = [placeDictionary objectForKey:@"formatted_address"];
                NSDictionary *placeGeometryDictionary = [placeDictionary objectForKey:@"geometry"];
                NSDictionary *placeLocationDictionary = nil;
                NSNumber *latitude = nil;
                NSNumber *longitude = nil;
                
                if (placeGeometryDictionary) {
                    placeLocationDictionary = [placeGeometryDictionary objectForKey:@"location"];
                }
                
                if (placeLocationDictionary) {
                    latitude = [placeLocationDictionary objectForKey:@"lat"];
                    longitude = [placeLocationDictionary objectForKey:@"lng"];
                }
                
                if (latitude && longitude) {
                    CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
                    [[self geocoder] reverseGeocodeLocation:placeLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                        if (error) {
                            block(nil, nil, error);
                        } else {
                            CLPlacemark *placemark = [placemarks firstObject];
                            block(placemark, self.name, error);
                        }
                    }];
                } else if (placeAddress) {
                    [[self geocoder] geocodeAddressString:placeAddress completionHandler:^(NSArray *placemarks, NSError *error) {
                        if (error) {
                            block(nil, nil, error);
                        } else {
                            CLPlacemark *placemark = [placemarks firstObject];
                            block(placemark, self.name, error);
                        }
                    }];
                } else {
                    NSString *errorDomain = [[NSBundle mainBundle] bundleIdentifier];
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey:NSLocalizedString(@"Could not resolve place.", nil) };
                    error = [[NSError alloc] initWithDomain:errorDomain code:-1 userInfo:userInfo];
                    
                    block(nil, self.name, error);
                }
            } else {
                NSString *errorDomain = [[NSBundle mainBundle] bundleIdentifier];
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey:NSLocalizedString(@"Could not resolve place.", nil) };
                error = [[NSError alloc] initWithDomain:errorDomain code:-1 userInfo:userInfo];
                
                block(nil, self.name, error);
            }
        }
    }];
}

- (void)resolveGecodePlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    [[self geocoder] geocodeAddressString:self.name completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            CLPlacemark *placemark = [placemarks firstObject];
            block(placemark, self.name, error);
        }
    }];
}

- (void)resolveToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    if (self.identifier.length > 0) {
        // If there is already a Google Place API reference number, there should
        // not be a need to attempt to geocode using the (inexact) address.
        [self resolveReferenceIdentifierToPlacemark:block];
    } else {
        // Geocode places already have their address stored in the 'name' field.
        [self resolveGecodePlaceToPlacemark:block];
    }
}

- (void)dealloc {
    [name release];
    [reference release];
    [identifier release];
    [geocoder release];
    [super dealloc];
}

@end
