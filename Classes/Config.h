/*
 *  Config.h
 *  NTRSSReader
 *
 *  Created by Luis on 7/15/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#define kUrl @"http://www.go-mono.com/monologue/index.rss"
//#define kUrl @"http://news.ycombinator.com/rss"

// for testing
#define kIncrementalItemAdd 0 // if set to 1, then on each refresh, up to kDeltaItemAdd items will be added
#define kDeltaItemAdd 4 // amount of items added per refresh