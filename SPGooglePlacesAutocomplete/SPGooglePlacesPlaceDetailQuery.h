//
//  SPGooglePlacesPlaceDetailQuery.h
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/18/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompleteUtilities.h"

@interface SPGooglePlacesPlaceDetailQuery : NSObject {
    NSURLConnection *googleConnection;
    NSMutableData *responseData;
}

@property (nonatomic, copy, readonly) SPGooglePlacesPlaceDetailResultBlock resultBlock;

+ (SPGooglePlacesPlaceDetailQuery *)query;

/*!
 Issues a Place Details request and pulls down the results. If called twice, the first request will be cancelled and the request will be re-issued using the current property values.
 */
- (void)fetchPlaceDetail:(SPGooglePlacesPlaceDetailResultBlock)block;

#pragma mark -
#pragma mark Required parameters

/*!
 A textual identifier that uniquely identifies a place, returned from a Place search request.
 */
@property (nonatomic, retain) NSString *reference;

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
 The language in which to return results. See the supported list of domain languages. Note that we often update supported languages so this list may not be exhaustive. If language is not supplied, the Place service will attempt to use the native language of the domain from which the request is sent.
 */
@property (nonatomic, retain) NSString *language;

@end
