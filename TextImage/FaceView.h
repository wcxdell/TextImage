//
//  FaceView.h
//  TextImage
//
//  Created by 王长旭 on 15/11/15.
//  Copyright © 2015年 王长旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FaceViewDelegate;

@interface FaceView : UIView

@property(weak,nonatomic) id<FaceViewDelegate> delegate;

- (instancetype) initWithFrame:(CGRect)frame;
@end

@protocol FaceViewDelegate <NSObject>

-(void) addFaceView:(NSString *) faceId;

-(void) sendMessage;

@end
