//
//  Item.h
//  NTRSSReader
//
//  Created by Luis on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Item :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * link;

@end



