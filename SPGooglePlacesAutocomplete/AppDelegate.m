//
//  AppDelegate.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "AppDelegate.h"
#import "SPGooglePlacesAutocompleteQuery.h"
@implementation AppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    SPGooglePlacesAutocompleteQuery *query = [SPGooglePlacesAutocompleteQuery query];
    query.input = @"370 fillmo";
    query.radius = 500;
    query.language = @"en";
    query.types = SPPlaceTypeGeocode;
    query.location = CLLocationCoordinate2DMake(37.76999, -122.44696);
    query.offset = 9;
    [query fetchPlaces:^(NSArray *places, NSError *error) {
        NSLog(@"places %@", places);
    }];
    
    return YES;
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
