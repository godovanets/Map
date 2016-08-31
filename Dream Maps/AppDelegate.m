

#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "MapViewController.h"
#import "TableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.

  UISplitViewController *splitViewController =
      (UISplitViewController *)self.window.rootViewController;
    MapViewController *mapViewController =
      [splitViewController.viewControllers objectAtIndex:1];

  splitViewController.delegate = mapViewController;

  [UIApplication sharedApplication].statusBarStyle =
      UIStatusBarStyleLightContent;

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  }

- (void)applicationDidEnterBackground:(UIApplication *)application {
  }

- (void)applicationWillEnterForeground:(UIApplication *)application {
  
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  
}

- (void)applicationWillTerminate:(UIApplication *)application {
 
}

@end
