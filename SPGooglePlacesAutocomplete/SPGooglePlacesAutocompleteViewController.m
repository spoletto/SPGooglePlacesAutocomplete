//
//  SPGooglePlacesAutocompleteViewController.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompleteViewController.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"

@interface SPGooglePlacesAutocompleteViewController ()

@end

@implementation SPGooglePlacesAutocompleteViewController
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
        searchQuery.radius = 100.0;
        shouldBeginEditing = YES;
    }
    return self;
}

- (void)viewDidLoad {
    self.searchDisplayController.searchBar.placeholder = @"Search or Address";
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [selectedPlaceAnnotation release];
    [mapView release];
    [searchQuery release];
    [super dealloc];
}

- (IBAction)recenterMapToUserLocation:(id)sender {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = self.mapView.userLocation.coordinate;
    
    [self.mapView setRegion:region animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResultPlaces count];
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return [searchResultPlaces objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"GillSans" size:16.0];
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)recenterMapToPlacemark:(CLPlacemark *)placemark {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = placemark.location.coordinate;
    
    [self.mapView setRegion:region];
}

- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address {
    [self.mapView removeAnnotation:selectedPlaceAnnotation];
    [selectedPlaceAnnotation release];
    
    selectedPlaceAnnotation = [[MKPointAnnotation alloc] init];
    selectedPlaceAnnotation.coordinate = placemark.location.coordinate;
    selectedPlaceAnnotation.title = address;
    [self.mapView addAnnotation:selectedPlaceAnnotation];
}

- (void)dismissSearchControllerWhileStayingActive {
    // Animate out the table view.
    NSTimeInterval animationDuration = 0.3;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.searchDisplayController.searchResultsTableView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self.searchDisplayController.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchDisplayController.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
        if (error) {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not map selected Place");
        } else if (placemark) {
            [self addPlacemarkAnnotationToMap:placemark addressString:addressString];
            [self recenterMapToPlacemark:placemark];
            [self dismissSearchControllerWhileStayingActive];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }];
}

#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    searchQuery.location = self.mapView.userLocation.coordinate;
    searchQuery.input = searchString;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
        } else {
            [searchResultPlaces release];
            searchResultPlaces = [places retain];
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar isFirstResponder]) {
        // User tapped the 'clear' button.
        shouldBeginEditing = NO;
        [self.searchDisplayController setActive:NO];
        [self.mapView removeAnnotation:selectedPlaceAnnotation];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (shouldBeginEditing) {
        // Animate in the table view.
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.searchDisplayController.searchResultsTableView.alpha = 1.0;
        [UIView commitAnimations];
        
        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    }
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

#pragma mark -
#pragma mark MKMapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapViewIn viewForAnnotation:(id <MKAnnotation>)annotation {
    if (mapViewIn != self.mapView || [annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *annotationIdentifier = @"SPGooglePlacesAutocompleteAnnotation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
    }
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [detailButton addTarget:self action:@selector(annotationDetailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = detailButton;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    // Whenever we've dropped a pin on the map, immediately select it to present its callout bubble.
    [self.mapView selectAnnotation:selectedPlaceAnnotation animated:YES];
}

- (void)annotationDetailButtonPressed:(id)sender {
    // Detail view controller application logic here.
}

@end
