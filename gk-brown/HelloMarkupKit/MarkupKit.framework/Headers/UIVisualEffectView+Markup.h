//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIVisualEffectView (Markup)

/**
 * Creates an extra-light blur effect view.
 */
+ (UIVisualEffectView *)extraLightBlurEffectView;

/**
 * Creates a light blur effect view.
 */
+ (UIVisualEffectView *)lightBlurEffectView;

/**
 * Creates a dark blur effect view.
 */
+ (UIVisualEffectView *)darkBlurEffectView;

#if TARGET_OS_TV
/**
 * Creates an extra-dark blur effect view.
 */
+ (UIVisualEffectView *)extraDarkBlurEffectView;
#endif

/**
 * Creates a regular blur effect view.
 */
+ (UIVisualEffectView *)regularBlurEffectView;

/**
 * Creates a prominent blur effect view.
 */
+ (UIVisualEffectView *)prominentBlurEffectView;

@end

NS_ASSUME_NONNULL_END
