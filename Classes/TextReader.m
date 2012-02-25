//
//  TextReader.m
//  EpubDownload
//
//  Created by  on 2011/9/23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TextReader.h"

@implementation TextReader

@synthesize receiveContent,textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done"
			style:UIBarButtonItemStylePlain
			target:self action:@selector(back:)] autorelease];
    }
    return self;
}

- (IBAction)back:(id)sender{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    textView.delegate = self;
    //這寫法也可以
    //textView.editable = NO;
    textView.text = receiveContent;
    textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    textView.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:textView];
}
//不要讓txt檔案可以編輯
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [receiveContent release];
    [textView release];
    [super dealloc];
}

@end
