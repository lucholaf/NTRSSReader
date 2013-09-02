//
//  NTRSSReaderAppDelegate.h
//  NTRSSReader
//
//  Created by Luis on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface NTRSSReaderAppDelegate : NSObject <UIApplicationDelegate> {
@private
    UIWindow *window_;
	UINavigationController *navController_;
	
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;	
}

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)saveContext;

@end

