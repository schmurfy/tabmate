#import <Cocoa/Cocoa.h>

/* Here are the non-exposed methods we use on TextMate */
@interface NSObject(TabMatePrivateMethods)
- (void)setTabSize:(int)tabSize;
- (void)setSoftTabs:(BOOL)softTabs;
- (NSArray *)bundleItemsOfKind:(NSString *)arg;
- (NSString *)UUID;
- (void)changeLanguageTo:(NSString *)str andLearn:(BOOL)learn;
@end

@protocol TMPlugInController
- (float)version;
@end

/* Hack based on Allan Odgaard's ClockExamplePlugin example, which will
   fire off a kDocumentChangedNotification notification when the user loads a file or changes tab. */

extern NSString* const kDocumentChangedNotification;

@interface TextMateGlue : NSWindow 
{
}
@end
