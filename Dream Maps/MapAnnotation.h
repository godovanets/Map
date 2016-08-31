

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface MapAnnotation : NSObject<MKAnnotation>

// Center latitude and longitude of the annotation view.
// The implementation of this property must be KVO compliant.
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

// Title and subtitle for use by selection UI.
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *subtitle;

@end
