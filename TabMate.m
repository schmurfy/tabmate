#import "TabMate.h"

@interface TabMate (Private)
- (void)respectTabSize;
- (void)respectTabType;
- (void)respectGrammar;
@end

@implementation TabMate

- (id)initWithPlugInController:(id <TMPlugInController>)aController
{
  if (self = [super init]) {
    [TextMateGlue poseAsClass:[NSWindow class]];
    mGlue = [[TextMateGlue alloc] init];
    
    // observe the kDocumentLoaded notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(documentChanged:) 
                                                 name:kDocumentChangedNotification 
                                               object:nil];
  }
  
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [mGlue release];
  [mParser release];
  [super dealloc];
}

#pragma mark -

- (void)documentChanged:(NSNotification*)notification
{
  if (!notification)
    return;
  
  NSString *path = [[notification userInfo] valueForKey:@"path"];
  if (!path)
    return;
  
  // set this up lazily
  if (!mParser) {
    mParser = [[ModeLineParser alloc] initWithFile:path];
  } else {
    BOOL success = [mParser tryParseFile:path];
    if (!success)
      return;
  }

  
  // AWFUL HACK! (but needed to make this plug-in work)
  //
  // We're getting called before TextMate's responder chain is totally
  // set up, so we need to delay our call slightly and let the
  // textarea finish setting up before we do our thing.
  [self performSelector:@selector(respectTabSize) withObject:nil afterDelay:0.0];
  [self performSelector:@selector(respectTabType) withObject:nil afterDelay:0.0];
  [self performSelector:@selector(respectGrammar) withObject:nil afterDelay:0.0];
}

- (void)respectTabSize
{
  if (!mParser)
    return;

  int tabSize = [mParser tabWidth];
  if (tabSize != -1) {
    id hopefullyTheTextView = [NSApp targetForAction:@selector(setTabSize:)];
    if (hopefullyTheTextView)
      [hopefullyTheTextView setTabSize:tabSize];
  }
}

- (void)respectTabType
{
  if (!mParser)
    return;
  
  id hopefullyTheTextView = [NSApp targetForAction:@selector(setSoftTabs:)];
  if (hopefullyTheTextView)
    [hopefullyTheTextView setSoftTabs:[mParser softTabs]];
}

- (void)respectGrammar
{
  if (!mParser)
    return;

  id hopefullyTheTextView = [NSApp targetForAction:@selector(setSoftTabs:)];
  if (hopefullyTheTextView) {
    NSString* langString = [mParser modeLanguage];
    
    NSString* langUUID = nil;
    
    Class bm = [[NSBundle mainBundle] classNamed:@"BundleManager"];
    id bundleManager = [bm sharedInstance];
    
    NSArray* languages = [bundleManager bundleItemsOfKind:@"language"];
    
    int i = [languages count];
    while (i--) {
      if ([[[languages objectAtIndex:i] name] caseInsensitiveCompare:langString] == NSOrderedSame) {
        langUUID = [[languages objectAtIndex:i] UUID];
        break;
      }
    }
    
    if(langUUID != nil) {
      [hopefullyTheTextView changeLanguageTo:langUUID andLearn:NO];
    }
  }
}

@end
