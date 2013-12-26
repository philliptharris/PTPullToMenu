//
//  PTPullToMenuTVC.m
//  PTPullToMenu
//
//  Created by sscunnin on 12/19/13.
//  Copyright (c) 2013 Phillip Harris. All rights reserved.
//

#import "PTPullToMenuTVC.h"

@interface PTPullToMenuTVC ()
@property (nonatomic, strong) UIView *arrow;
@property (nonatomic, strong) UISegmentedControl *menu;
@property (nonatomic, assign) CGFloat sideMargin;
@property (nonatomic, assign) CGSize arrowSize;
@property (nonatomic, assign) CGFloat interMargin;
@property (nonatomic, assign) CGFloat arrowBottomMargin;
@property (nonatomic, assign) CGFloat menuHomeY;
@property (nonatomic, assign) CGFloat arrowHomeY;
@property (nonatomic, assign) CGFloat flipPoint;
@property (nonatomic, assign) BOOL menuGetsStuck;
@property (nonatomic, assign) BOOL arrowGetsStuck;
@property (nonatomic, assign) BOOL arrowHasFlipped;
@property (nonatomic, assign) BOOL arrowHasCompletedFlipAnimation;
@end

@implementation PTPullToMenuTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView.panGestureRecognizer addTarget:self action:@selector(tableDidPan:)];
    
    _menuGetsStuck = YES;
    _arrowGetsStuck = YES;
    _arrowHasFlipped = NO;
    _arrowHasCompletedFlipAnimation = NO;
    
    _arrowSize = CGSizeMake(13.0, 39.0/2.0);
    _arrowBottomMargin = 4.0;
    _flipPoint = -54.0;
    
    _arrow = [[UIView alloc] initWithFrame:CGRectMake(0.0, -1.0 * (_arrowSize.height + _arrowBottomMargin), _arrowSize.width, _arrowSize.height)];
//    _arrow.backgroundColor = [UIColor lightGrayColor];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitterArrow"]];
    [_arrow addSubview:imgView];
    [self.tableView addSubview:_arrow];
    
    _sideMargin = -5.0;
    _interMargin = 0.0;
    
    _menu = [[UISegmentedControl alloc] initWithItems:@[@"Share", @"Rename", @"Add Item"]];
    CGFloat availableWidth = CGRectGetWidth(self.tableView.frame) - _sideMargin * 2.0;
    CGFloat segmentWidth = availableWidth / _menu.numberOfSegments;
    for (int i = 0; i < _menu.numberOfSegments; i++) {
        [_menu setWidth:segmentWidth forSegmentAtIndex:i];
    }
    CGRect frm = _menu.frame;
    frm.origin.x = _sideMargin;
    frm.origin.y = -1.0 * _arrowBottomMargin - _arrowSize.height - _interMargin - CGRectGetHeight(frm);
    _menu.frame = frm;
    [self.tableView addSubview:_menu];
    
    _menu.tintColor = [UIColor colorWithRed:61.0/255 green:70.0/255 blue:77.0/255 alpha:1.0];
    
    _menuHomeY = CGRectGetMinY(_menu.frame);
    _arrowHomeY = CGRectGetMinY(_arrow.frame);
}

//===============================================
#pragma mark -
#pragma mark UITableViewDataSource
//===============================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.textLabel.text = @"testing asdfas as";
    return cell;
}

//===============================================
#pragma mark -
#pragma mark UITableViewDelegate
//===============================================

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat trueOffset = scrollView.contentOffset.y + scrollView.contentInset.top;
    
    NSLog(@"did scroll: %f", trueOffset);
    
    if (_menuGetsStuck) {
        
        CGRect frm = self.menu.frame;
        if (trueOffset < _menuHomeY) {
            frm.origin.y = trueOffset;
        }
        else {
            frm.origin.y = _menuHomeY;
        }
        self.menu.frame = frm;
        
        if (_arrowGetsStuck) {
            
            frm = self.arrow.frame;
            if (trueOffset < _menuHomeY) {
                frm.origin.y = trueOffset + CGRectGetHeight(self.menu.frame) + _interMargin;
            }
            else {
                frm.origin.y = _arrowHomeY;
            }
            self.arrow.frame = frm;
        }
    }
    
    CGFloat fullDuration = 5.0;
    CGFloat radians = atan2(self.arrow.transform.b, self.arrow.transform.a);
    NSLog(@"%f", radians);
    
    if (trueOffset < _flipPoint) {
        
        if (!_arrowHasFlipped) {
            _arrowHasCompletedFlipAnimation = NO;
            _arrowHasFlipped = YES;
            
            [UIView animateWithDuration:fullDuration delay:0.0 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
                self.arrow.transform = transform;
            } completion:^(BOOL finished) {
                _arrowHasCompletedFlipAnimation = YES;
                [self setMenuSelectionPerArrowPosition];
            }];
        }
    }
    else {
        
        if (_arrowHasFlipped) {
            _arrowHasCompletedFlipAnimation = NO;
            [self setMenuSelectionPerArrowPosition];
            _arrowHasFlipped = NO;
            [UIView animateWithDuration:fullDuration delay:0.0 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                CGAffineTransform transform = CGAffineTransformIdentity;
                self.arrow.transform = transform;
            } completion:^(BOOL finished) {
            }];
        }
    }
    
    // This is visually jarring
//    self.menu.hidden = (trueOffset >= _flipPoint);
}

- (BOOL)hasReachedFlipPoint {
    CGFloat trueOffset = self.tableView.contentOffset.y + self.tableView.contentInset.top;
    return (trueOffset < _flipPoint);
}

//===============================================
#pragma mark -
#pragma mark Table > Scrollview > PanGR
//===============================================

- (void)tableDidPan:(UIPanGestureRecognizer *)gestureRecognizer {
    
    NSLog(@"did pan");
    
//    CGPoint translation = [gestureRecognizer translationInView:self.tableView];
    CGPoint touchPoint = [gestureRecognizer locationInView:self.tableView];
    
    CGRect arrowFrm = self.arrow.frame;
    CGFloat originX = touchPoint.x - CGRectGetWidth(arrowFrm) / 2.0;
    originX = MAX(_sideMargin, originX);
    originX = MIN(CGRectGetMaxX(self.menu.frame) - CGRectGetWidth(arrowFrm), originX);
    arrowFrm.origin.x = originX;
    self.arrow.frame = arrowFrm;
    
    [self setMenuSelectionPerArrowPosition];
}

- (void)setMenuSelectionPerArrowPosition {
    
    CGRect arrowFrm = self.arrow.frame;
    
    CGFloat xPoint = CGRectGetMidX(arrowFrm) - _sideMargin;
    CGFloat segmentWidth = [self.menu widthForSegmentAtIndex:0];
    NSInteger index = floorf(xPoint / segmentWidth);
    
    if ([self hasReachedFlipPoint] && _arrowHasCompletedFlipAnimation && self.tableView.dragging && self.tableView.tracking) {
        [self.menu setSelectedSegmentIndex:index];
    }
    else {
        [self.menu setSelectedSegmentIndex:-1];
    }
}

@end
