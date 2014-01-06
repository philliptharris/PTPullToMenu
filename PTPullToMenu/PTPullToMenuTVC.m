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
@property (nonatomic, strong) UISegmentedControl *seg;
@property (nonatomic, strong) UIView *menu;
@property (nonatomic, assign) CGFloat sideMargin;
@property (nonatomic, assign) CGSize arrowSize;
@property (nonatomic, assign) CGFloat interMargin;
@property (nonatomic, assign) CGFloat arrowBottomMargin;
@property (nonatomic, assign) CGFloat menuHomeY;
//@property (nonatomic, assign) CGFloat arrowHomeY;
@property (nonatomic, assign) CGFloat flipPoint;
@property (nonatomic, assign) BOOL menuGetsStuck;
//@property (nonatomic, assign) BOOL arrowGetsStuck;
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
    
//    self.tableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    
    [self.tableView.panGestureRecognizer addTarget:self action:@selector(tableDidPan:)];
    
    _menuGetsStuck = YES;
//    _arrowGetsStuck = YES;
    _arrowHasFlipped = NO;
    _arrowHasCompletedFlipAnimation = NO;
    
    _arrowSize = CGSizeMake(13.0, 39.0/2.0);
    _arrowBottomMargin = 4.0;
    _sideMargin = -5.0;
    _interMargin = 0.0;
    _flipPoint = -54.0;
    
    _seg = [[UISegmentedControl alloc] initWithItems:@[@"Share", @"Rename", @"Add Item"]];
    _seg.tintColor = [UIColor colorWithRed:61.0/255 green:70.0/255 blue:77.0/255 alpha:1.0];
    _seg.tintColor = [UIColor colorWithRed:0.0/255 green:126.0/255 blue:229.0/255 alpha:1.0];
    CGFloat availableWidth = CGRectGetWidth(self.tableView.frame) - _sideMargin * 2.0;
    CGFloat segmentWidth = availableWidth / _seg.numberOfSegments;
    for (int i = 0; i < _seg.numberOfSegments; i++) {
        [_seg setWidth:segmentWidth forSegmentAtIndex:i];
    }
    CGRect segFrm = _seg.frame;
    
    CGFloat menuHeight = _arrowBottomMargin + _arrowSize.height + _interMargin + CGRectGetHeight(segFrm);
    
    _menu = [[UIView alloc] initWithFrame:CGRectMake(0.0, -1.0 * menuHeight, CGRectGetWidth(self.tableView.frame), menuHeight)];
    [self.tableView addSubview:_menu];
    _menu.backgroundColor = [UIColor clearColor];
    
    CGFloat baseY = menuHeight;
    
    _arrow = [[UIView alloc] initWithFrame:CGRectMake(0.0, baseY - (_arrowSize.height + _arrowBottomMargin), _arrowSize.width, _arrowSize.height)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitterArrow"]];
    [_arrow addSubview:imgView];
    [_menu addSubview:_arrow];
    
    segFrm.origin.x = _sideMargin;
    segFrm.origin.y = baseY - _arrowBottomMargin - _arrowSize.height - _interMargin - CGRectGetHeight(segFrm);
    _seg.frame = segFrm;
    [_menu addSubview:_seg];
    
    _menuHomeY = CGRectGetMinY(_menu.frame);
//    _arrowHomeY = CGRectGetMinY(_arrow.frame);
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
    
    NSLog(@"did scroll to trueOffset: %f", trueOffset);
    
    if (_menuGetsStuck) {
        
        CGRect frm = self.menu.frame;
        if (trueOffset < _menuHomeY) {
            frm.origin.y = trueOffset + (_menuHomeY - trueOffset) / 3.0;
        }
        else {
            frm.origin.y = _menuHomeY;
        }
        self.menu.frame = frm;
        
//        if (_arrowGetsStuck) {
//            
//            frm = self.arrow.frame;
//            if (trueOffset < _menuHomeY) {
//                frm.origin.y = trueOffset + CGRectGetHeight(self.menu.frame) + _interMargin;
//            }
//            else {
//                frm.origin.y = _arrowHomeY;
//            }
//            self.arrow.frame = frm;
//        }
    }
    
    CGFloat fullDuration = 0.2;
//    CGFloat radians = atan2(self.arrow.transform.b, self.arrow.transform.a);
//    NSLog(@"%f", radians);
    
    if (trueOffset < _flipPoint) {
        
        if (!_arrowHasFlipped) {
            
            NSLog(@"FLIP TO ACTIVE");
            
            _arrowHasCompletedFlipAnimation = NO;
            _arrowHasFlipped = YES;
            
            CGRect frm = self.seg.frame;
            frm.origin.y = -1.0 * CGRectGetHeight(frm);
            self.seg.frame = frm;
            self.seg.hidden = NO;
            frm.origin.y = 0.0;
            
            [UIView animateWithDuration:fullDuration delay:0.0 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
                self.arrow.transform = transform;
            } completion:^(BOOL finished) {
                _arrowHasCompletedFlipAnimation = YES;
                [self setMenuSelectionPerArrowPosition];
            }];
            
            [UIView animateWithDuration:fullDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.seg.frame = frm;
            } completion:^(BOOL finished) {
            }];
        }
    }
    else {
        
        if (_arrowHasFlipped) {
            
            NSLog(@"DE-FLIP");
            
            _arrowHasCompletedFlipAnimation = NO;
            [self setMenuSelectionPerArrowPosition];
            _arrowHasFlipped = NO;
            
            CGRect frm = self.seg.frame;
            frm.origin.y = -1.0 * CGRectGetHeight(frm);
            
            [UIView animateWithDuration:fullDuration delay:0.0 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                CGAffineTransform transform = CGAffineTransformIdentity;
                self.arrow.transform = transform;
            } completion:^(BOOL finished) {
            }];
            
            [UIView animateWithDuration:fullDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.seg.frame = frm;
            } completion:^(BOOL finished) {
                self.seg.hidden = YES;
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
    
//    NSLog(@"did pan");
    
//    CGPoint translation = [gestureRecognizer translationInView:self.tableView];
    CGPoint touchPoint = [gestureRecognizer locationInView:self.tableView];
    
    CGRect arrowFrm = self.arrow.frame;
    CGFloat originX = touchPoint.x - CGRectGetWidth(arrowFrm) / 2.0;
    originX = MAX(_sideMargin, originX);
    originX = MIN(CGRectGetMaxX(self.seg.frame) - CGRectGetWidth(arrowFrm), originX);
    arrowFrm.origin.x = originX;
    self.arrow.frame = arrowFrm;
    
    [self setMenuSelectionPerArrowPosition];
}

- (void)setMenuSelectionPerArrowPosition {
    
    CGRect arrowFrm = self.arrow.frame;
    
    CGFloat xPoint = CGRectGetMidX(arrowFrm) - _sideMargin;
    CGFloat segmentWidth = [self.seg widthForSegmentAtIndex:0];
    NSInteger index = floorf(xPoint / segmentWidth);
    
    if ([self hasReachedFlipPoint] && _arrowHasCompletedFlipAnimation && self.tableView.dragging && self.tableView.tracking) {
        [self.seg setSelectedSegmentIndex:index];
    }
    else {
        [self.seg setSelectedSegmentIndex:-1];
    }
}

@end
