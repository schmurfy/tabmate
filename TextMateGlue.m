#import "TextMateGlue.h"

NSString* const kDocumentChangedNotification = @"HWDocumentChanged";

@implementation TextMateGlue

- (void)setRepresentedFilename:(NSString*)aPath
{
  // Make sure we only notify if the represented filename actually changes, since
  // this function may be called redundantly.
  // c.f. http://lists.macromates.com/pipermail/textmate-plugins/2005-November/000011.html
  if (![[super representedFilename] isEqualToString:aPath]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentChangedNotification 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:aPath forKey:@"path"]];
  }
  
  [super setRepresentedFilename:aPath];
}

@end

