#import "TestModelineParser.h"

@implementation TestModelineParser

- (void)setUp 
{
  parser = [ModeLineParser new];
}

- (void)testEmacsModelines
{
  STAssertNotNil(parser, @"parser nil!");
  
  NSString *testfilePath = @"/var/tmp/testfiles/";
  
  // test file 1 (regular emacs modeline)
  NSString *file1Path = [testfilePath stringByAppendingPathComponent:@"file1"];
  STAssertTrue([parser tryParseFile:file1Path], @"Could not parse file 1");
  
  STAssertEqualObjects([parser modeLanguage], @"C++", @"file #1 lang error");
  STAssertEquals([parser tabWidth], 2, @"file #1 tab width error");
  STAssertTrue([parser softTabs], @"file #1 soft tabs error");
  
  // test file 2 (regular emacs modeline)
  NSString *file2Path = [testfilePath stringByAppendingPathComponent:@"file2"];
  STAssertTrue([parser tryParseFile:file2Path], @"Could not parse file 1");
  
  STAssertEqualObjects([parser modeLanguage], @"IDL", @"file #2 lang error");
  STAssertEquals([parser tabWidth], 4, @"file #2 tab width error");
  STAssertTrue([parser softTabs], @"file #2 soft tabs error");

  // test file 3 (modeline with lowercase "mode"
  NSString *file3Path = [testfilePath stringByAppendingPathComponent:@"file3"];
  STAssertTrue([parser tryParseFile:file3Path], @"Could not parse file 3");
  
  STAssertEqualObjects([parser modeLanguage], @"JavaScript", @"file #3 lang error");
  STAssertEquals([parser tabWidth], 3, @"file #3 tab width error");
  STAssertFalse([parser softTabs], @"file #3 tabs error");
  
  // test file 4 (php file with modeline on second line)
  NSString *file4Path = [testfilePath stringByAppendingPathComponent:@"file4"];
  STAssertTrue([parser tryParseFile:file4Path], @"Could not parse file 4");
  STAssertEqualObjects([parser modeLanguage], @"php", @"file #4 lang error");
  STAssertFalse([parser softTabs], @"file #4 tabs error");
}

@end
