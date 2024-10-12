//
//  ConfirmDeleteController.h
//  photomanage
//
//  Created by chenxianming on 2024/5/21.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ConfirmDeleteControllerDelegate <NSObject>
@optional
- (void)confirmDelete:(NSMutableArray<PHAsset *> *)array;
- (void)didPhotoPreviewDeleteCountChange;
@end
@interface ConfirmDeleteController : UIViewController
@property (weak) id<ConfirmDeleteControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *deleteAssetsArray;
@end

NS_ASSUME_NONNULL_END
