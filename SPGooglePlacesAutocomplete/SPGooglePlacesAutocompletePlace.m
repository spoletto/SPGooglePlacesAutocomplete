//
//  SPGooglePlacesAutocompletePlace.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompletePlace.h"

@interface SPGooglePlacesAutocompletePlace()
@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, retain, readwrite) NSString *reference;
@property (nonatomic, retain, readwrite) NSString *identifier;
@end

@implementation SPGooglePlacesAutocompletePlace

@synthesize name, reference, identifier;

+ (SPGooglePlacesAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary {
    SPGooglePlacesAutocompletePlace *place = [[[self alloc] init] autorelease];
    place.name = [placeDictionary objectForKey:@"description"];
    place.reference = [placeDictionary objectForKey:@"reference"];
    place.identifier = [placeDictionary objectForKey:@"id"];
    return place;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, Reference: %@, Identifier: %@",
            name, reference, identifier];
}

- (void)dealloc {
    [name release];
    [reference release];
    [identifier release];
    [super dealloc];
}

@end
