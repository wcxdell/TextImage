//
//  FaceView.m
//  TextImage
//
//  Created by 王长旭 on 15/11/15.
//  Copyright © 2015年 王长旭. All rights reserved.
//

#import "FaceView.h"
#import "FaceManager.h"

static const NSInteger kMaxLine = 2;
static const NSInteger kMaxPerLine = 6;


@interface FacePreviewView : UIView

@property (weak, nonatomic) UIImageView *faceImageView /**< 展示face表情的 */;
@property (weak, nonatomic) UIImageView *backgroundImageView /**< 默认背景 */;

@end

@implementation FacePreviewView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"previewFace"]];
    [self addSubview:self.backgroundImageView = backgroundImageView];
    
    UIImageView *faceImageView = [[UIImageView alloc] init];
    [self addSubview:self.faceImageView = faceImageView];
    
    self.bounds = self.backgroundImageView.bounds;
}

/**
 *  修改faceImageView显示的图片
 *
 *  @param image 需要显示的表情图片
 */
- (void)setFaceImage:(UIImage *)image{
    if (self.faceImageView.image == image) {
        return;
    }
    [self.faceImageView setImage:image];
    [self.faceImageView sizeToFit];
    self.faceImageView.center = self.backgroundImageView.center;
    [UIView animateWithDuration:.3 animations:^{
        self.faceImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
//        self.faceImageView.transform = CGAffineTransformScale(self.faceImageView.transform, 1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            self.faceImageView.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end


@interface FaceView()<UIScrollViewDelegate>
@property(nonatomic,strong) UIScrollView * scrollView;
@property(nonatomic,strong) UIPageControl * pageControl;
@property (nonatomic,strong) UIView * bottomView;

@property(strong,nonatomic) FacePreviewView * facePreviewView;

@property(assign,nonatomic) NSUInteger facePage;
@end

@implementation FaceView

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.pageControl setCurrentPage:scrollView.contentOffset.x / scrollView.frame.size.width];
    self.facePage = self.pageControl.currentPage;
}


#pragma mark - private
- (instancetype) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void) setup{
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
    [self addSubview:self.bottomView];
    
    [self setupEmojiFaces];
    
    self.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.scrollView addGestureRecognizer:longPress];
}

-(void) setupEmojiFaces{
    
//    [self resetScrollView];
    
    NSInteger pageItemCount = kMaxLine * kMaxPerLine - 1;
    
    NSMutableArray *faceIdArray = [NSMutableArray arrayWithArray:[FaceManager shareInstance].emojiFaceArrays];
    
    NSUInteger pageCount = faceIdArray.count % pageItemCount == 0 ? faceIdArray.count/pageItemCount : faceIdArray.count/pageItemCount + 1;
    
    self.pageControl.numberOfPages = pageCount;
    
    for (int i = 0; i < pageCount; i ++) {
        if (i == pageCount - 1) {
            [faceIdArray addObject:@{@"face_id":@"100",@"face_name":@"[--100]"}];
        }else{
            [faceIdArray insertObject:@{@"face_id":@"100",@"face_name":@"[--100]"} atIndex:(1 + i)*pageItemCount + i];
        }
    }
    
    NSUInteger page = 0;
    NSUInteger column = 0;
    NSUInteger row = 0;
    
    CGFloat itemWidth = (self.frame.size.width - 20)/kMaxPerLine;
    
    for (NSDictionary * face in faceIdArray) {

        if (column > kMaxPerLine - 1) {
            row ++ ;
            column = 0;
        }

        if (row > kMaxLine - 1) {
            row = 0;
            column = 0;
            page ++ ;
        }
        

        CGFloat startX = 10 + column * itemWidth + page * self.frame.size.width;

        CGFloat startY = row * itemWidth;
        
        UIImageView *imageView =[self faceImageViewWithFaceId:face[@"face_id"]];
        [imageView setFrame:CGRectMake(startX, startY, itemWidth, itemWidth)];
        [self.scrollView addSubview:imageView];
        column ++ ;
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * (page + 1), self.scrollView.frame.size.height)];
    [self.scrollView setContentOffset:CGPointMake(self.facePage * self.frame.size.width, 0)];
    self.pageControl.currentPage = self.facePage;
}

-(UIImageView *) faceImageViewWithFaceId:(NSString*) faceId{
    NSString *faceImageName = [FaceManager faceImageNameWithFaceID:faceId];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:faceImageName]];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.tag = [faceId integerValue];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceTap:)];
    [imageView addGestureRecognizer:tap];
    
    return imageView;
}

-(void)faceTap:(UITapGestureRecognizer *) recognizer{
    NSString * faceId = [NSString stringWithFormat:@"%ld",recognizer.view.tag];
    [self.delegate addFaceView:[FaceManager faceImageNameWithFaceID:faceId]];
}

-(void) resetScrollView{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollView setContentSize:CGSizeZero];
    [self.pageControl setNumberOfPages:0];
}

-(void) handleLongPress:(UILongPressGestureRecognizer*)longPress{
    CGPoint touchPoint = [longPress locationInView:self];
    UIImageView *touchFaceView = [self faceViewWithinInPoint:touchPoint];
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self.facePreviewView setCenter:CGPointMake(touchPoint.x, touchPoint.y - 70)];
        [self.facePreviewView setFaceImage:touchFaceView.image];
        [self addSubview:self.facePreviewView];
    }else if (longPress.state == UIGestureRecognizerStateChanged){
        [self.facePreviewView setCenter:CGPointMake(touchPoint.x, touchPoint.y - 70)];
        [self.facePreviewView setFaceImage:touchFaceView.image];
    }else if (longPress.state == UIGestureRecognizerStateEnded) {
        [self.facePreviewView removeFromSuperview];
    }
}

- (UIImageView *)faceViewWithinInPoint:(CGPoint)point{
    
    for (UIImageView *imageView in self.scrollView.subviews) {
        if (CGRectContainsPoint(imageView.frame, CGPointMake(self.pageControl.currentPage * self.frame.size.width + point.x, point.y))) {
            return imageView;
        }
    }
    return nil;
}

-(void) sendAction:(UIButton*) button{
    [self.delegate sendMessage];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - Getters

- (UIScrollView*) scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height - 60)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *) pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, _scrollView.frame.size.height, self.frame.size.width, 20)];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

- (UIView *) bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _pageControl.frame.origin.y + _pageControl.frame.size.height, self.frame.size.width, 40)];
        
        UIImageView * topLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width - 70, 0.5f)];
        topLine.backgroundColor = [UIColor lightGrayColor];
        [_bottomView addSubview:topLine];
        
        UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 70, 0, 70, 40)];
//        sendButton.backgroundColor = [UIColor lightGrayColor];
//        [sendButton s];
        [sendButton setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        [sendButton setBackgroundImage:[self imageWithColor:[UIColor darkGrayColor]] forState:UIControlStateHighlighted];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:sendButton];
    }
    return _bottomView;
}

- (FacePreviewView *) facePreviewView {
    if (!_facePreviewView) {
        _facePreviewView = [[FacePreviewView alloc] initWithFrame:CGRectZero];
    }
    return _facePreviewView;
}

@end
