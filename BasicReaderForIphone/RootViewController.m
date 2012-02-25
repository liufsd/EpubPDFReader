//
//  RootViewController.m
//  BasicReaderForIphone
//
//  Created by Macminiserver on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    switch (indexPath.row) {
        case 0:{
            cell.textLabel.text = @"顯示TXT檔案";
        }
            break;
        case 1:{
            cell.textLabel.text = @"顯示PDF檔案";
        }
            break;
        case 2:{
            cell.textLabel.text = @"顯示純文字Epub檔案";
        }
            break;
        case 3:{
            cell.textLabel.text = @"顯示圖畫書Epub檔案";
        }
            break;
            
        default:
            break;
    }
    // Configure the cell.
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError *error;
    NSString *phrase = nil;//假如PDF是有鎖密碼的話
    
    switch (indexPath.row) {
        //TXT
        case 0:{
            NSString *txtContent = [[NSString alloc]
                                    initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xalanLICENSE" ofType:@"txt"]
                                    encoding:NSUTF8StringEncoding
                                    error:&error];
            TextReader *textReader = [[TextReader alloc]init];
            textReader.receiveContent = txtContent;
            textReader.title = @"TXT 文件";
            [self.navigationController pushViewController:textReader animated:YES];
            [txtContent release];
            [textReader release];
            
        }
            break;
        //PDF
        case 1:{
             ReaderDocument * document = [[[ReaderDocument alloc] initWithFilePath:[[NSBundle mainBundle] pathForResource:@"MobileHIG" ofType:@"pdf"] password:phrase] autorelease];
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            readerViewController.delegate = self;
            readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentModalViewController:readerViewController animated:YES];
            [readerViewController release];
        }
            break;
        //EPUB
        case 2:{
            epubView = [[EPubViewController alloc] init];
            [epubView loadEpub:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"The Chessmen of Mars" ofType:@"epub"]]];
            epubView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:epubView animated:YES];
            [epubView release];
        }
            break;
        case 3:{
            epubView = [[EPubViewController alloc] init];
            [epubView loadEpub:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Peter Rabbit" ofType:@"epub"]]];
            epubView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:epubView animated:YES];
            [epubView release];
        }
            break;
            
        default:
            break;
    }
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

@end
