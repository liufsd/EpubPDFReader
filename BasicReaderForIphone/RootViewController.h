//
//  RootViewController.h
//  BasicReaderForIphone
//
//  Created by Macminiserver on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPubViewController.h"
#import "ReaderViewController.h"
#import "TextReader.h"

@interface RootViewController : UITableViewController <ReaderViewControllerDelegate>{
    EPubViewController *epubView;
}

@end
