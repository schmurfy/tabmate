#import <Foundation/Foundation.h>
#import <AGRegex/AGRegex.h>

/* Parses mode-lines. Currently only supports emacs-style mode-lines. */

// emacs example:
/* -*- Mode: Java; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

@interface ModeLineParser : NSObject 
{
  AGRegex       *mRegEx;
  NSDictionary  *mModeDict;
}

- (id)init;
- (id)initWithFile:(NSString*)aPath;

// returns YES on success.
- (BOOL)tryParseFile:(NSString*)aPath;

// the size of each tab
// returns -1 on error.
- (int)tabWidth;

// are we using hard tabs, or spaces?
// defaults to NO on error.
- (BOOL)softTabs;

// e.g., "C++", "Java", etc.
// returns empty string on error.
- (NSString*)modeLanguage;

@end
