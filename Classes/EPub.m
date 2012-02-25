//
//  EPub.m
//  AePubReader
//
//  Created by Federico Frappi on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EPub.h"
#import "ZipArchive.h"
#import "Chapter.h"

@interface EPub()

- (void) parseEpub;
- (void) unzipAndSaveFileNamed:(NSString*)fileName;
- (NSString*) applicationDocumentsDirectory;
- (NSString*) parseManifestFile;
- (void) parseOPF:(NSString*)opfPath;

@end

@implementation EPub

@synthesize spineArray;

- (id) initWithEPubPath:(NSString *)path{
	if((self=[super init])){
		epubFilePath = [path retain];
		spineArray = [[NSMutableArray alloc] init];
		[self parseEpub];
	}
	return self;
}

- (void) parseEpub{
	[self unzipAndSaveFileNamed:epubFilePath];
	NSString* opfPath = [self parseManifestFile];
	[self parseOPF:opfPath];
}

- (void)unzipAndSaveFileNamed:(NSString*)fileName{
	ZipArchive* za = [[ZipArchive alloc] init];
//	NSLog(@"%@", fileName);
//	NSLog(@"unzipping %@", epubFilePath);
	if( [za UnzipOpenFile:epubFilePath]){
		NSString *strPath=[NSString stringWithFormat:@"%@/UnzippedEpub",[self applicationDocumentsDirectory]];
		//NSLog(@"strPath %@", strPath);
		//先把Epub解壓到Document/UnzippedEpub 這個資料夾裡面
        
        //刪除所有裡面已經有的檔案
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:strPath]) {
			NSError *error;
			[filemanager removeItemAtPath:strPath error:&error];
		}
		[filemanager release];
		filemanager=nil;
        
		//開始解壓縮
        //ret : 正確
		BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",strPath] overWrite:YES];
		if( NO==ret ){
			//如果解壓過程中出現問題，就跳alert
			UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
														  message:@"Error while unzipping the epub"
														 delegate:self
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
			[alert show];
			[alert release];
			alert=nil;
		}
		[za UnzipCloseFile];
	}					
	[za release];
}

//取得Document路徑
- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

//解析META-INF
- (NSString*) parseManifestFile{
	NSString* manifestFilePath = [NSString stringWithFormat:@"%@/UnzippedEpub/META-INF/container.xml", [self applicationDocumentsDirectory]];
//	NSLog(@"%@", manifestFilePath);
	NSFileManager *fileManager = [[NSFileManager alloc] init];
    //如果有找到container.xml這種東西，就表示正確可以繼續往下解析
	if ([fileManager fileExistsAtPath:manifestFilePath]) {
		//NSLog(@"Valid epub");
		CXMLDocument* manifestFile = [[[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:manifestFilePath] options:0 error:nil] autorelease];
		CXMLNode* opfPath = [manifestFile nodeForXPath:@"//@full-path[1]" error:nil];
//		NSLog(@"%@", [NSString stringWithFormat:@"%@/UnzippedEpub/%@", [self applicationDocumentsDirectory], [opfPath stringValue]]);
		return [NSString stringWithFormat:@"%@/UnzippedEpub/%@", [self applicationDocumentsDirectory], [opfPath stringValue]];
        
	} 
    else {
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"錯誤"
                                                      message:@"epub格式無效"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        [alert release];
		return nil;
	}
	[fileManager release];
}

//解析OPF
- (void) parseOPF:(NSString*)opfPath{
	CXMLDocument* opfFile = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:opfPath] options:0 error:nil];
	NSArray* itemsArray = [opfFile nodesForXPath:@"//opf:item" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
//	NSLog(@"itemsArray size: %d", [itemsArray count]);
    
    NSString* ncxFileName;
	
    NSMutableDictionary* itemDictionary = [[NSMutableDictionary alloc] init];
	for (CXMLElement *element in itemsArray) {
		[itemDictionary setValue:[[element attributeForName:@"href"] stringValue] forKey:[[element attributeForName:@"id"] stringValue]];
        
        //找出NCX檔案的路徑！
        if([[[element attributeForName:@"id"] stringValue] isEqualToString:@"ncx"]){
            ncxFileName = [[element attributeForName:@"href"] stringValue];
            //NSLog(@"NCX File Name %@",ncxFileName);
            //NSLog(@"%@ : %@", [[element attributeForName:@"id"] stringValue], [[element attributeForName:@"href"] stringValue]);
        }
        
        //XHTML 支援的 image 有下列四種格式:
        /*
        if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"image/jpeg"]||
           [[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"image/png"]||
           [[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"image/gif"]||
           [[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"image/svg+xml"]){
            NSString *imgName = [[element attributeForName:@"href"] stringValue];
            //NSLog(@"圖片路徑&名稱 %@",imgName);
        }
        */
         
        /*
        if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"application/x-dtbncx+xml"]){
            ncxFileName = [[element attributeForName:@"href"] stringValue];
         // NSLog(@"%@ : %@", [[element attributeForName:@"id"] stringValue], [[element attributeForName:@"href"] stringValue]);
        }
        
        if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"application/xhtml+xml"]){
            ncxFileName = [[element attributeForName:@"href"] stringValue];
            //NSLog(@"%@ : %@", [[element attributeForName:@"id"] stringValue], [[element attributeForName:@"href"] stringValue]);
        }
        
        if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"text/xml"]){
            ncxFileName = [[element attributeForName:@"href"] stringValue];
            NSLog(@"NCx File Name %@",ncxFileName);
            //NSLog(@"%@ : %@", [[element attributeForName:@"id"] stringValue], [[element attributeForName:@"href"] stringValue]);
        }
         */
	}
    int lastSlash = [opfPath rangeOfString:@"/" options:NSBackwardsSearch].location;
	NSString* ebookBasePath = [opfPath substringToIndex:(lastSlash +1)];
    CXMLDocument* ncxToc = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", ebookBasePath, ncxFileName]] options:0 error:nil];
    
    //NSLog(@"NCX 路徑 %@",[NSString stringWithFormat:@"%@%@", ebookBasePath, ncxFileName]);
    NSMutableDictionary* titleDictionary = [[NSMutableDictionary alloc] init];
    
    for (CXMLElement* element in itemsArray) {
        NSString* href = [[element attributeForName:@"href"] stringValue];
        NSString* xpath = [NSString stringWithFormat:@"//ncx:content[@src='%@']/../ncx:navLabel/ncx:text", href];
        NSArray* navPoints = [ncxToc nodesForXPath:xpath namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.daisy.org/z3986/2005/ncx/" forKey:@"ncx"] error:nil];
       
        if([navPoints count]!=0){
            CXMLElement* titleElement = [navPoints objectAtIndex:0];
           [titleDictionary setValue:[titleElement stringValue] forKey:href];
        }
    }
	
	NSArray* itemRefsArray = [opfFile nodesForXPath:@"//opf:itemref" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
	//NSLog(@"itemRefsArray %@", itemRefsArray);
    
	NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
    int count = 0;
	for (CXMLElement* element in itemRefsArray) {
        NSString* chapHref = [itemDictionary valueForKey:[[element attributeForName:@"idref"] stringValue]];

        Chapter* tmpChapter = [[Chapter alloc] initWithPath:[NSString stringWithFormat:@"%@%@", ebookBasePath, chapHref]
                                                       title:[titleDictionary valueForKey:chapHref] 
                                                chapterIndex:count++];
		[tmpArray addObject:tmpChapter];
		
		[tmpChapter release];
        //NSLog(@"chapHref  %@",chapHref);
	}
	
	self.spineArray = [NSArray arrayWithArray:tmpArray]; 
	//NSLog(@"\n\n");
    //NSLog(@"SpineArray  %@",spineArray);
    
	[opfFile release];
	[tmpArray release];
	[ncxToc release];
	[itemDictionary release];
	[titleDictionary release];
    
}

- (void)dealloc {
    [spineArray release];
	[epubFilePath release];
    [super dealloc];
}

@end
