//
//  TextImageCell.m
//  TextImage
//
//  Created by 王长旭 on 15/11/5.
//  Copyright © 2015年 王长旭. All rights reserved.
//

#import "TextImageCell.h"
#import "Masonry.h"
#import "FaceManager.h"

#define maxTextWidth self.contentView.frame.size.width - 40

@implementation TextImageCell


#pragma mark - Override Methods


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"点击了cell");
}


#pragma mark - Public Methods
- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)updateConstraints{
    [super updateConstraints];
    
    [self.backgroundImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-8);
        make.top.equalTo(self.contentView.mas_top).with.offset(8);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-8);
        make.width.lessThanOrEqualTo(@(maxTextWidth));
    }];
    
    [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.backgroundImageView).with.insets(UIEdgeInsetsMake(10, 15, 10, 15));
    }];
    
}

-(void) setup{
    [self.contentView addSubview:self.backgroundImageView];
    [self.backgroundImageView addSubview:self.messageLabel];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Setters
- (void)setMessages:(NSString *)message{
    self.backgroundImageView.image = [[UIImage imageNamed:@"pop"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
    NSMutableAttributedString *attrS = [FaceManager replaceStrWithEmotion:message];
    [attrS addAttributes:[self textStyle] range:NSMakeRange(0, attrS.length)];
    self.messageLabel.attributedText = attrS;
    [self updateConstraints];
}

#pragma mark - Getters
-(UIImageView*) backgroundImageView{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]init];
    }
    return _backgroundImageView;
}

-(UILabel *) messageLabel{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.numberOfLines = 0;
        _messageLabel.preferredMaxLayoutWidth = maxTextWidth;
        _messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _messageLabel;
}

- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    style.paragraphSpacing = 0.25 * font.lineHeight;
    style.hyphenationFactor = 1.0;
    return @{NSFontAttributeName: font,
             NSParagraphStyleAttributeName: style};
}

@end
