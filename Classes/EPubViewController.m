//
//  EPubViewController.m
//  EpubDownload
//
//  Created by Macminiserver on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EPubViewController.h"
#import "SearchResultsViewController.h"
#import "SearchResult.h"
#import "UIWebView+SearchWebView.h"
#import "Chapter.h"
#import "ChapterList.h"
#import <QuartzCore/QuartzCore.h>

@interface EPubViewController()

//Spine 指的是文件出現的順序
- (void) gotoNextSpine;
- (void) gotoPrevSpine;
- (void) gotoNextPage;
- (void) gotoPrevPage;

- (int) getGlobalPageCount;
- (void) gotoPageInCurrentSpine: (int)pageIndex;
- (void) updatePagination;
- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex;


@end

@implementation EPubViewController

@synthesize loadedEpub, toolbar, webView; 
@synthesize chapterListButton,decTextSizeButton, incTextSizeButton;
@synthesize currentPageLabel, searching;
@synthesize currentSearchResult;
@synthesize loadingView;

- (void) loadEpub:(NSURL*) epubURL{
    isBarShow = YES;
    currentSpineIndex = 0;
    currentPageInSpineIndex = 0;
    pagesInCurrentSpineCount = 0;
    totalPagesCount = 0;
	searching = NO;
    epubLoaded = NO;
    self.loadedEpub = [[EPub alloc] initWithEPubPath:[epubURL path]];
    epubLoaded = YES;
    //NSLog(@"讀取Epub檔案");
    [self performSelector:@selector(updatePagination) withObject:nil afterDelay:0.0];
}

- (void) chapterDidFinishLoad:(Chapter *)chapter{
    totalPagesCount+= chapter.pageCount;
	if(chapter.chapterIndex + 1 < [loadedEpub.spineArray count]){
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] setDelegate:self];
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize];
		[currentPageLabel setText:[NSString stringWithFormat:@" ... /%d", totalPagesCount]];
	} 
    else {
        [currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		paginating = NO;
		//NSLog(@"分頁結束");
        [self performSelector:@selector(stopRolling) withObject:nil afterDelay:0.0];
	}
}

- (int) getGlobalPageCount{
	int pageCount = 0;
	for(int i=0; i<currentSpineIndex; i++){
		pageCount+= [[loadedEpub.spineArray objectAtIndex:i] pageCount]; 
	}
	pageCount+=currentPageInSpineIndex+1;
	return pageCount;
}

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex {
	[self loadSpine:spineIndex atPageIndex:pageIndex highlightSearchResult:nil];
}

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult{
	webView.hidden = YES;	
	self.currentSearchResult = theResult;
    
    //iphone沒有popView
	//[chaptersPopover dismissPopoverAnimated:YES];
    
    NSURL* url = [NSURL fileURLWithPath:[[loadedEpub.spineArray objectAtIndex:spineIndex] spinePath]];    
    //這邊把.html檔案丟給webView loading
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
	currentPageInSpineIndex = pageIndex;
	currentSpineIndex = spineIndex;
	if(!paginating){
        [currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
	}
}

- (void) gotoPageInCurrentSpine:(int)pageIndex{
	if(pageIndex>=pagesInCurrentSpineCount){
		pageIndex = pagesInCurrentSpineCount - 1;
		currentPageInSpineIndex = pagesInCurrentSpineCount - 1;	
	}
	
	float pageOffset = pageIndex*webView.bounds.size.width;
    
	NSString *goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
	NSString *goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
	
	[webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
	[webView stringByEvaluatingJavaScriptFromString:goTo];
	
	if(!paginating){
		//[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
        [currentPageLabel setText:[NSString stringWithFormat:@"%d",[self getGlobalPageCount]]];
	}
	webView.hidden = NO;
}

//下一個章節
- (void) gotoNextSpine {
	if(!paginating){
		if(currentSpineIndex+1<[loadedEpub.spineArray count]){
			[self loadSpine:++currentSpineIndex atPageIndex:0];
            CATransition *transition = [CATransition animation];
            [transition setDelegate:self];
            [transition setDuration:0.5f];
            [transition setType:@"pageCurl"];
            [transition setSubtype:@"fromRight"];
            [self.webView.layer addAnimation:transition forKey:@"CurlAnim"];
		}
	}
}

//上一個章節
- (void) gotoPrevSpine {
    if(!paginating){
        if(currentSpineIndex-1>=0){
			[self loadSpine:--currentSpineIndex atPageIndex:0];
		}	
	}
}

//到下一頁
- (void) gotoNextPage {
	if(!paginating){
        if(currentPageInSpineIndex+1<pagesInCurrentSpineCount){
			[self gotoPageInCurrentSpine:++currentPageInSpineIndex];
            CATransition *transition = [CATransition animation];
            [transition setDelegate:self];
            [transition setDuration:0.5f];
            [transition setType:@"pageCurl"];
            [transition setSubtype:@"fromRight"];
            [self.webView.layer addAnimation:transition forKey:@"CurlAnim"];
		} 
        else {
			[self gotoNextSpine];
		}
    }
}

//回上一頁
- (void) gotoPrevPage {
	if (!paginating) {
        if(currentPageInSpineIndex-1>=0){
			[self gotoPageInCurrentSpine:--currentPageInSpineIndex];
            CATransition *transition = [CATransition animation];
            [transition setDelegate:self];
            [transition setDuration:0.5f];
            [transition setType:@"pageUnCurl"];
            [transition setSubtype:@"fromRight"];
            [self.webView.layer addAnimation:transition forKey:@"UnCurlAnim"];
		} 
        else {
			if(currentSpineIndex!=0){
                CATransition *transition = [CATransition animation];
                [transition setDelegate:self];
                [transition setDuration:0.5f];
                [transition setType:@"pageUnCurl"];
                [transition setSubtype:@"fromRight"];
                [self.webView.layer addAnimation:transition forKey:@"UnCurlAnim"];
				int targetPage = [[loadedEpub.spineArray objectAtIndex:(currentSpineIndex-1)] pageCount];
				[self loadSpine:--currentSpineIndex atPageIndex:targetPage-1];
			}
		}
	}
}

//放大字體
- (IBAction) increaseTextSizeClicked:(id)sender{
	if(!paginating){
		if(currentTextSize+25<=150){
			currentTextSize+=25;
			[self updatePagination];
            //字體最大就150
			if(currentTextSize == 150){
				[incTextSizeButton setEnabled:NO];
			}
			[decTextSizeButton setEnabled:YES];
		}
	}
}

//縮小字體
- (IBAction) decreaseTextSizeClicked:(id)sender{
    //除非處理完才會再處理一次，放大縮小不可連按
    if(!paginating){
        //字體最小預設為75
		if(currentTextSize-25>=50){
			currentTextSize-=25;
			[self updatePagination];
            //當字體的大小設定小於50的時候，就把按鈕功能取消
            //沒辦法在更小了！
			if(currentTextSize==50){
				[decTextSizeButton setEnabled:NO];
			}
			[incTextSizeButton setEnabled:YES];
		}
	}
}

//列出章節
//Iphone不能直接用UIPopoverController，這邊按下去會Crash
- (IBAction)showChapterIndex:(id)sender{
    ChapterList* chapterListView = [[ChapterList alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    [chapterListView setEpubViewController:self];
    chapterListView.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentModalViewController:chapterListView animated:YES];
    [chapterListView release];
}

- (IBAction) backButton:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)webViewDidFinishLoad:(UIWebView *)theWebView{
	
    [[[webView subviews] lastObject] setScrollEnabled:NO];
    
	NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
	
	NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
	"if (mySheet.addRule) {"
	"mySheet.addRule(selector, newRule);"								// For Internet Explorer
	"} else {"
	"ruleIndex = mySheet.cssRules.length;"
	"mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
	"}"
	"}";
	
    
	NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %fpx; -webkit-column-gap: 0px; -webkit-column-width: %fpx;')", self.webView.frame.size.height, self.webView.frame.size.width];
	NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
	NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')", currentTextSize];
	NSString *setHighlightColorRule = [NSString stringWithFormat:@"addCSSRule('highlight', 'background-color: yellow;')"];
    NSString *setImageRule = [NSString stringWithFormat:@"addCSSRule('img', 'max-width: %fpx; height:auto;')", self.webView.frame.size.width *0.75];
    
    //NSString *changeFont = [NSString stringWithFormat:@"addCSSRule('body', 'font-family:Bradley Hand;')"];
    
	[webView stringByEvaluatingJavaScriptFromString:varMySheet];
	[webView stringByEvaluatingJavaScriptFromString:addCSSRule];
	[webView stringByEvaluatingJavaScriptFromString:insertRule1];
	[webView stringByEvaluatingJavaScriptFromString:insertRule2];
	[webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
	[webView stringByEvaluatingJavaScriptFromString:setHighlightColorRule];
	[webView stringByEvaluatingJavaScriptFromString:setImageRule];
    
    //[webView stringByEvaluatingJavaScriptFromString:changeFont];
	
    if(currentSearchResult!=nil){
        //	NSLog(@"Highlighting %@", currentSearchResult.originatingQuery);
        [webView highlightAllOccurencesOfString:currentSearchResult.originatingQuery];
	}
	
	int totalWidth = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
	pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);
    
    //字體大小改變的時候會跑這邊
    //NSLog(@"總頁數 %i",pagesInCurrentSpineCount);
	//NSLog(@"目前頁數 %i",currentPageInSpineIndex);
    
    [self gotoPageInCurrentSpine:currentPageInSpineIndex];
}


//更新分頁
- (void) updatePagination{
	if(epubLoaded){
        if(!paginating){
            paginating = YES;
            totalPagesCount=0;
            [self loadSpine:currentSpineIndex atPageIndex:currentPageInSpineIndex];
            [[loadedEpub.spineArray objectAtIndex:0] setDelegate:self];
            [[loadedEpub.spineArray objectAtIndex:0] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize];
            [currentPageLabel setText:@".../..."];
        }
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingIndicator.center = CGPointMake(toolbar.frame.size.width/2 ,toolbar.frame.size.height/2);
    [loadingIndicator startAnimating];
    toolbar.alpha = 0.8;
    [self.toolbar addSubview:loadingIndicator];
    
    
    [webView setDelegate:self];
    
	UIScrollView* sv = nil;
	for (UIView* v in  webView.subviews) {
		if([v isKindOfClass:[UIScrollView class]]){
			sv = (UIScrollView*) v;
			sv.scrollEnabled = NO;
			sv.bounces = NO;
		}
	}
	currentTextSize = 100;
	
    //Webview加入手勢判斷。
	UISwipeGestureRecognizer* rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextPage)] ;
	[rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	
	UISwipeGestureRecognizer* leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPrevPage)] ;
	[leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    
    
    [webView addGestureRecognizer:rightSwipeRecognizer];
	[webView addGestureRecognizer:leftSwipeRecognizer];
    
    [self performSelector:@selector(stratRolling)];
}

//如果沒有讓Epub Loading完成就切換左右畫面，會導致當機
- (void)stratRolling{
    [loadingIndicator startAnimating];
}

- (void)stopRolling{
    [loadingIndicator stopAnimating];
    [loadingIndicator setHidesWhenStopped:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return NO;
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    self.toolbar = nil;
	self.webView = nil;
	self.chapterListButton = nil;
	self.decTextSizeButton = nil;
	self.incTextSizeButton = nil;
	self.currentPageLabel = nil;
	[loadedEpub release];
	//[chaptersPopover release];
	[currentSearchResult release];
    [super dealloc];
}

@end
