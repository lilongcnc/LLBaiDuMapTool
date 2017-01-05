//
//  LLBaiDuMapGeoCodeSerachTool.m
//  LLBaiDuMapTool
//
//  Created by 李龙 on 17/1/5.
//  Copyright © 2017年 李龙. All rights reserved.
//

#import "LLBaiDuMapGeoCodeSerachTool.h"


@interface LLBaiDuMapGeoCodeSerachTool ()<BMKGeoCodeSearchDelegate>

@property (nonatomic,strong) BMKGeoCodeSearch *myBMKGeoCodeSearch;

@end

@implementation LLBaiDuMapGeoCodeSerachTool

ILSingleton_M

- (BMKGeoCodeSearch *)myBMKGeoCodeSearch
{
    if (!_myBMKGeoCodeSearch) {
        _myBMKGeoCodeSearch = [[BMKGeoCodeSearch alloc] init];
        _myBMKGeoCodeSearch.delegate = self;

    }
    return _myBMKGeoCodeSearch;
}


-(void)setInputCoordinate:(CLLocationCoordinate2D)inputCoordinate{
    _inputCoordinate = inputCoordinate;
    
//    //开始
//    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
//    reverseGeocodeSearchOption.reverseGeoPoint = coordinate;
//    [geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    
}


@end
