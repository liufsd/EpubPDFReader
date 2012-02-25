@implementation UIWebView (SearchWebView)

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str {
    //這邊呼叫SearchWebView.js這支java的來跑
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
        
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@');",str];    
    //Evaluating評估
    [self stringByEvaluatingJavaScriptFromString:startSearch];
        
    //NSLog(@"%@", [self stringByEvaluatingJavaScriptFromString:@"console"]);
    return [[self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount;"] intValue];
}

- (void)removeAllHighlights {
    [self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
}

@end