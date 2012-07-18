//
//  SPGooglePlacesAutocompletePlace.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompletePlace.h"

@interface SPGooglePlacesAutocompletePlace()
@property (nonatomic, readwrite) NSString *description;
@property (nonatomic, readwrite) NSString *reference;
@property (nonatomic, readwrite) NSString *identifier;
@end

@implementation SPGooglePlacesAutocompletePlace

@synthesize description, reference, identifier;

+ (SPGooglePlacesAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary {
    SPGooglePlacesAutocompletePlace *place = [[[self alloc] init] autorelease];
    place.description = [placeDictionary objectForKey:@"description"];
    place.reference = [placeDictionary objectForKey:@"reference"];
    place.identifier = [placeDictionary objectForKey:@"id"];
    return place;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Description: %@, Reference: %@, Identifier: %@",
            description, reference, identifier];
}

@end
