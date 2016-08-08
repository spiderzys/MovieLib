//
//  FirstViewControllerTest.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-08-06.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "FirstViewController.h"

// make private method publick for testing
@interface FirstViewController (Testing)

- (void)addMovieToCoreData:(int)tag;

@end
@interface FirstViewControllerTest : XCTestCase
@property FirstViewController* first;
@property AppDelegate* delegate;
@end

@implementation FirstViewControllerTest
@synthesize first,delegate;


- (void)setUp {
    [super setUp];
    first = [[FirstViewController alloc]init];
    delegate = [[UIApplication sharedApplication]delegate];
    [first viewDidAppear:true];

    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}




- (void)testExample {
    
    
    XCTAssertTrue(first.playingMoviesRequestResult.count>0);
    
    // test they are recent movies
    for (NSDictionary *movie in first.playingMoviesRequestResult) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *release_date = [movie valueForKey:@"release_date"];
        NSDate *releaseDate = [dateFormatter dateFromString:release_date];
        NSDate *currentDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                   fromDate:releaseDate toDate:currentDate options:0];
       
        XCTAssertTrue([difference day]<60);
    }
    
    
    
    
    
    
  
    
    XCTestExpectation *exp = [self expectationWithDescription:@"core"];
   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
   

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      //  dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
   
        NSArray *temp = [NSMutableArray arrayWithArray: [delegate.managedObjectContext executeFetchRequest:request error:&error]];
        
        
        
        XCTAssertTrue(temp.count == coreDataSize);
        
        
        [exp fulfill];
      
    });
   
    [self waitForExpectationsWithTimeout:6.0 handler:nil];
    
    
     NSError *error;
    NSArray *temp = [NSMutableArray arrayWithArray: [delegate.managedObjectContext executeFetchRequest:request error:&error]];

    [delegate.managedObjectContext deleteObject:[temp lastObject]];
    [delegate saveContext];
    
    //  NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    
    
    
    
    temp = [NSMutableArray arrayWithArray: [delegate.managedObjectContext executeFetchRequest:request error:&error]];
    
    XCTAssertTrue(temp.count == coreDataSize - 1);
    
  
   [first addMovieToCoreData:coreDataSize-1];
   temp = [NSMutableArray arrayWithArray: [delegate.managedObjectContext executeFetchRequest:request error:&error]];
    XCTAssertTrue(temp.count == coreDataSize);

    
    
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}



@end
