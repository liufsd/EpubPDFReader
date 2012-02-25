//
//  ChapterList.h
//  EpubDownload
//
//  Created by Macminiserver on 9/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPubViewController.h"
@interface ChapterList : UITableViewController{
    EPubViewController* epubViewController;
}
@property(nonatomic, assign) EPubViewController* epubViewController;

@end
