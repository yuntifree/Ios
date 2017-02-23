//
//  JokeListCell.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/23.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "JokeListCell.h"

@interface JokeListCell ()
{
    __weak IBOutlet UILabel *_contentLbl;
    __weak IBOutlet UIButton *_likeBtn;
    __weak IBOutlet UILabel *_heartLbl;
    __weak IBOutlet UIButton *_unlikeBtn;
    __weak IBOutlet UILabel *_badLbl;
    
    NSDictionary *_attributeDic;
    JokeModel *_model;
}
@end

@implementation JokeListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6;
    _attributeDic = @{NSParagraphStyleAttributeName: style,
                      NSFontAttributeName: SystemFont(14),
                      NSForegroundColorAttributeName: COLOR(50, 50, 50, 1)};
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setJokeValue:(JokeModel *)model
{
    _model = model;
    if ([model.content isKindOfClass:[NSString class]] && model.content.length) {
        _contentLbl.attributedText = [[NSAttributedString alloc] initWithString:model.content attributes:_attributeDic];
    } else {
        _contentLbl.attributedText = nil;
    }
    if (model.heart >= 10000) {
        _heartLbl.text = [NSString stringWithFormat:@"%ld万人",model.heart / 10000];
    } else {
        _heartLbl.text = [NSString stringWithFormat:@"%ld人",model.heart];
    }
    if (model.bad >= 10000) {
        _badLbl.text = [NSString stringWithFormat:@"%ld万人",model.bad / 10000];
    } else {
        _badLbl.text = [NSString stringWithFormat:@"%ld人",model.bad];
    }
    _likeBtn.selected = model.liked;
    _unlikeBtn.selected = model.unliked;
}

- (IBAction)likeBtnClick:(UIButton *)sender {
    if (_likeBtn.selected || _unlikeBtn.selected) {
        if (_evaluatedBlock) {
            _evaluatedBlock();
        }
        return;
    }
    _model.liked = YES;
    _model.heart++;
    sender.transform = CGAffineTransformIdentity;
    [UIView animateKeyframesWithDuration:0.4 delay:0 options:0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 / 2.0 animations: ^{
            sender.transform = CGAffineTransformMakeScale(2.0, 2.0);
        }];
        [UIView addKeyframeWithRelativeStartTime:1 / 2.0 relativeDuration:1 / 2.0 animations: ^{
            sender.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    } completion:^(BOOL finished) {
        if (_likeOrUnlikeBlock) {
            _likeOrUnlikeBlock(_model, sender.tag - 100);
        }
    }];
}

- (IBAction)unlikeBtnClick:(UIButton *)sender {
    if (_likeBtn.selected || _unlikeBtn.selected) {
        if (_evaluatedBlock) {
            _evaluatedBlock();
        }
        return;
    }
    _model.unliked = YES;
    _model.bad++;
    sender.transform = CGAffineTransformIdentity;
    [UIView animateKeyframesWithDuration:0.4 delay:0 options:0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 / 2.0 animations: ^{
            sender.transform = CGAffineTransformMakeScale(0.5, 0.5);
        }];
        [UIView addKeyframeWithRelativeStartTime:1 / 2.0 relativeDuration:1 / 2.0 animations: ^{
            sender.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    } completion:^(BOOL finished) {
        if (_likeOrUnlikeBlock) {
            _likeOrUnlikeBlock(_model, sender.tag - 100);
        }
    }];
}

@end
