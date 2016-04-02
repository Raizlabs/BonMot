//
//  BaselineCapHeightCell.m
//  BonMot
//
//  Created by Zev Eisenberg on 4/20/15.
//  Copyright © 2015 Zev Eisenberg. All rights reserved.
//

#import "BaselineCapHeightCell.h"

static NSString *const kFontNameEBGaramond = @"EBGaramond12-Regular";

@interface BaselineCapHeightCell ()

@property (strong, nonatomic) IBOutletCollection(UILabel) BONGeneric(NSArray, UILabel *) * capHeightNumberLabels;

@property (weak, nonatomic) IBOutlet UILabel *numberCapHeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberXHeightLabel;
@property (weak, nonatomic) IBOutlet UIView *capHeightBaselineHairline;
@property (weak, nonatomic) IBOutlet UIView *xHeightBaselineHairline;

@end

@implementation BaselineCapHeightCell

+ (NSString *)title
{
    return @"Cap Height & X-Height";
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSAttributedString *numberString = BONChain.new.fontNameAndSize(kFontNameEBGaramond, 100.0).figureCase(BONFigureCaseOldstyle).string(@"167").attributedString;

    for (UILabel *label in self.capHeightNumberLabels) {
        label.attributedText = numberString;
    }

    [NSLayoutConstraint constraintWithItem:self.numberCapHeightLabel
                                 attribute:NSLayoutAttributeBaseline
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.capHeightBaselineHairline
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0.0]
        .active = YES;

    [NSLayoutConstraint constraintWithItem:self.numberXHeightLabel
                                 attribute:NSLayoutAttributeBaseline
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.xHeightBaselineHairline
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0.0]
        .active = YES;
}

@end
