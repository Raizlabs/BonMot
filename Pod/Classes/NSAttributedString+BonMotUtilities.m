//
//  NSAttributedString+BonMotUtilities.m
//  BonMot
//
//  Created by Eliot Williams on 3/9/16.
//
//

#import "NSAttributedString+BonMotUtilities.h"
#import "BONChain.h"
#import "BONSpecial.h"

static NSString *const kUnassignedCharacterNamePrefix = @"\\N{<unassigned-";
static NSString *const kUnassignedCharacterNameSuffix = @">}";

@implementation NSAttributedString (BonMotUtilities)

- (NSString *)bon_humanReadableStringIncludingImageSize:(BOOL)shouldIncludeImageSize
{
    NSString *originalString = self.string;
    NSMutableString *composedHumanReadableString = [NSMutableString string];

    [originalString enumerateSubstringsInRange:NSMakeRange(0, originalString.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *BONCNullable substring, NSRange substringRange, NSRange enclosingRange, BOOL *BONCNonnull stop) {

        static NSCharacterSet *s_newLineCharacterSet = nil;
        if (!s_newLineCharacterSet) {
            s_newLineCharacterSet = [NSCharacterSet newlineCharacterSet];
        }
        NSCharacterSet *s_whiteSpaceAndNewLinesSet = nil;
        if (!s_whiteSpaceAndNewLinesSet) {
            s_whiteSpaceAndNewLinesSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        }

        unichar character = [substring characterAtIndex:0];
        NSString *specialCharacterSubstitutionString = [BONSpecial humanReadableStringDictionary][@(character)];

        NSMutableString *mutableUnicodeName = substring.mutableCopy;
        CFStringTransform((CFMutableStringRef)mutableUnicodeName, NULL, kCFStringTransformToUnicodeName, FALSE);

        BONStringDict *attributes = [self attributesAtIndex:substringRange.location effectiveRange:NULL];
        NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
        UIImage *attachedImage;
        attachedImage = attachment.image;

        // Substitute attached images with @"{image#heightx#width}"
        if (attachedImage) {
            NSString *imageSubstitutionString;
            NSMutableString *imageSizeString = [NSMutableString stringWithFormat:@"%@", NSStringFromCGSize(attachedImage.size)];
            if (imageSizeString && shouldIncludeImageSize) {
                NSMutableString *modifiedImageSizeString = [imageSizeString stringByReplacingOccurrencesOfString:@", " withString:@"x"].mutableCopy;
                [modifiedImageSizeString insertString:@"image" atIndex:1];
                imageSubstitutionString = modifiedImageSizeString;
            }
            else {
                imageSubstitutionString = @"{image}";
            }
            [composedHumanReadableString appendString:imageSubstitutionString];
        }
        // Swap applicable BONSpecial characters with @"{#camelCaseName}"
        else if (specialCharacterSubstitutionString) {
            [composedHumanReadableString appendFormat:@"%@", specialCharacterSubstitutionString];
        }
        // Substitute Newline character with  @"{newline}"
        else if ([substring rangeOfCharacterFromSet:s_newLineCharacterSet].location != NSNotFound) {
            [composedHumanReadableString appendString:@"{newline}"];
        }
        // Substitute 򡌸 or similar with {unassignedUnicode#unicodeNumber}
        else if ([mutableUnicodeName hasPrefix:kUnassignedCharacterNamePrefix] && [mutableUnicodeName hasSuffix:kUnassignedCharacterNameSuffix]) {
            NSString *unicodeName = [mutableUnicodeName substringWithRange:NSMakeRange(kUnassignedCharacterNamePrefix.length, mutableUnicodeName.length - kUnassignedCharacterNamePrefix.length - kUnassignedCharacterNameSuffix.length)];

            NSString *unassignedCharacterString = [NSString stringWithFormat:@"{unassignedUnicode%@}", unicodeName];
            [composedHumanReadableString appendString:unassignedCharacterString];
        }
        else {
            [composedHumanReadableString appendString:substring];
        }
    }];

    return composedHumanReadableString;
}

@end
