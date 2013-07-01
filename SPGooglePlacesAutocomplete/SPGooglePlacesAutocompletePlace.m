//
//  SPGooglePlacesAutocompletePlace.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompletePlace.h"
#import "SPGooglePlacesAutocompletePlaceDetails.h"
#import "SPGooglePlacesPlaceDetailQuery.h"

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
    place.identifier = [placeDictionary objectForKey:@"id"];
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

- (void)fetchPlaceDetails:(SPGooglePlacesPlaceDetailResultBlock)block {
    SPGooglePlacesPlaceDetailQuery *query = [SPGooglePlacesPlaceDetailQuery query];
    query.reference = self.reference;
    [query fetchPlaceDetail:block];
}

- (void)resolveEstablishmentPlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    
    [self fetchPlaceDetails:^(SPGooglePlacesAutocompletePlaceDetails *placeDetails, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            NSString *addressString = placeDetails.formattedAddress;
            [[self geocoder] geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error) {
                    block(nil, nil, error);
                } else {
                    CLPlacemark *placemark = [placemarks onlyObject];
                    block(placemark, self.name, error);
                }
            }];
        }
    }];
}

- (void)resolveGecodePlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    [[self geocoder] geocodeAddressString:self.name completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            CLPlacemark *placemark = [placemarks onlyObject];
            block(placemark, self.name, error);
        }
    }];
}

- (void)resolveToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    if (type == SPPlaceTypeGeocode) {
        // Geocode places already have their address stored in the 'name' field.
        [self resolveGecodePlaceToPlacemark:block];
    } else {
        [self resolveEstablishmentPlaceToPlacemark:block];
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
