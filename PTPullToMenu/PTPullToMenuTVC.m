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
    
    _arrowSize = CGSizeMake(20.0, 29.0);
    _arrowBottomMargin = 10.0;
    _flipPoint = 60.0;
    
    _arrow = [[UIView alloc] initWithFrame:CGRectMake(0.0, -1.0 * (_arrowSize.height + _arrowBottomMargin), _arrowSize.width, _arrowSize.height)];
    _arrow.backgroundColor = [UIColor clearColor];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
    [_arrow addSubview:imgView];
    [self.tableView addSubview:_arrow];
    
    _sideMargin = -5.0;
    _interMargin = 10.0;
    
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
    
    CGRect frm = self.menu.frame;
    if (trueOffset < _menuHomeY) {
        frm.origin.y = trueOffset;
    }
    else {
        frm.origin.y = _menuHomeY;
    }
    self.menu.frame = frm;
    
    frm = self.arrow.frame;
    if (trueOffset < _arrowHomeY) {
        frm.origin.y = trueOffset + CGRectGetHeight(self.menu.frame) + _interMargin;
    }
    else {
        frm.origin.y = _arrowHomeY;
    }
    self.arrow.frame = frm;
}

//===============================================
#pragma mark -
#pragma mark Table > Scrollview > PanGR
//===============================================

- (void)tableDidPan:(UIPanGestureRecognizer *)gestureRecognizer {
    
    NSLog(@"did pan");
    
    CGPoint translation = [gestureRecognizer translationInView:self.tableView];
    CGPoint touchPoint = [gestureRecognizer locationInView:self.tableView];
    
    CGRect frm = self.arrow.frame;
    CGFloat originX = touchPoint.x - CGRectGetWidth(frm) / 2.0;
    originX = MAX(_sideMargin, originX);
    originX = MIN(CGRectGetMaxX(self.menu.frame) - CGRectGetWidth(frm), originX);
    frm.origin.x = originX;
    self.arrow.frame = frm;
    
    CGFloat xPoint = CGRectGetMidX(frm) - _sideMargin;
    CGFloat segmentWidth = [self.menu widthForSegmentAtIndex:0];
    NSInteger index = floorf(xPoint / segmentWidth);
    [self.menu setSelectedSegmentIndex:index];
}

@end
