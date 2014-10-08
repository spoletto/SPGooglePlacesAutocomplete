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

- (void)resolveEstablishmentPlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    SPGooglePlacesPlaceDetailQuery *query = [SPGooglePlacesPlaceDetailQuery query];
    query.placeIdentifier = self.identifier;
    [query fetchPlaceDetail:^(NSDictionary *placeDictionary, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            if ([placeDictionary objectForKey:@"geometry"]) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(360.0f, 360.0f);
                
                NSDictionary *location = [[placeDictionary objectForKey:@"geometry"] objectForKey:@"location"];
                
                if ([location objectForKey:@"lat"] && [location objectForKey:@"lng"]) {
                    CGFloat latitude = 360.0f;
                    CGFloat longitude = 360.0f;
                    
                    if ([location objectForKey:@"lat"]) {
                        latitude = [[location objectForKey:@"lat"] floatValue];
                    }
                    
                    if ([location objectForKey:@"lng"]) {
                        longitude = [[location objectForKey:@"lng"] floatValue];
                    }
                    
                    coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                }
                
                if (CLLocationCoordinate2DIsValid(coordinate)) {
                    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
                    block(placemark, self.name, error);
                    return;
                }
            }
            
            NSString *addressString = [placeDictionary objectForKey:@"formatted_address"];
            [geocoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error) {
                    SPPresentAlertViewWithErrorAndTitle(error, @"Could not map selected Place");
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
