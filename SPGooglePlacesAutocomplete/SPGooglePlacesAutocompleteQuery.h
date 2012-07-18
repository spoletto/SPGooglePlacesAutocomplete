//
//  SPGooglePlacesAutocompleteQuery.h
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "SPGooglePlacesAutocompleteUtilities.h"

@interface SPGooglePlacesAutocompleteQuery : NSObject {
    NSURLConnection *googleConnection;
    NSMutableData *responseData;
}

@property (nonatomic, copy, readonly) SPGooglePlacesAutocompleteResultBlock resultBlock;

+ (SPGooglePlacesAutocompleteQuery *)query;

/*!
 Pulls down places that match the query. If -fetchPlaces is called twice, the first request will be cancelled and the request will be re-issued using the current property values.
 */
- (void)fetchPlaces:(SPGooglePlacesAutocompleteResultBlock)block;

#pragma mark -
#pragma mark Required parameters

/*!
 The text string on which to search. The Place service will return candidate matches based on this string and order results based on their perceived relevance. Defaults to nil.
 */
@property (nonatomic, retain) NSString *input;

/*!
 Indicates whether or not the Place request came from a device using a location sensor (e.g. a GPS) to determine the location sent in this request. This value must be either true or false. Defaults to YES.
 */
@property (nonatomic) BOOL sensor;

/*!
 Your application's API key. This key identifies your application for purposes of quota management. Visit the APIs Console to select an API Project and obtain your key. Maps API for Business customers must use the API project created for them as part of their Places for Business purchase. Defaults to kGoogleAPIKey.
 */
@property (nonatomic, retain) NSString *key;

#pragma mark -
#pragma mark Optional parameters

/*!
 The character position in the input term at which the service uses text for predictions. For example, if the input is 'Googl' and the completion point is 3, the service will match on 'Goo'. The offset should generally be set to the position of the text caret. If no offset is supplied, the service will use the entire term.
 */
@property (nonatomic) NSUInteger offset;

/*!
 The point around which you wish to retrieve Place information.
 */
@property (nonatomic) CLLocationCoordinate2D location;

/*!
 The distance (in meters) within which to return Place results. Note that setting a radius biases results to the indicated area, but may not fully restrict results to the specified area.
 */
@property (nonatomic) CGFloat radius;

/*!
 The language in which to return results. See the supported list of domain languages. Note that we often update supported languages so this list may not be exhaustive. If language is not supplied, the Place service will attempt to use the native language of the domain from which the request is sent.
 */
@property (nonatomic, retain) NSString *language;

/*!
 The types of Place results to return. If no type is specified, all types will be returned.
 */
@property (nonatomic) SPGooglePlacesAutocompletePlaceType types;

@end

