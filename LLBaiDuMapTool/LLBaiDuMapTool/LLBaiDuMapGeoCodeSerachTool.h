//
//  LLBaiDuMapGeoCodeSerachTool.h
//  LLBaiDuMapTool
//
//  Created by 李龙 on 17/1/5.
//  Copyright © 2017年 李龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYHTBaiduMap.h"
#import "ILSingletom.h"

@interface LLBaiDuMapGeoCodeSerachTool : NSObject

ILSingleton_H

@property (nonatomic,assign) CLLocationCoordinate2D inputCoordinate;


@end
