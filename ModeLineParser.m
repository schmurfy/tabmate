#import "ModeLineParser.h"

// the holy grail of this plug-in
NSString* const kModeLineRegEx = @"(?P<key>[^\\d ]+): (?P<value>.*?);";

@interface ModeLineParser (Private)

// finding the modeline
- (NSString*)modeLineFromFile:(NSString*)aPath;

// validating it
- (BOOL)isModeLine:(NSString*)aString;

// parsing it into a dictionary
- (NSDictionary*)parseModeLine:(NSString*)aModeLine;

@end

static int min(int a, int b) {
  return (a < b) ? a : b;
}

@implementation ModeLineParser

- (id)init 
{
  if ((self = [super init])) {
    mRegEx = [[AGRegex alloc] initWithPattern:kModeLineRegEx];
    mModeDict = nil;
  }
  return self;
}

- (id)initWithFile:(NSString*)aPath
{
  if ([self init]) {
    [self tryParseFile:aPath];
  }
  return self;
}

- (void)dealloc
{
  [mModeDict release];
  [mRegEx release];
  [super dealloc];
}

#pragma mark -

- (BOOL)tryParseFile:(NSString*)aPath
{
  if (!aPath)
    return NO;
  
  NSString *modeLine = [self modeLineFromFile:aPath];
  if (!modeLine)
    return NO;
  
  [mModeDict release];
  mModeDict = [[self parseModeLine:modeLine] retain];
  return (mModeDict != nil);
}

- (int)tabWidth
{
  NSString *width = [mModeDict objectForKey:@"tab-width"];
  return (width ? [width intValue] : 2);
}

- (BOOL)softTabs
{
  NSString *indentMode = [mModeDict objectForKey:@"indent-tabs-mode"];
  return (indentMode ? [indentMode isEqualToString:@"nil"] : YES);
}

- (NSString*)modeLanguage 
{
  NSString *lang = [mModeDict objectForKey:@"Mode"];
  // also try lowercase
  if (!lang)
    lang = [mModeDict objectForKey:@"mode"];
    
  return (lang ? lang : @"");
}

@end

@implementation ModeLineParser (Private)

- (BOOL)isModeLine:(NSString*)aString
{
  return ([mRegEx findInString:aString] != nil);
}

- (NSDictionary*)parseModeLine:(NSString*)aModeLine
{
  NSEnumerator *matchesIter = [mRegEx findEnumeratorInString:aModeLine];
  if (!matchesIter)
    return nil;
  
  NSMutableDictionary *dict = nil;
  AGRegexMatch *match;
  
  while (match = [matchesIter nextObject]) {
    if (!dict)
      dict = [[NSMutableDictionary alloc] init];
    
    NSString *key = [match groupNamed:@"key"];
    NSString *value = [match groupNamed:@"value"];
    if (key && value)
      [dict setObject:value forKey:key];
  }
  
  // Make sure we return an immutable dictionary
  NSDictionary *returnDict = dict ? [dict copy] : nil;
  [dict release];
  
  return [returnDict autorelease];
}

- (NSString*)modeLineFromFile:(NSString*)aPath
{
  // See if it's valid text file
  NSString *text = [NSString stringWithContentsOfFile:aPath];
  if (!text) {
    return nil;
  }
  
  // Split by lines
  NSArray *lines = [text componentsSeparatedByString:@"\n"];
  if (!lines) {
    return nil;
  }

  // try looking for a modeline on the first three lines
  int i;
  for (i=0; i<min([lines count], 2); ++i) {
    // try finding the modeline on the first line
    NSString *curLine = [lines objectAtIndex:i];
    if ([self isModeLine:curLine]) {
      return curLine;
    }
  }

  return nil;
}

@end
