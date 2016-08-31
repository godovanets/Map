
#import "LocationManager.h"

@interface LocationManager ()

@end

@implementation LocationManager

+ (LocationManager *)newLocationWithName:(NSString *)name
                               andAdress:(NSString *)adress
                          andDescription:(NSString *)description
                             andLatitude:(NSNumber *)latitude
                           andLongtitude:(NSNumber *)longtitude {
  LocationManager *location = [[LocationManager alloc] init];

  location.locationName = name;
  location.locationAdress = adress;
  location.locationDescription = description;

  location.locationLatitude = latitude;
  location.locationLongtitude = longtitude;

  return location;
}


@end
