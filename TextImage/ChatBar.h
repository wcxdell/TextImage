//
//  ChatBar.h
//  TextImage
//
//  Created by 王长旭 on 15/11/10.
//  Copyright © 2015年 王长旭. All rights reserved.
//

#import <UIKit/UIKit.h>


#define chatBarHeight 40

@protocol ChatBarDelegate;

@interface ChatBar : UIView

@property(weak,nonatomic) id<ChatBarDelegate> delegate;

-(void) endInputing;

@end

@protocol ChatBarDelegate <NSObject>

- (void) ChatBarDidChange:(ChatBar*)chatBar  Frame:(CGRect)frame;

- (void) sendMessage:(NSString*) message;

@end
