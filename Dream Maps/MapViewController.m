
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "LocationManager.h"
#import "MapAnnotation.h"
#import "MapViewController.h"

@interface MapViewController ()<MKMapViewDelegate>

@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) CLGeocoder *geocoder;
@property(strong, nonatomic) MKDirections *directions;
@property(strong, nonatomic) MKPolyline *polyline;
@property(strong, nonatomic) MKPolygon *polygon;

#pragma mark - Outlets and Actions
@property(weak, nonatomic)
    IBOutlet UISegmentedControl *mapPresentationStyleControl;
@property(weak, nonatomic) IBOutlet UITextField *searchField;

- (IBAction)searchForLocationFromSearchField:(id)sender;
- (IBAction)changeMapPresentationStyleControl:(id)sender;
- (IBAction)addPinOnLongPressGesture:(id)sender;

@property(nonatomic) CGRect searchFieldOriginalFrame;

@end

@implementation MapViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self askForUserLocationUsage];

  [self refreshUI];
  self.geocoder = [CLGeocoder new];

  // Do any additional setup after loading the view, typically from a nib.
}

- (void)setLocation:(LocationManager *)location {
  // Make sure you're to not setting up the same location.
  if (_location != location) {
    _location = location;

    // Update the UI to reflect default locations
    [self refreshUI];
  }
}

- (void)refreshUI {
  if (_location) {
    _searchField.text =
        [NSString stringWithFormat:@"%@ | %@", _location.locationName,
                                   _location.locationAdress];

    MKCoordinateRegion selectedRegion;
    selectedRegion.center.latitude = [_location.locationLatitude doubleValue];
    selectedRegion.center.longitude =
        [_location.locationLongtitude doubleValue];
    selectedRegion.span.latitudeDelta = 0.03;
    selectedRegion.span.longitudeDelta = 0.03;

    [self.mapView setRegion:selectedRegion animated:YES];

    MapAnnotation *annotation = [[MapAnnotation alloc] init];

    annotation.title =
        [NSString stringWithFormat:@"%@", _location.locationName];
    annotation.subtitle =
        [NSString stringWithFormat:@"%@, %@", _location.locationDescription,
                                   _location.locationAdress];
    annotation.coordinate =
        CLLocationCoordinate2DMake([_location.locationLatitude doubleValue],
                                   [_location.locationLongtitude doubleValue]);

    [self.mapView addAnnotation:annotation];

  } else {
    _searchField.text = _searchField.text;
  }
}

#pragma mark - Custom Annotation View

- (MKAnnotationView *)mapView:(MKMapView *)myMap
            viewForAnnotation:(id<MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }

  static NSString *identifier = @"Annotation";

  MKPinAnnotationView *pin = (MKPinAnnotationView *)[self.mapView
      dequeueReusableAnnotationViewWithIdentifier:identifier];

  if (!pin) {
    pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                          reuseIdentifier:identifier];
    pin.pinTintColor = [UIColor redColor];
    pin.animatesDrop = YES;
    pin.canShowCallout = YES;

    // right button on anotation
    UIButton *addPinLocationToTableView =
        [UIButton buttonWithType:UIButtonTypeContactAdd];
    pin.rightCalloutAccessoryView = addPinLocationToTableView;
    [addPinLocationToTableView
               addTarget:self
                  action:@selector(addLocationFromMapToTableView:)
        forControlEvents:UIControlEventTouchDown];

    CLLocationCoordinate2D droppedAt = annotation.coordinate;
    NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);

    CLLocation *draglocation =
        [[CLLocation alloc] initWithLatitude:droppedAt.latitude
                                   longitude:droppedAt.longitude];

    [self.geocoder
        reverseGeocodeLocation:draglocation
             completionHandler:^(NSArray *placemark, NSError *error) {

               // set the title if we got any placemarks...
               if (placemark.count > 0) {
                 CLPlacemark *topResult = [placemark objectAtIndex:0];

                 NSString *ISOcountry = topResult.ISOcountryCode;

                 NSString *URLString = [NSString
                     stringWithFormat:
                         @"http://www.crwflags.com/fotw/images/%c/%@.gif",
                         [ISOcountry characterAtIndex:0], ISOcountry];
                 NSLog(@"URL string: %@", URLString);
                 NSURL *url = [NSURL URLWithString:URLString];
                 UIImage *image =
                     [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                 UIImage *tempImage = nil;
                 CGSize targetSize = CGSizeMake(90, 30);
                 UIGraphicsBeginImageContext(targetSize);
                 CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
                 thumbnailRect.origin = CGPointMake(35.0, 0.0);
                 thumbnailRect.size.width = targetSize.width;
                 thumbnailRect.size.height = targetSize.height;
                 [image drawInRect:thumbnailRect];
                 tempImage = UIGraphicsGetImageFromCurrentImageContext();
                 UIGraphicsEndImageContext();
                 UIImageView *imageView =
                     [[UIImageView alloc] initWithImage:tempImage];

                 // left button on anotation (view)
                 UIView *leftAccessoryViewForPin =
                     [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];

                 UIButton *putRoad =
                     [UIButton buttonWithType:UIButtonTypeCustom];
                 putRoad.frame = CGRectMake(0, 0, 30, 30);
                 //[putRoad sizeToFit];
                 [putRoad setBackgroundColor:[UIColor clearColor]];
                 [putRoad setTitle:@"->" forState:UIControlStateNormal];
                 [putRoad setTitleColor:[UIColor blueColor]
                               forState:UIControlStateNormal];
                 [putRoad addTarget:self
                               action:@selector(
                                          putRoadFromCurrentLocationToPin:)
                     forControlEvents:UIControlEventTouchDown];

                 [leftAccessoryViewForPin addSubview:putRoad];
                 [leftAccessoryViewForPin addSubview:imageView];

                 [pin setLeftCalloutAccessoryView:leftAccessoryViewForPin];
                 pin.draggable = YES;
               }

             }];

  } else {
    pin.annotation = annotation;
  }

  return pin;
}

#pragma mark - Making road from user location to pin

- (void)putRoadFromCurrentLocationToPin:(UIButton *)sender {
  [UIView animateWithDuration:0.5f
      animations:^{
        [sender setAlpha:0.5f];
      }
      completion:^(BOOL finished) {
        [sender setAlpha:1.0f];
      }];

  MapAnnotation *annotationView =
      [self.mapView.selectedAnnotations objectAtIndex:0];

  CLLocationCoordinate2D coordinate = annotationView.coordinate;

  MKDirectionsRequest *request = [MKDirectionsRequest new];
  request.source = [MKMapItem mapItemForCurrentLocation];

  MKPlacemark *placemark =
      [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];

  MKMapItem *destionation = [[MKMapItem alloc] initWithPlacemark:placemark];

  request.destination = destionation;

  request.transportType = MKDirectionsTransportTypeAny;

  request.requestsAlternateRoutes = YES;

  if ([self.directions isCalculating]) {
    [self.directions cancel];
  }

  self.directions = [[MKDirections alloc] initWithRequest:request];

  [self.directions
      calculateDirectionsWithCompletionHandler:^(
          MKDirectionsResponse *_Nullable response, NSError *_Nullable error) {

        if (error) {
          NSLog(@"Something is wrong with calculating directions");

        } else if (response.routes.count > 0) {
          [self.mapView removeOverlays:[self.mapView overlays]];

          NSMutableArray *array = [NSMutableArray array];

          for (MKRoute *route in response.routes) {
            [array addObject:route.polyline];
          }

          [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
        }
      }];
}



#pragma mark - Add location from map to table

- (void)addLocationFromMapToTableView:(UIButton *)sender {
  MapAnnotation *annotationView =
      [self.mapView.selectedAnnotations objectAtIndex:0];

  CLLocationCoordinate2D coordinate = annotationView.coordinate;

  CLLocation *location =
      [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                 longitude:coordinate.longitude];

  [self.geocoder cancelGeocode];
  [self.geocoder
      reverseGeocodeLocation:location
           completionHandler:^(NSArray<CLPlacemark *> *_Nullable placemarks,
                               NSError *_Nullable error) {

             if (placemarks.count > 0) {
               CLPlacemark *topResult = [placemarks objectAtIndex:0];

               NSString *thoroughfare = topResult.thoroughfare;
               NSString *subThoroughfare = topResult.subThoroughfare;
               if (!thoroughfare) {
                 thoroughfare = @"Unknown street";
                 subThoroughfare = @"unknown place";
               }

               NSString *locality = topResult.locality;
               NSString *country = topResult.country;
               NSString *ISOcountry = topResult.ISOcountryCode;
               if (!locality) {
                 locality = @"Unknown city";
               }
               if (!country) {
                 ISOcountry = @"unknown ISO code";
               }

               LocationManager *objectToSend = [LocationManager
                   newLocationWithName:[NSString
                                           stringWithFormat:@"%@, %@",
                                                            thoroughfare,
                                                            subThoroughfare]
                             andAdress:[NSString stringWithFormat:@"%@, %@",
                                                                  locality,
                                                                  ISOcountry]
                        andDescription:[NSString stringWithFormat:@"%@, %@",
                                                                  locality,
                                                                  ISOcountry]
                           andLatitude:[NSNumber
                                           numberWithDouble:coordinate.latitude]
                         andLongtitude:[NSNumber
                                           numberWithDouble:coordinate
                                                                .longitude]];

               [[NSNotificationCenter defaultCenter]
                   postNotificationName:@"myNotification"
                                 object:objectToSend];
             }

           }];
}

- (void)dealloc {
  if ([self.geocoder isGeocoding]) {
    [self.geocoder cancelGeocode];
  }
  if ([self.directions isCalculating]) {
    [self.directions cancel];
  }

  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Dragging pin

- (void)mapView:(MKMapView *)mapView
        annotationView:(MKAnnotationView *)view
    didChangeDragState:(MKAnnotationViewDragState)newState
          fromOldState:(MKAnnotationViewDragState)oldState {
  if (newState == MKAnnotationViewDragStateEnding) {
    CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
    NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);

    CLLocation *draglocation =
        [[CLLocation alloc] initWithLatitude:droppedAt.latitude
                                   longitude:droppedAt.longitude];

    [self.geocoder
        reverseGeocodeLocation:draglocation
             completionHandler:^(NSArray *placemark, NSError *error) {

               // initialize the title to "unknown" in case geocode has
               // failed...
               NSString *annotationTitle = @"Address unknown";
               NSString *annotationSubtitle = @"Adress unknown";

               // set the title if we got any placemarks...
               if (placemark.count > 0) {
                 CLPlacemark *topResult = [placemark objectAtIndex:0];
                 NSString *thoroughfare = topResult.thoroughfare;
                 NSString *subThoroughfare = topResult.subThoroughfare;
                 if (!thoroughfare) {
                   thoroughfare = @"Unknown street";
                   subThoroughfare = @"unknown place";
                 }
                 if (!subThoroughfare) {
                   thoroughfare = @"Unknown street";
                   subThoroughfare = @"unknown place";
                 }

                 annotationTitle = [NSString
                     stringWithFormat:@"%@, %@", thoroughfare, subThoroughfare];

                 NSString *locality = topResult.locality;
                 NSString *country = topResult.country;
                 NSString *ISOcountry = topResult.ISOcountryCode;
                 if (!locality) {
                   locality = @"Unknown city";
                 }
                 if (!country) {
                   country = @"unknown country";
                   ISOcountry = @"unknown ISO code";
                 }
                 annotationSubtitle =
                     [NSString stringWithFormat:@"%@, %@, %@", locality,
                                                country, ISOcountry];
               }

               // now create the annotation...
               MapAnnotation *annotationToAdd = [[MapAnnotation alloc] init];
               annotationToAdd.coordinate = view.annotation.coordinate;
               annotationToAdd.title = annotationTitle;
               annotationToAdd.subtitle = annotationSubtitle;

               [self.mapView removeAnnotation:view.annotation];
               [self.mapView addAnnotation:annotationToAdd];

             }];
  }
}

#pragma mark - Add pin on long press

- (IBAction)addPinOnLongPressGesture:(UIGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan) {
    CGPoint longTouchPoint = [sender locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
        [self.mapView convertPoint:longTouchPoint
              toCoordinateFromView:self.mapView];

    CLLocation *currentLocation =
        [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude
                                   longitude:touchMapCoordinate.longitude];

    [self.geocoder
        reverseGeocodeLocation:currentLocation
             completionHandler:^(NSArray *placemark, NSError *error) {

               // initialize the title to "unknown" in case geocode has
               // failed...
               NSString *annotationTitle = @"Address unknown";
               NSString *annotationSubtitle = @"Adress unknown";

               // set the title if we got any placemarks...
               if (placemark.count > 0) {
                 CLPlacemark *topResult = [placemark objectAtIndex:0];

                 NSString *thoroughfare = topResult.thoroughfare;
                 NSString *subThoroughfare = topResult.subThoroughfare;
                 if (!thoroughfare) {
                   thoroughfare = @"Unknown street";
                   subThoroughfare = @"unknown place";
                 }
                 annotationTitle = [NSString
                     stringWithFormat:@"%@, %@", thoroughfare, subThoroughfare];

                 NSString *locality = topResult.locality;
                 NSString *country = topResult.country;
                 NSString *ISOcountry = topResult.ISOcountryCode;
                 if (!locality) {
                   locality = @"Unknown city";
                 }
                 if (!country) {
                   country = @"unknown country";
                   ISOcountry = @"unknown ISO code";
                 }
                 annotationSubtitle =
                     [NSString stringWithFormat:@"%@, %@, %@", locality,
                                                country, ISOcountry];
               }

               // now create the annotation...
               MapAnnotation *annotationToAdd = [[MapAnnotation alloc] init];

               annotationToAdd.coordinate = touchMapCoordinate;
               annotationToAdd.title = annotationTitle;
               annotationToAdd.subtitle = annotationSubtitle;

               [self.mapView addAnnotation:annotationToAdd];
             }];
  }
}

#pragma mark - Asking user for using his location

- (void)askForUserLocationUsage {
  // asking for a permission to work with user location
  self.locationManager = [[CLLocationManager alloc] init];
  if ([CLLocationManager authorizationStatus] ==
      kCLAuthorizationStatusNotDetermined) {
    NSLog(@"\n\nAccess to location services not determined asking for "
          @"permission\n\n");
    if ([[NSBundle mainBundle] objectForInfoDictionaryKey:
                                   @"NSLocationWhenInUseUsageDescription"] &&
        [self.locationManager
            respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
      [self.locationManager requestWhenInUseAuthorization];
    }

  } else if ([CLLocationManager authorizationStatus] ==
             kCLAuthorizationStatusDenied) {
    NSLog(@"\n\nAccess to location services denied\n\n");

  } else if ([CLLocationManager authorizationStatus] ==
             kCLAuthorizationStatusRestricted) {
    NSLog(@"\n\nAccess to location services restricted\n\n");
  }

  if ([CLLocationManager authorizationStatus] ==
      kCLAuthorizationStatusAuthorizedAlways) {
    NSLog(@"\n\nAccess to location services always allowed\n\n");
  } else if ([CLLocationManager authorizationStatus] ==
             kCLAuthorizationStatusAuthorizedWhenInUse) {
    NSLog(@"\n\nAccess to location services when in use allowed\n\n");
  }
}

#pragma mark - Some UI features

- (IBAction)changeMapPresentationStyleControl:(id)sender {
  switch (self.mapPresentationStyleControl.selectedSegmentIndex) {
    case 0:
      self.mapView.mapType = MKMapTypeStandard;
      break;

    case 1:
      self.mapView.mapType = MKMapTypeSatelliteFlyover;
      break;

    case 2:

      self.mapView.mapType = MKMapTypeHybridFlyover;
      break;

    default:
      NSLog(@"Something is wrong with setting map presentation style");
      break;
  }
}

- (IBAction)searchForLocationFromSearchField:(id)sender {
  NSString *adressStringToSearch = self.searchField.text;

  [self.geocoder
      geocodeAddressString:adressStringToSearch
         completionHandler:^(NSArray<CLPlacemark *> *_Nullable placemarks,
                             NSError *_Nullable error) {

           if (error) {
             NSLog(@"%@", error);
           } else {
             CLPlacemark *placemark = [placemarks lastObject];
             float spanX = 0.03;
             float spanY = 0.03;
             MKCoordinateRegion region;
             region.center.latitude = placemark.location.coordinate.latitude;
             region.center.longitude = placemark.location.coordinate.longitude;
             region.span = MKCoordinateSpanMake(spanX, spanY);
             [self.mapView setRegion:region animated:YES];

             CLLocation *location =
                 [[CLLocation alloc] initWithLatitude:region.center.latitude
                                            longitude:region.center.longitude];

             [self.geocoder
                 reverseGeocodeLocation:location
                      completionHandler:^(NSArray *placemark, NSError *error) {

                        // initialize the title to "unknown" in case geocode has
                        // failed...
                        NSString *annotationTitle = @"Address unknown";
                        NSString *annotationSubtitle = @"Adress unknown";

                        // set the title if we got any placemarks...
                        if (placemark.count > 0) {
                          CLPlacemark *topResult = [placemark objectAtIndex:0];
                          NSString *thoroughfare = topResult.thoroughfare;
                          NSString *subThoroughfare = topResult.subThoroughfare;
                          if (!thoroughfare) {
                            thoroughfare = @"Unknown street";
                            subThoroughfare = @"unknown place";
                          }
                          if (!subThoroughfare) {
                            thoroughfare = @"Unknown street";
                            subThoroughfare = @"unknown place";
                          }

                          annotationTitle = [NSString
                              stringWithFormat:@"%@, %@", thoroughfare,
                                               subThoroughfare];

                          NSString *locality = topResult.locality;
                          NSString *country = topResult.country;
                          NSString *ISOcountry = topResult.ISOcountryCode;
                          if (!locality) {
                            locality = @"Unknown city";
                          }
                          if (!country) {
                            country = @"unknown country";
                            ISOcountry = @"unknown ISO code";
                          }
                          annotationSubtitle = [NSString
                              stringWithFormat:@"%@, %@, %@", locality, country,
                                               ISOcountry];
                        }

                        // now create the annotation...
                        MapAnnotation *annotationToAdd =
                            [[MapAnnotation alloc] init];
                        annotationToAdd.coordinate = CLLocationCoordinate2DMake(
                            region.center.latitude, region.center.longitude);
                        annotationToAdd.title = annotationTitle;
                        annotationToAdd.subtitle = annotationSubtitle;

                        [self.mapView addAnnotation:annotationToAdd];
                      }];
           }

         }];
}

@end
