#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LocationManager : NSObject

@property(strong, nonatomic) NSString *locationName;
@property(strong, nonatomic) NSString *locationAdress;
@property(strong, nonatomic) NSNumber *locationLatitude;
@property(strong, nonatomic) NSNumber *locationLongtitude;
@property(strong, nonatomic) NSString *locationDescription;

// Factory class method to create new locations
+ (LocationManager *)newLocationWithName:(NSString *)name
                               andAdress:(NSString *)adress
                          andDescription:(NSString *)description
                             andLatitude:(NSNumber *)latitude
                           andLongtitude:(NSNumber *)longtitude;

@end
