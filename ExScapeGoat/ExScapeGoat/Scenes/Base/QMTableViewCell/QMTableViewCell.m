//
//  QMTableViewCell.m
//  ExScapeGoat
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"
#import "QMPlaceholder.h"
#import <QMImageView.h>

#import "DYPieChartView.h"

#define ARC4RANDOM_MAX 0x100000000
#define MakeColor(r, g, b) [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f]

@interface QMTableViewCell ()
{
    DYPieChartView * _pieChartView;
    NSInteger _index;
    NSArray * _array;
}

/**
 *  Outlets
 */
@property (weak, nonatomic) IBOutlet QMImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

/**
 *  Cached values
 */
@property (assign, nonatomic) NSUInteger placeholderID;
@property (copy, nonatomic) NSString *avatarUrl;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *body;

@end

@implementation QMTableViewCell

+ (void)registerForReuseInTableView:(UITableView *)tableView {
    
    NSString *nibName = NSStringFromClass([self class]);
    UINib *nib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
    NSParameterAssert(nib);
    
    NSString *cellIdentifier = [self cellIdentifier];
    NSParameterAssert(cellIdentifier);
    
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
}

+ (NSString *)cellIdentifier {
    
    return NSStringFromClass([self class]);
}

+ (CGFloat)height {
    return 0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _avatarImage.imageViewType = QMImageViewTypeCircle;
    _titleLabel.text = nil;
    _bodyLabel.text = nil;
}

#pragma mark - Setters

//generate random numbers within range
-(int)generateRandomNumberBetweenMin:(int)min Max:(int)max
{
    return ( (arc4random() % (max-min+1)) + min );
}

- (void)setTitle:(NSString *)title placeholderID:(NSUInteger)placeholderID avatarUrl:(NSString *)avatarUrl {
    
    if (![_title isEqualToString:title]) {
        
        _title = [title copy];
        self.titleLabel.text = title;
    }
    
    if (_placeholderID != placeholderID || ![_avatarUrl isEqualToString:avatarUrl]) {
        
        _placeholderID = placeholderID;
        
        _avatarUrl = [avatarUrl copy];
        
        UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.avatarImage.bounds title:self.title ID:self.placeholderID];
        
        [self.avatarImage setImageWithURL:[NSURL URLWithString:avatarUrl]
                              placeholder:placeholder
                                  options:SDWebImageLowPriority
                                 progress:nil
                           completedBlock:nil];
        
        // *** EDITION
        _array = @[@[@(0.4), @(0.35), @(0.25), @(0.0), @(0.0)],
                   @[@(0.3), @(0.35), @(0.25), @(0.0), @(0.1)],
                   @[@(0.2), @(0.2), @(0.0), @(0.35), @(0.25)],
                   @[@(0.35), @(0.0), @(0.15), @(0.30), @(0.2)],
                   @[@(0.0), @(0.15), @(0.35), @(0.2), @(0.3)]];
        //
        CGFloat size = self.avatarImage.frame.size.height;
        //
        _pieChartView = [[DYPieChartView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        double val = ((double)arc4random() / ARC4RANDOM_MAX) * (2*M_PI - 0.0) + 0.0;
        _pieChartView.startAngle = val;
        _pieChartView.clockwise = NO;
        _pieChartView.lineWidth = @(2);
        //_pieChartView.center = self.avatarImage.center;
        _pieChartView.sectorColors = @[MakeColor(1, 189, 199),
                                       MakeColor(13, 240, 190),
                                       MakeColor(7, 215, 194),
                                       MakeColor(13, 240, 190),
                                       MakeColor(1, 189, 199)
                                       ];
        //get random numbers
        int mRand = [self generateRandomNumberBetweenMin:0 Max:4];
        [_pieChartView setScaleValues:_array[mRand]];
        //
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height / 2;
        [self.avatarImage.layer addSublayer: _pieChartView.layer];
        [self.avatarImage.layer setMasksToBounds:YES];
        
        
    }
}

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = [title copy];
        self.titleLabel.text = title;
    }
}

- (void)setBody:(NSString *)body {
    
    if (![_body isEqualToString:body]) {
        
        _body = [body copy];
        self.bodyLabel.text = body;
    }
}

@end
