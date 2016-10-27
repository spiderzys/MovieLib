//
//  Movie+CoreDataProperties.h
//  
//
//  Created by YANGSHENG ZOU on 2016-01-02.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

@interface Movie (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *overview;
@property (nullable, nonatomic, retain) NSData *poster_data;
@property (nullable, nonatomic, retain) NSString *release_date;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *vote_average;
@property (nullable, nonatomic, retain) NSNumber *idn;
@property (nullable, nonatomic, retain) NSString *cast;
@property (nullable, nonatomic, retain) NSNumber *vote_count;
@property (nullable, nonatomic, retain) NSNumber *length;

@end

NS_ASSUME_NONNULL_END
