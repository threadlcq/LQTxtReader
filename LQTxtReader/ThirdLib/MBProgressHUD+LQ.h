//
//  MBProgressHUD+LQ.h
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/3.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (LQ)
+ (nonnull MBProgressHUD *)showSuccess:(NSString *_Nullable)success;
+ (nonnull MBProgressHUD *)showSuccess:(NSString *_Nullable)success toView:(UIView *_Nullable)view;
+ (void)showSuccess:(NSString *_Nullable)success completion:(nullable MBProgressHUDCompletionBlock)completionBlock;
+ (void)showSuccess:(NSString *_Nullable)success toView:(UIView *_Nullable)view completion:(nullable MBProgressHUDCompletionBlock)completionBlock;
    
+ (nonnull MBProgressHUD *)showError:(NSString *_Nullable)error;
+ (nonnull MBProgressHUD *)showError:(NSString *_Nullable)error toView:(UIView *_Nullable)view;
+ (void)showError:(NSString *_Nullable)error completion:(nullable MBProgressHUDCompletionBlock)completionBlock;
+ (void)showError:(NSString *_Nullable)error toView:(UIView *_Nullable)view completion:(nullable MBProgressHUDCompletionBlock)completionBlock;
    
+ (void)showHitMessage:(NSString *_Nullable)hitMessage;
+ (void)showHitMessage:(NSString *_Nullable)hitMessage yOffset:(CGFloat)yOffset;
+ (void)showHitMessage:(NSString *_Nullable)hitMessage toView:(UIView *_Nullable)view;
+ (void)showHitMessage:(NSString *_Nullable)hitMessage toView:(UIView *_Nullable)view yOffset:(CGFloat)yOffset;
    
+ (nonnull MBProgressHUD *)showMessage;
+ (nonnull MBProgressHUD *)showMessage:(NSString *_Nullable)message;
+ (nonnull MBProgressHUD *)showMessageToView:(UIView *_Nullable)view;
+ (nonnull MBProgressHUD *)showMessage:(NSString *_Nullable)message toView:(UIView *_Nullable)view;
    
+ (void)showAI;
+ (void)showAIYOffset:(CGFloat)yOffset;
+ (void)showAIToView:(UIView *_Nullable)view;
+ (void)showAIToView:(UIView *_Nullable)view enabled:(BOOL)enabled;
+ (void)showAIToView:(UIView *_Nullable)view yOffset:(CGFloat)yOffset;
+ (void)showAIToView:(UIView *_Nullable)view yOffset:(CGFloat)yOffset enabled:(BOOL)enabled;
    
+ (void)hideHUDForView:(UIView *_Nullable)view;
+ (void)hideHUD;
    
+ (nonnull MBProgressHUD *)showCustomView:(UIView *_Nullable)customView toView:(UIView *_Nullable)view;
@end
