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

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * read;
@property (nonatomic, strong) NSString * link;

@end



