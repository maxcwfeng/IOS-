//
//  AJPhotoGroupCell.m
//  AJPhotoPicker
//
//  Created by AlienJunX on 15/11/2.
//  Copyright (c) 2015 AlienJunX
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "AJPhotoGroupCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AJPhotoGroupCell()
@property (nonatomic, strong) PHCollection *assetsGroup;
@property (nonatomic, weak) UIImageView *groupImageView;
@property (nonatomic, weak) UILabel *groupTextLabel;
@end


@implementation AJPhotoGroupCell

- (void)bind:(PHAssetCollection *)assetsGroup{
    self.assetsGroup = assetsGroup;
    self.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    if (self.groupImageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 5, 50, 50)];
        [self.contentView addSubview:imageView];
        self.groupImageView = imageView;
    }
    
    if (self.groupTextLabel == nil) {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, self.bounds.size.height/2-10, [UIScreen mainScreen].bounds.size.width-70, 20)];
        textLabel.font = [UIFont systemFontOfSize:15];
        textLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:textLabel];
        self.groupTextLabel = textLabel;
    }
    
    PHFetchOptions *fetchOption = [[PHFetchOptions alloc] init];
    fetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    fetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetsGroup options:fetchOption];
    
    NSString *title = assetsGroup.localizedTitle;
    if([assetsGroup.localizedTitle isEqualToString:@"Recents"]) {
        title = @"最近项目";
    }
    
    if([assetsGroup.localizedTitle isEqualToString:@"Recently Deleted"]) {
        title = @"最近项目";
    }
    
    if([assetsGroup.localizedTitle isEqualToString:@"Recents"]) {
        title = @"最近项目";
    }
    
    if([assetsGroup.localizedTitle isEqualToString:@"Recents"]) {
        title = @"最近项目";
    }
    self.groupTextLabel.text = [NSString stringWithFormat:@"%@(%ld)",title, result.count];
    
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = YES;
    imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    [[PHImageManager defaultManager] requestImageForAsset:result.lastObject targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageRequestOptions resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        self.groupImageView.image = image;
    }];
}

@end
