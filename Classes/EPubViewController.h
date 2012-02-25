//
//  EPubViewController.h
//  EpubDownload
//
//  Created by Macminiserver on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZipArchive.h"
#import "EPub.h"
#import "Chapter.h"


@class SearchResultsViewController;
@class SearchResult;

@interface EPubViewController : UIViewController<UIWebViewDelegate, ChapterDelegate,UIGestureRecognizerDelegate> {
	IBOutlet UIToolbar *toolbar;
	
	UIWebView *webView;
    
    UIBarButtonItem *chapterListButton;
    
    UIBarButtonItem *decTextSizeButton;
    
	UIBarButtonItem *incTextSizeButton;
    UIBarButtonItem *backButton;
    UILabel* currentPageLabel;
	
	EPub* loadedEpub;
	int currentSpineIndex;
	int currentPageInSpineIndex;
	int pagesInCurrentSpineCount;
	int currentTextSize;
	int totalPagesCount;
    
    BOOL epubLoaded;
    BOOL paginating;
    BOOL searching;
    
	
    UIAlertView *loadingView;
    BOOL isLoadingViewShow;
    BOOL isBarShow;
    
    UIActivityIndicatorView *loadingIndicator;
}

- (IBAction) showChapterIndex:(id)sender;
- (IBAction) increaseTextSizeClicked:(id)sender;
- (IBAction) decreaseTextSizeClicked:(id)sender;
- (IBAction) backButton:(id)sender;

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult;

- (void) loadEpub:(NSURL*) epubURL;

@property (nonatomic, retain) EPub* loadedEpub;
@property (nonatomic, retain) SearchResult* currentSearchResult;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *chapterListButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *decTextSizeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *incTextSizeButton;
@property (nonatomic, retain) IBOutlet UILabel *currentPageLabel;
@property BOOL searching;
@property (nonatomic, retain)UIAlertView *loadingView;
@end
