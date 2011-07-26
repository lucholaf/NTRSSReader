//
//  RootViewController.h
//  NTRSSReader
//
//  Created by Luis on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTToolbar.h"
#import "NTRSSLoader.h"

@interface RootViewController : UITableViewController<UIWebViewDelegate, NSFetchedResultsControllerDelegate, NTToolbarDelegate, NTRSSLoaderDelegate> {
	NSFetchedResultsController *fetchedResultsController_;
	
	NTToolbar *toolbar_;
	NTRSSLoader *loader_;
	
	NSManagedObjectContext *context_;
	
	int itemDeltaCounter_;
	
	NSFetchRequest *itemFetchRequest_;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *context;

@end
