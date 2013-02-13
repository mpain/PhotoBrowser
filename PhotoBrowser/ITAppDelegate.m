#import "ITAppDelegate.h"
#import "MRMainViewController.h"

@implementation ITAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[MRMainViewController new]];

    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor colorWithWhite:51.0 / 255.0 alpha:1.0];
    [self.window makeKeyAndVisible];
    return YES;
}


@end