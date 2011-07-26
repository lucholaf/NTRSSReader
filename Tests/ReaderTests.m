#import <GHUnitIOS/GHUnit.h>

@interface ReaderTests : GHTestCase {}
@end

@implementation ReaderTests

- (BOOL)shouldRunOnMainThread {
	// By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
	// Also an async test that calls back on the main thread, you'll probably want to return YES.
	return NO;
}

- (void)setUpClass {
	// Run at start of all tests in the class
}

- (void)tearDownClass {
	// Run at end of all tests in the class
}

- (void)setUp {
	// Run before each test method
}

- (void)tearDown {
	// Run after each test method
}

- (void) testFirstUT {
    GHAssertEquals(1, 2, @"Should Pass");
}

@end