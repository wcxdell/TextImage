//
//  ChatBar.m
//  TextImage
//
//  Created by 王长旭 on 15/11/10.
//  Copyright © 2015年 王长旭. All rights reserved.
//

#import "ChatBar.h"
#import "Masonry.h"
#import "FaceView.h"

@interface ChatBar()<UITextViewDelegate,FaceViewDelegate>

@property (strong,nonatomic) UITextView * textView;
@property (strong,nonatomic) UIButton * faceButton;
@property (strong,nonatomic) FaceView * faceView;

@property (assign,nonatomic,readonly) CGFloat screenHeight;

@end

@implementation ChatBar

#pragma mark - FaceViewDelegate


-(void)addFaceView:(NSString*)faceId{
    if ([faceId isEqualToString:@"[--100]"]) {
        [self textView:self.textView shouldChangeTextInRange:NSMakeRange(self.textView.text.length - 1, 1) replacementText:@""];
    }else{
       self.textView.text = [NSString stringWithFormat:@"%@%@",self.textView.text,faceId];
    }
    
}

-(void) sendMessage{
    [self.delegate sendMessage:self.textView.text];
    self.textView.text = @"";
    
}

#pragma mark - private

-(instancetype) initWithFrame:(CGRect)frame{
    if( self = [super initWithFrame:frame]){
        [self setup];
    }
    return self;
}

-(void) setup{
    [self addSubview:self.textField];
    [self addSubview:self.faceButton];
    
    UIImageView *topLine = [[UIImageView alloc] init];
    topLine.backgroundColor = [UIColor colorWithRed:180/255.0f green:180/255.0f blue:180/255.0f alpha:1.0f];
    [self addSubview:topLine];
    
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(@.5f);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    
    [self setNeedsUpdateConstraints];
    
}

-(void) updateConstraints{
    
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(self.mas_top).with.offset(6);
        make.height.equalTo(@(chatBarHeight-12));
        make.right.equalTo(self.faceButton.mas_left).with.offset(-10);
    }];
    
    [self.faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-10);
        make.top.equalTo(self.mas_top).offset(6);
        make.height.equalTo(self.textView.mas_height);
        make.width.equalTo(self.textView.mas_height);
    }];
    
    [super updateConstraints];
}

-(void) faceButtonTouch:(UIButton*) button{
    [self.superview addSubview:self.faceView];
    self.faceButton.selected = !self.faceButton.selected;
    if (self.faceButton.selected) {
        if ([self.textView isFirstResponder]){
            [self.textView resignFirstResponder];
        }
        [UIView animateWithDuration:0.3f animations:^{
            [self.faceView setFrame:CGRectMake(0, self.screenHeight - 210, self.faceView.frame.size.width, self.faceView.frame.size.height)];
        }];
        [self setFrame:CGRectMake(0, [self screenHeight] - chatBarHeight - self.faceView.frame.size.height, self.frame.size.width, self.frame.size.height) animated:YES];
    }else{
        [self.textView becomeFirstResponder];
        [self closeFaceView];
    }
}


-(void) keyBoardWillHide:(NSNotification *)notification{
    CGRect tmpRect = self.frame;
    tmpRect.origin.y = self.screenHeight - chatBarHeight;
    [self setFrame:tmpRect animated:YES];
}

-(void) keyBoardWillShow:(NSNotification *)notification{
    CGSize keyBoardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect chatViewFrame = self.frame;
//    chatViewFrame.origin.y = chatViewFrame.origin.y - keyBoardRect.height;
    chatViewFrame.origin.y = [self screenHeight] - keyBoardRect.height - self.frame.size.height;
    [self setFrame:chatViewFrame animated:YES];
    [self closeFaceView];
    
}

-(void) chatBarWillChange{
    
}

-(void)closeFaceView{
    CGRect tmpRect = self.faceView.frame;
    tmpRect.origin.y = [self screenHeight];
    [UIView animateWithDuration:0.3f animations:^{
        self.faceView.frame = tmpRect;
    }];
    self.faceButton.selected = NO;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - TextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self.delegate sendMessage:textView.text];
        textView.text = @"";
        return NO;
    }else if(text.length == 0){
        NSString * replaceFaceId = [self.textView.text substringWithRange:range];
        if ([replaceFaceId isEqualToString:@"]"]) {
            while (YES) {
                range.location--;
                range.length++;
                replaceFaceId = [self.textView.text substringWithRange:range];
                if (range.location == 0 && ![replaceFaceId hasPrefix:@"["]) {
                    return YES;
                }
                if([replaceFaceId hasPrefix:@"[--"] && [replaceFaceId hasSuffix:@"]"]){
                    break;
                }
            }
            self.textView.text = [self.textView.text stringByReplacingCharactersInRange:range withString:@""];
            [self.textView setSelectedRange:NSMakeRange(range.location, 0)];
            return NO;
        }else if(self.textView.text.length != 0){
            self.textView.text = [self.textView.text stringByReplacingCharactersInRange:range withString:@""];
            [self.textView setSelectedRange:NSMakeRange(range.location, 0)];
        }
    }
    return YES;
}

#pragma mark - public Method

-(void)endInputing{
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }else{
        [self closeFaceView];
        CGRect tmpRect = self.frame;
        tmpRect.origin.y = self.screenHeight - chatBarHeight;
        [self setFrame:tmpRect animated:YES];
    }
    
}

#pragma mark - Getter
- (CGFloat)screenHeight{
    
    return [[UIApplication sharedApplication] keyWindow].bounds.size.height;
}

-(UITextView*) textField{
    if(!_textView){
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:16.0f];
        _textView.layer.cornerRadius = 4.0f;
        _textView.layer.masksToBounds = YES;
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textView.layer.borderWidth = 0.5f;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.delegate = self;
    }
    return _textView;
}

-(UIButton *) faceButton{
    if (!_faceButton) {
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_faceButton setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
        [_faceButton setBackgroundImage:[UIImage imageNamed:@"input"] forState:UIControlStateSelected];
    }
    
    [_faceButton addTarget:self action:@selector(faceButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    return _faceButton;
}

-(FaceView *)faceView{
    if (!_faceView) {
        _faceView = [[FaceView alloc]initWithFrame:CGRectMake(0, self.screenHeight, self.frame.size.width, 210)];
        _faceView.backgroundColor = self.backgroundColor;
        _faceView.delegate = self;
    }
    return _faceView;
}

- (void)setFrame:(CGRect)frame animated:(BOOL)animated{
    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            [self setFrame:frame];
        }];
    }else{
        [self setFrame:frame];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ChatBarDidChange:Frame:)]) {
        [self.delegate ChatBarDidChange:self Frame:frame];
    }
}

@end
