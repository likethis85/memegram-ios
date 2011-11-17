//
//  MGAppDelegate.m
//  Memegram
//
//  Created by William Fleming on 11/14/11.
//  Copyright (c) 2011 Endeca Technologies. All rights reserved.
//

#import "MGAppDelegate.h"

#import "SelectInstagramMediaController.h"

#import "MGDetailViewController.h"
#import "IGInstagramAPI.h"
#import "NSURL+WillFleming.h"

#pragma mark - constants

NSString * const kDefaultsInstagramToken = @"InstagramToken";
NSString * const kDefaultsMemegramToken = @"MemegramToken";
NSString * const kAuthCallbackURL = @"auth_callback";
NSString * const kAuthCallbackURLInstagramTokenParam = @"instagram_token";
NSString * const kAuthCallbackURLApiTokenParam = @"api_token";

#pragma mark -
@interface MGAppDelegate (Private)

- (void) ensureUserLoggedIn;

@end


#pragma mark -
@implementation MGAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Setup API base stuff
  [IGInstagramAPI setClientId:OAUTH_INSTAGRAM_KEY];
  [IGInstagramAPI setOAuthRedirctURL:OAUTH_INSTAGRAM_REDIRECT_URL];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [IGInstagramAPI setAccessToken:[defaults stringForKey:kDefaultsInstagramToken]];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    SelectInstagramMediaController *masterViewController = [[SelectInstagramMediaController alloc] initWithNibName:nil bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    self.window.rootViewController = self.navigationController;
  } else {
//    iPad not currently supported!
//    SelectInstagramMediaController *masterViewController = [[SelectInstagramMediaController alloc] initWithNibName:@"MGMasterViewController_iPad" bundle:nil];
//    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
//    
//    MGDetailViewController *detailViewController = [[MGDetailViewController alloc] initWithNibName:@"MGDetailViewController_iPad" bundle:nil];
//    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
//
//    self.splitViewController = [[UISplitViewController alloc] init];
//    self.splitViewController.delegate = detailViewController;
//    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
//    
//    self.window.rootViewController = self.splitViewController;
//    masterViewController.detailViewController = detailViewController;
  }
  
  [self.window makeKeyAndVisible];
  
  [self ensureUserLoggedIn];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  if ([kAuthCallbackURL isEqual:[url host]]) {
    NSDictionary *params = [url queryDictionary];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[params objectForKey:kAuthCallbackURLApiTokenParam] forKey:kDefaultsMemegramToken];
    [defaults setObject:[params objectForKey:kAuthCallbackURLInstagramTokenParam] forKey:kDefaultsInstagramToken];
    [defaults synchronize];
    [IGInstagramAPI setAccessToken:[params objectForKey:kAuthCallbackURLInstagramTokenParam]];
    //TODO handle failure here (params not present, etc. passed error codes?)
    
    // dismiss our auth controller, get back to the regular application
    [[[UIApplication sharedApplication] keyWindow] resignKeyWindow];
    
    return YES;
  }
  return NO;
}

- (void)saveContext
{
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil)
  {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
    {
      DLOG(@"Unresolved error %@, %@", error, [error userInfo]);
    } 
  }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Memegram" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Memegram.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
#ifdef DEBUG
      // quick fix (for dev) - attempt a delete and try again
      // potential infinite loop if things are really messed up
      [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
      __persistentStoreCoordinator = nil;
      [self persistentStoreCoordinator];
#else
      // there was an issue we failed to address
#endif
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end


#pragma mark -
@implementation MGAppDelegate (Private)

// both the memegram & instagram keys must be valid & present
- (void) ensureUserLoggedIn {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSString *memegramToken = [defaults stringForKey:kDefaultsMemegramToken];
  
  BOOL clearInstagramToken = NO;
  
  if (!memegramToken) {
    clearInstagramToken = YES;
  } else {
    //TODO - set clearInstagramToken to YES if token isn't valid
  }
  
  if (clearInstagramToken) {
    // make sure we end up re-authing, because we don't have a valid memegram taken
    [IGInstagramAPI setAccessToken:nil];
  }
  
  // IG API will check IG token, and prompt for reauth if not valid
  [IGInstagramAPI authenticateUser];
}

@end