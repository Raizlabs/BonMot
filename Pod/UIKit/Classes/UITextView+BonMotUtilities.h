//
//  UITextView+BonMotUtilities.h
//  BonMot
//
//  Created by Nora Trapp on 3/2/16.
//
//

@import UIKit;

#import "BONCompatibility.h"

@interface UITextView (BonMotUtilities)

/**
 *  Assign a @c BONChain object to apply to the label text. When a new value is assigned to @c bonString the chain attributes will be applied.
 */
@property (BONNullable, copy, nonatomic) BONChain *bonChain;

/**
 *  Assigning a string via this method will apply the attributes of any assigned @c bonChain and set the @c attributedText with the resulting @c NSAttributedString.
 *
 *  @param string The text to be displayed.
 */
- (void)setBonString:(BONNullable NSString *)string;

@end
