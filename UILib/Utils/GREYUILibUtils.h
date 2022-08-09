//
// Copyright 2022 Google Inc.
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

#import <UIKit/UIKit.h>

/**
 * Fetches the key window of @c application.
 *
 * @param application The UIApplication to look for key window.
 *
 * @return A UIWindow instance that specifies the key window of the @c application.
 */
UIWindow *GREYUILibUtilsGetApplicationKeyWindow(UIApplication *application);

/**
 * A provider for UIApplication windows. By default, all application windows are returned unless
 * this provider is initialized with custom windows.
 */
@interface GREYUILibUtils : NSObject

/**
 * @return A UIScreen which is the highest level view in the hierarchy of elements
 */
+ (UIScreen *)screen;

/**
 * @return A UIWindow which is the window on which all the scenes/view are rendered
 */
+ (UIWindow *)window;

@end
