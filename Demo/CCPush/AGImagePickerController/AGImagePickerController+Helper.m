//
//  AGImagePickerController+Helper.m
//  AGImagePickerController Demo
//
//  Created by Artur Grigor on 06.02.2013.
//  Copyright (c) 2013 Artur Grigor. All rights reserved.
//

#import "AGImagePickerController.h"
#import "AGImagePickerController+Helper.h"

#import <objc/runtime.h>

@implementation AGImagePickerController (Helper)

#pragma mark - Configuring Rows

- (NSUInteger)numberOfItemsPerRow
{
    if (_pickerFlags.delegateNumberOfItemsPerRowForDevice)
    {
        AGDeviceType deviceType = self.deviceType;
        UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
        
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(agImagePickerController:numberOfItemsPerRowForDevice:andInterfaceOrientation:)]) {
            return [self.delegate agImagePickerController:self numberOfItemsPerRowForDevice:deviceType andInterfaceOrientation:interfaceOrientation];
        }
        return self.defaultNumberOfItemsPerRow;
    } else {
        return self.defaultNumberOfItemsPerRow;
    }
}

- (NSUInteger)defaultNumberOfItemsPerRow
{
    NSUInteger numberOfItemsPerRow = 0;
    
    if (IS_IPAD())
    {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        {
            numberOfItemsPerRow = AGIPC_ITEMS_PER_ROW_IPAD_PORTRAIT;
        } else
        {
            numberOfItemsPerRow = AGIPC_ITEMS_PER_ROW_IPAD_LANDSCAPE;
        }
    } else
    {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        {
            numberOfItemsPerRow = AGIPC_ITEMS_PER_ROW_IPHONE_PORTRAIT;
            
        } else
        {
            numberOfItemsPerRow = AGIPC_ITEMS_PER_ROW_IPHONE_LANDSCAPE;
        }
    }
    
    return numberOfItemsPerRow;
}

#pragma mark - Configuring Selections

- (AGImagePickerControllerSelectionBehaviorType)selectionBehaviorInSingleSelectionMode
{
    if (_pickerFlags.delegateSelectionBehaviorInSingleSelectionMode)
    {
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(selectionBehaviorInSingleSelectionModeForAGImagePickerController:)]) {
            return [self.delegate selectionBehaviorInSingleSelectionModeForAGImagePickerController:self];
        }
        return SELECTION_BEHAVIOR_IN_SINGLE_SELECTION_MODE;
    } else {
        return SELECTION_BEHAVIOR_IN_SINGLE_SELECTION_MODE;
    }
}

#pragma mark - Appearance Configuration

- (BOOL)shouldDisplaySelectionInformation
{
    if (_pickerFlags.delegateShouldDisplaySelectionInformationInSelectionMode)
    {
        AGImagePickerControllerSelectionMode selectionMode = self.selectionMode;
        
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(agImagePickerController:shouldDisplaySelectionInformationInSelectionMode:)]) {
            return [self.delegate agImagePickerController:self shouldDisplaySelectionInformationInSelectionMode:selectionMode];
        }
        return SHOULD_DISPLAY_SELECTION_INFO;
    } else {
        return SHOULD_DISPLAY_SELECTION_INFO;
    }
}

- (BOOL)shouldShowToolbarForManagingTheSelection
{
    if (_pickerFlags.delegateShouldShowToolbarForManagingTheSelectionInSelectionMode)
    {
        AGImagePickerControllerSelectionMode selectionMode = self.selectionMode;
        
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(agImagePickerController:shouldShowToolbarForManagingTheSelectionInSelectionMode:)]) {
            return [self.delegate agImagePickerController:self shouldShowToolbarForManagingTheSelectionInSelectionMode:selectionMode];
        }
        return SHOULD_SHOW_TOOLBAR_FOR_MANAGING_THE_SELECTION;
    } else {
        return SHOULD_SHOW_TOOLBAR_FOR_MANAGING_THE_SELECTION;
    }
}

#pragma mark - Others

- (AGDeviceType)deviceType
{
    return (IS_IPAD() ? AGDeviceTypeiPad : AGDeviceTypeiPhone);
}

#pragma mark - Drawing: Item

- (CGRect)itemRect
{
    CGPoint topLeftPoint = self.itemTopLeftPoint;
    CGSize sizeOfItem = self.itemSize;
    
    return CGRectMake(topLeftPoint.x, topLeftPoint.y, sizeOfItem.width, sizeOfItem.height);
}

- (CGPoint)itemTopLeftPoint
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat width = bounds.size.width;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        if (bounds.size.width < bounds.size.height) {
            width = bounds.size.height;
        }
    }
    
    CGFloat x = 0, y = 0;
    
    x = (width - (self.numberOfItemsPerRow * self.itemSize.width)) / (self.numberOfItemsPerRow + 1);
    y = x;
    return CGPointMake(floor(x), floor(y));
}

- (CGSize)itemSize
{
    static CGSize _gSize;
    if (0 == _gSize.width || 0 == _gSize.height) {
        if (AGDeviceTypeiPad == self.deviceType) {
            _gSize = AGIPC_ITEM_SIZE_PAD;
            _gSize.width = _gSize.width*(self.screenWidth/768);
            _gSize.height = _gSize.width;
        } else {
            _gSize = AGIPC_ITEM_SIZE;
            _gSize.width = _gSize.width*(self.screenWidth/320);
            _gSize.height = _gSize.width;
        }
    }
    return _gSize;
}

- (CGFloat)screenWidth
{
    static CGFloat screenWidth = 0;
    if (0 == screenWidth) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        screenWidth = fmin(screenSize.width, screenSize.height);
    }
    return screenWidth;
}

#pragma mark - Drawing: Checkmark

- (CGRect)checkmarkFrameUsingItemFrame:(CGRect)frame
{
    CGRect checkmarkRect = AGIPC_CHECKMARK_RECT;
    
    return CGRectMake(
                      frame.size.width - checkmarkRect.size.width - checkmarkRect.origin.x,
                      frame.size.height - checkmarkRect.size.height - checkmarkRect.origin.y,
                      checkmarkRect.size.width,
                      checkmarkRect.size.height
                      );
}

@end

@implementation NSInvocation (Addon)

#pragma mark - Invocation

+ (id)invocationWithProtocol:(Protocol *)targetProtocol selector:(SEL)selector andRequiredFlag:(BOOL)isMethodRequired
{
	struct objc_method_description desc;
	desc = protocol_getMethodDescription(targetProtocol, selector, isMethodRequired, YES);
	if (desc.name == NULL)
		return nil;
	
	NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:desc.types];
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
	[inv setSelector:selector];
	return inv;
}

@end
