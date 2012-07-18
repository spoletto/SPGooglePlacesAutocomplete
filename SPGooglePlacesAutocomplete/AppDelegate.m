//
//  AppDelegate.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "AppDelegate.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompleteViewController.h"

@implementation AppDelegate

@synthesize window;

- (void)testCode {
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
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];    
    
    SPGooglePlacesAutocompleteViewController *viewController = [[[SPGooglePlacesAutocompleteViewController alloc] init] autorelease];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
