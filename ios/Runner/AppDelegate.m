#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // reset unread badge on app open
  UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // reset unread badge on app reopen
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
}

@end
