//
// Copyright 2020 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "GREYErrorFormatter.h"

#import "GREYFatalAsserts.h"
#import "GREYError+Private.h"
#import "GREYError.h"
#import "GREYErrorConstants.h"
#import "GREYObjectFormatter.h"
#import "NSError+GREYCommon.h"

#pragma mark - UI Hierarchy Keys

static NSString *const kHierarchyWindowLegendKey = @"[Window 1]";
static NSString *const kHierarchyAcessibilityLegendKey = @"[AX]";
static NSString *const kHierarchyUserInteractionEnabledLegendKey = @"[UIE]";
static NSString *const kHierarchyBackWindowKey = @"Back-Most Window";
static NSString *const kHierarchyAccessibilityKey = @"Accessibility";
static NSString *const kHierarchyUserInteractionEnabledKey = @"User Interaction Enabled";
static NSString *const kHierarchyLegendKey = @"Legend";
static NSString *const kHierarchyHeaderKey = @"UI Hierarchy (ordered by wind"
                                             @"ow level, back to front):\n";
static NSString *const kErrorPrefix = @"EarlGrey Encountered an Error:";

#pragma mark - GREYErrorFormatter

@implementation GREYErrorFormatter

#pragma mark - Public Methods

+ (NSString *)formattedDescriptionForError:(GREYError *)error {
  if (GREYShouldUseErrorFormatterForError(error)) {
    return LoggerDescription(error);
  } else {
    return [GREYObjectFormatter formatDictionary:[error grey_descriptionDictionary]
                                          indent:kGREYObjectFormatIndent
                                       hideEmpty:YES
                                        keyOrder:nil];
  }
}

#pragma mark - Public Functions

BOOL GREYShouldUseErrorFormatterForError(GREYError *error) {
  return [error.domain isEqualToString:kGREYInteractionErrorDomain] &&
         error.code == kGREYInteractionElementNotFoundErrorCode;
}

BOOL GREYShouldUseErrorFormatterForDetails(NSString *failureHandlerDetails) {
  return [failureHandlerDetails hasPrefix:kErrorPrefix];
}

#pragma mark - Static Functions

static NSString *FormattedHierarchy(NSString *hierarchy) {
  if (!hierarchy) {
    return nil;
  }
  NSMutableArray<NSString *> *logger = [[NSMutableArray alloc] init];
  [logger addObject:kHierarchyHeaderKey];
  NSString *windowLegend = kHierarchyWindowLegendKey;
  NSString *axLegend = kHierarchyAcessibilityLegendKey;
  NSString *uieLegend = kHierarchyUserInteractionEnabledLegendKey;
  NSDictionary<NSString *, NSString *> *legendLabels = @{
    windowLegend : kHierarchyBackWindowKey,
    axLegend : kHierarchyAccessibilityKey,
    uieLegend : kHierarchyUserInteractionEnabledKey
  };
  NSArray<NSString *> *keyOrder = @[ windowLegend, axLegend, uieLegend ];
  NSString *legendDescription = [GREYObjectFormatter formatDictionary:legendLabels
                                                               indent:kGREYObjectFormatIndent
                                                            hideEmpty:NO
                                                             keyOrder:keyOrder];
  [logger
      addObject:[NSString stringWithFormat:@"%@: %@\n", kHierarchyLegendKey, legendDescription]];
  [logger addObject:hierarchy];
  return [logger componentsJoinedByString:@"\n"];
}

static NSString *LoggerDescription(GREYError *error) {
  NSMutableString *logger = [[NSMutableString alloc] init];
  // Flag checked by GREYErrorFormatted(details, screenshotPaths).
  // TODO(wsaid): remove this when the GREYErrorFormatted(details, screenshotPaths) is removed
  [logger appendString:kErrorPrefix];
  NSString *exceptionReason = error.localizedDescription;
  if (exceptionReason) {
    [logger appendFormat:@"\n\n%@", exceptionReason];
  }

  NSString *recoverySuggestion = error.userInfo[kErrorDetailRecoverySuggestionKey];
  if (recoverySuggestion) {
    [logger appendFormat:@"\n\n%@", recoverySuggestion];
  }

  NSString *elementMatcher = error.userInfo[kErrorDetailElementMatcherKey];
  if (elementMatcher) {
    [logger appendFormat:@"\n\n%@:\n%@", kErrorDetailElementMatcherKey, elementMatcher];
  }

  NSString *assertionCriteria = error.userInfo[kErrorDetailAssertCriteriaKey];
  if (assertionCriteria) {
    [logger appendFormat:@"\n\n%@: %@", kErrorDetailAssertCriteriaKey, assertionCriteria];
  }
  NSString *actionCriteria = error.userInfo[kErrorDetailActionNameKey];
  if (actionCriteria) {
    [logger appendFormat:@"\n\n%@: %@", kErrorDetailActionNameKey, actionCriteria];
  }

  NSString *searchActionInfo = error.userInfo[kErrorDetailSearchActionInfoKey];
  if (searchActionInfo) {
    [logger appendFormat:@"\n\n%@\n%@", kErrorDetailSearchActionInfoKey, searchActionInfo];
  }

  NSString *nestedError = error.nestedError.description;
  if (nestedError) {
    [logger appendFormat:@"\n\nUnderlying Error:\n%@", nestedError];
  }

  NSString *hierarchy = FormattedHierarchy(error.appUIHierarchy);
  if (hierarchy) {
    [logger appendFormat:@"\n\n%@", hierarchy];
  }

  return [NSString stringWithFormat:@"%@\n", logger];
}

@end