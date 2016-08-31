
#import <UIKit/UIKit.h>

@class MKMapView, LocationManager;

@interface MapViewController : UIViewController<UISplitViewControllerDelegate>

@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, strong) LocationManager *location;

@end
