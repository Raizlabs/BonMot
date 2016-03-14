//
//  BONBaseTestCase.m
//  BonMot
//
//  Created by Zev Eisenberg on 7/10/15.
//  Copyright © 2015 Zev Eisenberg. All rights reserved.
//

@import XCTest;
#import "NSDictionary+BONEquality.h"
#import "DummyAssetClass.h"
#import "BONCompatibility.h"
#import "BonMot.h"

OBJC_EXTERN NSValue *BONValueFromRange(NSUInteger location, NSUInteger length);

#define BONTPrimitiveAssertCloseEnoughDictionaries(test, expression1, expressionStr1, expression2, expressionStr2, ...)                                                            \
    ({                                                                                                                                                                             \
        @try {                                                                                                                                                                     \
            id expressionValue1 = (expression1);                                                                                                                                   \
            id expressionValue2 = (expression2);                                                                                                                                   \
            if (![expressionValue1 bon_isCloseEnoughEqualToDictionary:expressionValue2]) {                                                                                         \
                _XCTRegisterFailure(test, _XCTFailureDescription(_XCTAssertion_EqualObjects, 0, expressionStr1, expressionStr2, expressionValue1, expressionValue2), __VA_ARGS__); \
            }                                                                                                                                                                      \
        }                                                                                                                                                                          \
        @catch (_XCTestCaseInterruptionException * interruption) {                                                                                                                 \
            [interruption raise];                                                                                                                                                  \
        }                                                                                                                                                                          \
        @catch (NSException * exception) {                                                                                                                                         \
            _XCTRegisterFailure(test, _XCTFailureDescription(_XCTAssertion_EqualObjects, 1, expressionStr1, expressionStr2, [exception reason]), __VA_ARGS__);                     \
        }                                                                                                                                                                          \
        @catch (...) {                                                                                                                                                             \
            _XCTRegisterFailure(test, _XCTFailureDescription(_XCTAssertion_EqualObjects, 2, expressionStr1, expressionStr2), __VA_ARGS__);                                         \
        }                                                                                                                                                                          \
    })

#define BONAssertEqualDictionaries(expression1, expression2, ...) \
    BONTPrimitiveAssertCloseEnoughDictionaries(self, expression1, @ #expression1, expression2, @ #expression2, __VA_ARGS__)

/**
 *  Uses XCTest assertions to check that the attributes of @c attributedString match the attributes and ranges in @c controlAttributes.
 *
 *  @param attributedString  The attributed string to validate.
 *  @param controlAttributes A dictionary whose keys are @c NSValue objects containing @c NSRange structs, and whose values are attributes dictionaries.
 */
#define BONAssertAttributedStringHasAttributes(attributedString, controlAttributes)                                                                                                              \
    NSMutableDictionary *mutableControlAttributes = controlAttributes.mutableCopy;                                                                                                               \
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(BONStringDict * BONCNonnull attrs, NSRange range, BOOL * BONCNonnull stop) { \
        NSValue *testRangeValue = [NSValue valueWithRange:range];                                                                                                                                    \
        NSDictionary *controlAttrs = controlAttributes[testRangeValue];                                                                                                                              \
        XCTAssertNotNil(controlAttrs, @"Attributed String had attributes that were not accounted for at %@: %@", NSStringFromRange(range), attrs);                                                   \
        BONAssertEqualDictionaries(attrs, controlAttrs);                                                                                                                                             \
        [mutableControlAttributes removeObjectForKey:testRangeValue]; }]; \
    XCTAssertEqual(mutableControlAttributes.count, 0, @"Some attributes not found in string: %@", mutableControlAttributes);

#define BONAssertEquivalentStrings(attributedString, controlHumanReadableString)       \
    NSAttributedString *castAttributedString = (NSAttributedString *)attributedString; \
    NSString *humanReadableString = castAttributedString.bon_humanReadableString;      \
    XCTAssertEqualObjects(humanReadableString, controlHumanReadableString);

@interface BONBaseTestCase : XCTestCase

@end
