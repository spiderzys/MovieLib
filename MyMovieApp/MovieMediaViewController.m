//
//  movieMediaViewController.m
//  MyMovieApp
//
//  Created by YANGSHENG ZOU on 2016-04-26.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

#import "MovieMediaViewController.h"

@interface MovieMediaViewController ()

@end
static NSString* header = @"header";
static NSString* cell = @"cell";
static CGSize NALabelSize;
static CGRect NALabelRect;
@implementation MovieMediaViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil movieDic:(NSDictionary*)movie{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _movie = movie;
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    _tintColor = self.navigationItem.leftBarButtonItem.tintColor;
    [_navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    _navigationBar.shadowImage = [UIImage new];
    self.navigationItem.title = [_movie valueForKey:@"title"];
    [self setCollectionView];
    
    
}

-(void)setCollectionView{
    [_movieMediaCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cell];
    [_movieMediaCollection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:header];
    NALabelSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height*0.1);
    NALabelRect = CGRectMake(20, 0, NALabelSize.width, NALabelSize.height);
    // Do any additional setup after loading the view from its nib.
    
    
    NSString *idn = [_movie valueForKey:@"id"];
    NSString *movieImagesString = [NSString stringWithFormat:@"%@%@/images?%@",movieImageUrl,idn,APIKey];
  //  NSLog(@"%@",movieImagesString);
    NSData *moviesImagesData = [NSData dataWithContentsOfURL:[NSURL URLWithString:movieImagesString]];
    if(moviesImagesData.length>0){
        
        NSDictionary *movieImagesDic = [NSJSONSerialization JSONObjectWithData:moviesImagesData options:0 error:nil];
        _posterPathArray = [movieImagesDic valueForKey:@"posters"];
        if(_posterPathArray.count>11){
            _posterPathArray = [_posterPathArray subarrayWithRange:NSMakeRange(0, 11)];
        }
        _backdropPathArray =  [movieImagesDic valueForKey:@"backdrops"];
        if(_backdropPathArray.count>10){
            _backdropPathArray = [_backdropPathArray subarrayWithRange:NSMakeRange(0, 10)];
        }
    }
    
    NSString *videoInquery = [NSString stringWithFormat:@"%@%@/videos?%@",movieWeb,idn,APIKey];
    NSArray *videoResult = [self getDataFromUrl:[NSURL URLWithString:videoInquery] withKey:@"results" LimitPages:0];
    
    if(videoResult){
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *result in videoResult) {
            
            if ([[result objectForKey:@"site"] isEqualToString:@"YouTube"]) {
                NSString *playId = [result objectForKey:@"key"];
                [temp addObject:playId];
            }
        }
        _tailerArray = [temp copy];
        
    }
    
    _headTitleArray = @[@"Posters",@"Backdrops",@"Traliers"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)dismissController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 3;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float height = self.view.frame.size.height;
    float width = self.view.frame.size.width;
    
    if(indexPath.section ==0){
        if(_posterPathArray.count!=0){
            
            return CGSizeMake(width, height*0.42);
        }
    }
    else if(indexPath.section==1){
        if(_backdropPathArray.count!=0){
            return CGSizeMake(width ,height*0.3);
        }
    }
    else{
        if(_tailerArray.count!=0){
            return CGSizeMake(width, height*0.5);
        }
        
    }
    return NALabelSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:cell forIndexPath:indexPath];
    if(collectionViewCell.subviews.count>1){
        [_loadingIndicator stopAnimating];
        return collectionViewCell;
    }
    float collectionViewHeight = collectionViewCell.bounds.size.height;
    
    UIScrollView *mediaScrollView = [[UIScrollView alloc]initWithFrame:collectionViewCell.bounds];
    
    
    
    if(indexPath.section == 2){
        
        if(_tailerArray.count==0){
            
            [collectionViewCell addSubview:[self NALabel]];
             [_loadingIndicator stopAnimating];
        }
        else{
            float tralierWidth = collectionViewHeight*trailerRatio;
            mediaScrollView.contentSize = CGSizeMake(_tailerArray.count*(tralierWidth+scrollViewContentGap) , collectionViewHeight);
            [collectionViewCell addSubview:mediaScrollView];
            for (int i = 0; i<_tailerArray.count; i++) {
               
                
                YTPlayerView *player = [[YTPlayerView alloc]initWithFrame:CGRectMake(i*(tralierWidth+scrollViewContentGap),0, tralierWidth , collectionViewHeight)];
                player.webView = [player createNewWebView];
                [player addSubview:player.webView];
                
                NSString * playid = [_tailerArray objectAtIndex:i];
                [mediaScrollView addSubview:player];
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    [player loadWithVideoId:playid];
                    if(i==_tailerArray.count-1){
                        [_loadingIndicator stopAnimating];
                    }
                    

                });
                
            }
            
            
            
            
            
            
        }
        
    }
    else{
        float imageWidth;
        NSArray *imageArray;
        if(indexPath.section==0){
            
            imageWidth = collectionViewHeight * posterRatio;
            imageArray = _posterPathArray;
        }
        else{
            
            
            imageWidth = collectionViewHeight * backdropRatio;
            imageArray = _backdropPathArray;
        }
        
        if(imageArray.count==0){
            [collectionViewCell addSubview:[self NALabel]];
            return collectionViewCell;
        }
        
        mediaScrollView.contentSize = CGSizeMake(imageArray.count*(imageWidth+scrollViewContentGap),collectionViewHeight);
        [collectionViewCell addSubview:mediaScrollView];
        for (int i = 0; i<imageArray.count; i++) {
            UIImageView* mediaImageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*(imageWidth+scrollViewContentGap),0,imageWidth,collectionViewHeight)];
            
            [mediaImageView setContentMode:UIViewContentModeScaleAspectFit];
            [mediaImageView setClipsToBounds:YES];
            [mediaScrollView addSubview:mediaImageView];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                NSDictionary *movieImageDic = [imageArray objectAtIndex:i];
                NSString *file_path = [movieImageDic valueForKey:@"file_path"];
                file_path = [imdbPosterWeb stringByAppendingString: file_path];
                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:file_path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [mediaImageView setImage: [UIImage imageWithData:data]];
                    });
                }];
                [task resume];
                
            });
            
            
        }
        
        
        
    }
    
    return collectionViewCell;
}




- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *headerView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:header forIndexPath:indexPath];
        if(headerView.subviews.count>1){
            return headerView;
        }
        UILabel *label = [[UILabel alloc]initWithFrame:NALabelRect];
        [headerView addSubview:label];
        label.textColor = _tintColor;
        [label setText:[_headTitleArray objectAtIndex:indexPath.section]];
        
        if(indexPath.section==2){
            _loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _loadingIndicator.color = _tintColor;
            _loadingIndicator.center = CGPointMake(label.frame.size.width/2, label.frame.size.height/2);
            NSLog(@"%@,%@",NSStringFromCGSize(NALabelSize),NSStringFromCGRect(NALabelRect));
            _loadingIndicator.hidesWhenStopped = YES;
            [label addSubview:_loadingIndicator];
            [_loadingIndicator startAnimating];
        }
        
        
    }
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return NALabelSize;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",indexPath);
}



-(UILabel*)NALabel{
    UILabel *label = [[UILabel alloc]initWithFrame:NALabelRect];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:_tintColor];
    [label setText:@"Not Available"];
    return label;
}
@end
