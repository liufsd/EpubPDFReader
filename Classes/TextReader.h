//
//  TextReader.h
//  EpubDownload
//
//  Created by  on 2011/9/23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextReader : UIViewController<UITextViewDelegate>{
    IBOutlet UITextView *textView;
    NSString *receiveContent;
}

@property (nonatomic,retain)NSString *receiveContent;
@property (nonatomic,retain)IBOutlet UITextView *textView;
@end
