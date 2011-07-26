//
//  RootViewController.m
//  NTRSSReader
//
//  Created by Luis on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ArticleViewController.h"
#import "Item.h"
#import "NTErrorHandler.h"
#import "Config.h"

#define DATE_KEY @"date"
#define ITEM_STR @"Item"

@implementation RootViewController

@synthesize context = context_;
@synthesize fetchedResultsController = fetchedResultsController_;

#pragma mark Core Data

- (void)saveContext {
    NSError *error = nil;
    if (context_) {
        if ([context_ hasChanges] && ![context_ save:&error]) {
            [NTErrorHandler handleError:error];
        }
    }
}

#pragma mark -
#pragma mark Toolbar functionality

- (void)activityStarted {
	if (toolbar_.running)
		return;
	
	[toolbar_ runWithText:@"Loading from RSS..."];
	
	itemDeltaCounter_ = 0;
	
	[loader_ refresh];
}

- (void)stopActivity:(BOOL)success {
	[toolbar_ stopRunning:success];
}

#pragma mark -
#pragma mark Error handling

- (void)onError:(NSError *)error {
	[self stopActivity:NO];

	[NTErrorHandler handleError:error];	
}

#pragma mark -
#pragma mark NTRSSLoader delegate

- (NSFetchRequest *)itemFetchRequest {
	if (itemFetchRequest_ == nil) {
		itemFetchRequest_ = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:ITEM_STR inManagedObjectContext:context_];
		[itemFetchRequest_ setEntity:entity];
	}
	
	return itemFetchRequest_;
}

- (void)onItem:(NSDictionary *)itemDict {
	NSFetchRequest *fetchRequest = [self itemFetchRequest]; // lazy load and reuse fetch request
	
	// 'link' attribute is used as unique identifier, also it's indexed for faster performance in this fetch request
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(link == %@)", [itemDict objectForKey:LINK_KEY]]; 
	[fetchRequest setPredicate:predicate];
	
	NSArray *fetched = [context_ executeFetchRequest:fetchRequest error:nil];
	if ([fetched count] == 0) { // it's a new item!
		
		// if using incremental add (testing purpose)
		if (kIncrementalItemAdd && itemDeltaCounter_ >= kDeltaItemAdd) {
			return; // ignore it
		}
		itemDeltaCounter_++;
		
		// process new item
		Item *item = [NSEntityDescription insertNewObjectForEntityForName:ITEM_STR inManagedObjectContext:context_];
		item.title = [itemDict objectForKey:TITLE_KEY];
		item.link = [itemDict objectForKey:LINK_KEY];
		item.author = [itemDict objectForKey:AUTHOR_KEY];
		item.date = [NSDate date]; // NSDate use millisecond precision so it's ok to use it for sorting
		item.read = [NSNumber numberWithBool:NO];				
	}	
}

- (void)finished:(NSError *)error {
	// if using incremental add (testing purpose)
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController_ sections] objectAtIndex:0];
	itemDeltaCounter_ = MAX(kDeltaItemAdd, [sectionInfo numberOfObjects]);
	
	[self stopActivity:error == nil];

	if (error) {
		[self onError:error];
	} else {
        [self saveContext];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController_ sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	// Add text to it
	Item *item = [fetchedResultsController_ objectAtIndexPath:indexPath];
    cell.textLabel.text = item.title;
	if ([item.read boolValue] == YES) {
		cell.textLabel.font = [UIFont systemFontOfSize:13];		
		cell.detailTextLabel.text = [NSString stringWithFormat:@"read | %@", item.author];
	} else {
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"unread | %@", item.author];;
	}
	
	cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

#pragma mark -
#pragma mark NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:ITEM_STR inManagedObjectContext:context_];
    [fetchRequest setEntity:entity];
	
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] 
							  initWithKey:DATE_KEY ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	
    [fetchRequest setFetchBatchSize:20];
	
    NSFetchedResultsController *theFetchedResultsController = 
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
										managedObjectContext:context_ sectionNameKeyPath:nil 
												   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    fetchedResultsController_.delegate = self;
	
    [sort release];
    [fetchRequest release];
    [theFetchedResultsController release];
	
    return fetchedResultsController_;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [(UITableView *)self.view beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {	
    UITableView *tableView = (UITableView *)self.view;
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
			
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
			
        case NSFetchedResultsChangeInsert:
            [(UITableView *)self.view insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [(UITableView *)self.view deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [(UITableView *)self.view endUpdates];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"NSRSSReader";
	self.navigationController.toolbarHidden = NO;
    ((UITableView *)self.view).allowsSelection = NO;
	
	toolbar_ = [[NTToolbar alloc] initWithDelegate:self];
	[self setToolbarItems:[toolbar_ items] animated:NO];
	
	loader_ = [[NTRSSLoader alloc] initWithDelegate:self andUrl:[NSURL URLWithString:kUrl]];
	
	NSError *error = nil;
	
	if (![[self fetchedResultsController] performFetch:&error]) {
		[self onError:error];
	} else {
		[self activityStarted];		
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	Item *item = [fetchedResultsController_ objectAtIndexPath:indexPath];
	
	// mark as read!
	item.read = [NSNumber numberWithBool:YES];
    
    // persist read mark
    [self saveContext];
	
	// reload this now modified row
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
    
    // web views are kind of RAM consumers if reused so we prefer to alloc each time...
    UIViewController *detailViewController = [[ArticleViewController alloc] initWithUrl:[NSURL URLWithString:item.link]];	
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];    
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	
	[toolbar_ release];
	[loader_ release];
}

- (void)dealloc {
	[itemFetchRequest_ release];
	
	self.context = nil;
	self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
	
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


@end

