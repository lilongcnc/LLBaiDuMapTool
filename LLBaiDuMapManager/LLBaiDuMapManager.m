//
//  ZYHTBaiDuMapTool.m
//  BusinessAreaPlat
//
//  Created by 李龙 on 16/6/20.
//
//

#import "LLBaiDuMapManager.h"
#import "CustomBuddleView.h"


@interface LLBaiDuMapManager()
//<BMKPoiSearchDelegate>//, BNNaviRoutePlanDelegate
<BMKPoiSearchDelegate,BMKMapViewDelegate, BMKPoiSearchDelegate, BMKRouteSearchDelegate, BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate>

@property (nonatomic, strong) BMKPoiSearch *mySearch;

@property (nonatomic,strong) BMKMapView *myMapView;

@property (nonatomic,strong) BMKLocationService *myLocalSever;


//搜索
@property (nonatomic, copy) searchOptionResultSuccessBlock searchOptionSuccessBlock;
@property (nonatomic, copy) searchOptionResultErrorBlock searchOptionErrorBlock;

//地理编码
@property (nonatomic, copy) getGeoCodeResultSuccessBlock getGeoCodeSuccessBlock;
@property (nonatomic, copy) getGeoCodeResultErrorBlock getGeoCodeErrorBlock;

//反地理编码
@property (nonatomic, copy) getReverseGeoCodeResultSuccessBlock getReverseGeoCodeSuccessBlock;
@property (nonatomic, copy) getReverseGeoCodeResultErrorBlock getReverseGeoCodeErrorBlock;


@property (nonatomic, copy) didUpdateBMKUserLocationBlock localblock;
@property (nonatomic, copy) didUpdateUserHeadingnBlock headingblock;
@property (nonatomic, copy) didFailToLocateUserWithErrorBlock localFailedblock;
@property (nonatomic,copy) mapViewDidFinishLoadingBlock mapViewFinshblock;

@end


@implementation LLBaiDuMapManager{
    int showBMKViewIndex;
}

ILSingleton_M

#pragma mark - 代理相关
- (void)ll_setDelegateNil{
    _myMapView.delegate = nil; // 不用时，置nil
    self.myLocalSever.delegate = nil;
    _mySearch.delegate = nil;
}

- (void)addDelegate{
     _myMapView.delegate = self;
}

#pragma mark - 懒加载
- (BMKLocationService *)myLocalSever
{
    if (!_myLocalSever) {
        _myLocalSever = [[BMKLocationService alloc] init];
        //定位精确度，精确度越高越耗电
        _myLocalSever.desiredAccuracy = kCLLocationAccuracyBest;
        //定位的更新频率，单位为米
        _myLocalSever.distanceFilter = kCLDistanceFilterNone;
    }
    return _myLocalSever;
}

- (BMKPoiSearch *)search
{
    if (!_mySearch) {
        //初始化检索对象
        _mySearch = [[BMKPoiSearch alloc] init];
        _mySearch.delegate = self;
    }
    return _mySearch;
}


- (BMKMapView *)ll_getBMKMapViewWithFrame:(CGRect)myRect setDelegate:(id<BMKMapViewDelegate>)mapDelegate{
    if (!_myMapView) {
        _myMapView = [[BMKMapView alloc] initWithFrame:myRect];
    }
    return _myMapView;
}


-(void)ll_mapViewDidFinishLoading:(mapViewDidFinishLoadingBlock)block{
    _mapViewFinshblock = block;
}



#pragma mark ================ 和定位相关 ================
//设置定位相关配置
- (void)ll_setUserLocationServiceConfig{
    _myMapView.showsUserLocation = YES;//显示定位图层 显示定位的蓝点儿
    /**
     BMKUserTrackingModeNone = 0,             /// 普通定位模式
     BMKUserTrackingModeFollow,               /// 定位跟随模式
     BMKUserTrackingModeFollowWithHeading,    /// 定位罗盘模式
     */
    _myMapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    
    //定位三角标识下的蓝色圆圈
    BMKLocationViewDisplayParam* para=[[BMKLocationViewDisplayParam alloc]init];
    para.locationViewOffsetX=0;
    para.locationViewOffsetY=0;
    para.isAccuracyCircleShow=NO;
    para.isRotateAngleValid=YES;
    _myMapView.hidden=NO;
    [_myMapView updateLocationViewWithParam:para];
    
    
}

//开始
- (void)ll_startUserLocationService{

    if(!self.myLocalSever.delegate){
        NSLog(@"----------------------- 设置定位代理 -----------------------");
        self.myLocalSever.delegate = self;
    }
    
    //启动LocationService
    _myMapView.zoomLevel=15;
    
    [self.myLocalSever startUserLocationService];
}

//停止
- (void)ll_stopUserLocationService{
    //启动LocationService
    [self.myLocalSever stopUserLocationService];
}

//-------- BMKLocationServiceDelegate:  实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    NSLog(@"heading is %@",userLocation.heading);
    if (_headingblock)
        _headingblock(userLocation);
//        [_mapView updateLocationData:userLocation];
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [self.myLocalSever stopUserLocationService];
    
    if (_localblock)
        _localblock(userLocation);
    
    
    [_myMapView updateLocationData:userLocation]; //出现定位点
    
    //必须延迟执行,否则能把地图放到到定位点
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setMapRegionWithCoordinate:userLocation.location.coordinate];
    });
    
}

//定位失败后，会调用此函数
- (void)didFailToLocateUserWithError:(NSError *)error
{
    if (_localFailedblock)
        _localFailedblock(error);
    
    
    //默认处理
    NSLog(@"%s",__FUNCTION__);
    NSString *errorMessage;
    if ([error code] == kCLErrorDenied)
    {
        NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
        NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
        errorMessage = [NSString stringWithFormat: @"您的访问被拒绝，请开启定位:设置 > 隐私 > 位置 > 定位服务 下 %@应用",appName];
    }
    else  if ([error code] == kCLErrorLocationUnknown)
    {
        errorMessage = @"无法定位到你的位置!";
    }
    UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:nil  message:errorMessage
                                                    delegate:self  cancelButtonTitle:@"确定"  otherButtonTitles:nil];
    [alert show];
}



//传入经纬度,将baiduMapView 锁定到以当前经纬度为中心点的显示区域和合适的显示范围
- (void)setMapRegionWithCoordinate:(CLLocationCoordinate2D)theCoordinate
{
    NSLog(@"%f---%f",theCoordinate.latitude,theCoordinate.longitude);
    BMKCoordinateRegion region = BMKCoordinateRegionMake(theCoordinate, BMKCoordinateSpanMake(0.05, 0.05));//越小地图显示越详细
    [_myMapView setRegion:region animated:YES];//执行设定显示范围
    [_myMapView setCenterCoordinate:theCoordinate animated:YES];//根据提供的经纬度为中心原点 以动画的形式移动到该区域
}

-(void)ll_didUpdateUserHeadingn:(didUpdateUserHeadingnBlock)block{
    _headingblock = block;
}

-(void)ll_didUpdateBMKUserLocation:(didUpdateBMKUserLocationBlock)block{
    _localblock = block;
}

-(void)ll_didFailToLocateUserWithError:(didFailToLocateUserWithErrorBlock)block{
    _localFailedblock = block;
}












#pragma mark ================ 缩小和放大地图 ================

- (void)ll_addZoomLevelWithChangeNumber:(int)changeNumber{
    _myMapView.zoomLevel += changeNumber;
}

- (void)ll_reduceZoomLevelWithChangeNumber:(int)changeNumber{
    _myMapView.zoomLevel -= changeNumber;
    
}







#pragma mark ================ 热力地图,交通信息,卫星图 ================
-(void)ll_openOrCloseBaiduHeatMap:(BMKMapView *)_mapView{
     (_mapView.baiduHeatMapEnabled == 1)? (_mapView.baiduHeatMapEnabled = 0): (_mapView.baiduHeatMapEnabled = 1);
}

- (void)ll_openOrCloseBaiduTraffic:(BMKMapView *)_mapView{
    (_mapView.trafficEnabled == 1)? (_mapView.trafficEnabled = 0): (_mapView.trafficEnabled = 1);
}

- (void)ll_openOrCloseBaiduSatelliteType:(BMKMapView *)_mapView{
    /*
     BMKMapTypeStandard   = 1,               ///< 标准地图
     BMKMapTypeSatellite  = 2
     */
   (_mapView.mapType == 1)? (_mapView.mapType = 2): (_mapView.mapType = 1);
}







#pragma mark ================ 搜索之城市搜索 ================
-(void)ll_doCitySearchDealWithKey:(NSString *)keyWord  success:(searchOptionResultSuccessBlock)successBlock error:(searchOptionResultErrorBlock)errorBlock{
    
    _searchOptionSuccessBlock = successBlock;
    _searchOptionErrorBlock = errorBlock;
    
    
    NSLog(@"城市检索");
    BMKCitySearchOption* cityOption=[[BMKCitySearchOption alloc]init];
    cityOption.keyword = keyWord;
    cityOption.pageIndex = _cityPpageIndex?_cityPpageIndex:0;
    cityOption.pageCapacity = _cityPageCapacity?_cityPageCapacity:10;
    BOOL flag = [self.search poiSearchInCity:cityOption];
    
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        self.searchOptionErrorBlock(nil,@"周边检索发送失败");
    }

}


#pragma mark ================ 搜索之周边搜索 ================
-(void)ll_doNearBySearchDealWithKey:(NSString *)keyWord andNearByCenter:(CLLocationCoordinate2D)center success:(searchOptionResultSuccessBlock)successBlock error:(searchOptionResultErrorBlock)errorBlock{
    
    
    _searchOptionSuccessBlock = successBlock;
    _searchOptionErrorBlock = errorBlock;
    
    NSLog(@"周边检索");
    //发起检索
    BMKNearbySearchOption *nearOption = [[BMKNearbySearchOption alloc]init];
    
    nearOption.pageIndex = _nearByPpageIndex?_nearByPpageIndex:0;
    nearOption.pageCapacity = _nearByPageCapacity?_nearByPageCapacity:10;
    nearOption.location = center;
    nearOption.keyword = keyWord;
    BOOL flag = [self.search poiSearchNearBy:nearOption];
    
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        if (_searchOptionErrorBlock)
            _searchOptionErrorBlock(nil,@"周边检索发送失败");
    }
}

#pragma mark - BMKPoiSearchDelegate
/**
 *  实现PoiSearchDeleage处理回调结果
 *
 *  @param searcher      poi搜索
 *  @param poiResultList 搜索结果
 *  @param error         错误吗
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        if (_searchOptionSuccessBlock)
            _searchOptionSuccessBlock(poiResultList.poiInfoList,&error,@"成功搜索到结果");
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        if (_searchOptionErrorBlock)
            _searchOptionErrorBlock(&error,@"起始点有歧义");
        
    } else {
        if (_searchOptionErrorBlock)
            _searchOptionErrorBlock(&error,@"抱歉，未找到结果");
    }
}


















#pragma mark ================ 大头针操作 ================
//移除数组内所有的大头针标注
- (void)ll_removeAnimations:(NSArray *)annotationArray fromMapVirew:(BMKMapView *)mapView{
    [mapView removeAnnotations:annotationArray];
}

//移除单个大头针标注
- (void)ll_removeAnimation:(id<BMKAnnotation>)annotation fromMapVirew:(BMKMapView *)mapView{
    [mapView removeAnnotation:annotation];
}

//增加一个大头针
- (void)ll_addAnnotationWithCoodinate:(CLLocationCoordinate2D)coor withTitle:(NSString *)title andSubTitle:(NSString *)subTitle toMapView:(BMKMapView *)mapView
{
    NSLog(@"%s",__FUNCTION__);
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = coor;
    annotation.title = title;
    annotation.subtitle = subTitle;
    [mapView addAnnotation:annotation];
}

//增加一组大头针
- (void)ll_addAnnotationArray:(NSArray *)annotationArray toMapView:(BMKMapView *)mapView
{
    [mapView addAnnotations:annotationArray];
}


#pragma mark - BMKMapViewDelegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    if (_mapViewFinshblock)
        _mapViewFinshblock(mapView);
}

//自定义大头针
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    NSLog(@"%s",__FUNCTION__);
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        
        //        NSLog(@"%s  %@",__FUNCTION__,[annotation title]);
        //        NSLog(@"%s  %@",__FUNCTION__,[annotation subtitle]);
        //        NSLog(@"%s  %@",__FUNCTION__,[annotation coordinate]);
        
            BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
            newAnnotationView.pinColor = _pinColor;
            newAnnotationView.animatesDrop = _isShowAnimatesDrop;// 设置该标注点动画显示
            if (_pinImageName != nil && ![_pinImageName isEqualToString:@""]) {
                newAnnotationView.image = [UIImage imageNamed:_pinImageName];  //把大头针换成别的图片
            }
      
            if(_paopaoBMKActionPaopaoView && !_paopaoBMKActionPaopaoViewArray){
                newAnnotationView.paopaoView = _paopaoBMKActionPaopaoView;
            }else if(!_paopaoBMKActionPaopaoView && _paopaoBMKActionPaopaoViewArray){
                newAnnotationView.paopaoView = _paopaoBMKActionPaopaoViewArray[showBMKViewIndex];
                showBMKViewIndex++;
            }else if(_paopaoBMKActionPaopaoView && _paopaoBMKActionPaopaoViewArray ){
                [NSException raise:@"From LLBaiDuMapTool:mapView:viewForAnnotation" format:@"Don't set values of `_paopaoBMKActionPaopaoView` and `_paopaoBMKActionPaopaoViewArray` at the same time."];
            }

        
        return newAnnotationView;
    }
    
    return nil;
}










//地理解析
- (void)ll_geoCodeSearchWithCity:(NSString *)cityStr withAddress:(NSString *)addressStr success:(getGeoCodeResultSuccessBlock)successBlock error:(getGeoCodeResultErrorBlock)errorBlock{
    
    _getGeoCodeSuccessBlock = successBlock;
    _getGeoCodeErrorBlock = errorBlock;
    
    
    BMKGeoCodeSearch *geocoderSearcher =[[BMKGeoCodeSearch alloc]init];
    geocoderSearcher.delegate = self;
    
    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geoCodeSearchOption.city= cityStr;
    geoCodeSearchOption.address = addressStr;
    
    BOOL flag = [geocoderSearcher geoCode:geoCodeSearchOption];
    if (flag)
    {
        NSLog(@"geo检索发送成功");
    }
    else
    {
        if (_getGeoCodeErrorBlock)
            self.getGeoCodeErrorBlock(nil,@"geo检索发送失败");
    }
}



//反地理解析
- (void)ll_reverseGeoCodeSearchWith:(CLLocationCoordinate2D)cllocationCoordinate2D success:(getReverseGeoCodeResultSuccessBlock)successBlock error:(getReverseGeoCodeResultErrorBlock)errorBlock{

    _getReverseGeoCodeSuccessBlock = successBlock;
    _getReverseGeoCodeErrorBlock = errorBlock;
    
    
    BMKGeoCodeSearch *geocoderSearcher =[[BMKGeoCodeSearch alloc]init];
    geocoderSearcher.delegate = self;
    
    //发起反向地理编码检索
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = cllocationCoordinate2D;
    BOOL flag = [geocoderSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        if (_getReverseGeoCodeErrorBlock)
            _getReverseGeoCodeErrorBlock(nil,@"反geo检索发送失败");
    }
}

#pragma mark - 地理编码和反地理编码: BMKGeoCodeSearchDelegate
//接收地理编码结果
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    NSLog(@"onGetGeoCodeResult: %f---%f",result.location.longitude,result.location.latitude);

    NSLog(@"%s",__FUNCTION__);
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        if (_getGeoCodeSuccessBlock)
            _getGeoCodeSuccessBlock(result,&error,@"成功接收地理编码结果");
    }
    else {
        NSLog(@"抱歉，未找到结果");
        if (_getGeoCodeErrorBlock)
            _getGeoCodeErrorBlock(&error,@"抱歉，未找到结果");
    }
}




// 接收反向地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error {
    

        NSLog(@"%s",__FUNCTION__);


      if (error == BMK_SEARCH_NO_ERROR) {
          // 在此处理正常结果
          NSLog(@"%@", result.address);
          if (self.getReverseGeoCodeSuccessBlock)
              self.getReverseGeoCodeSuccessBlock(result,&error,@"成功接收反向地理编码结果");
          
      }
      else {
          if (self.getReverseGeoCodeErrorBlock)
              self.getReverseGeoCodeErrorBlock(nil,@"抱歉，未找到结果");
      }
}






//发起导航
//- (void)startNaviWithBeginCoor:(CLLocationCoordinate2D)begin endCoor:(CLLocationCoordinate2D)end
//{
//    //节点数组
//    NSMutableArray *nodesArray = [[NSMutableArray alloc]    initWithCapacity:2];
//    
//    //起点
//    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
//    startNode.pos = [[BNPosition alloc] init];
//    startNode.pos.x = begin.longitude;
//    startNode.pos.y = begin.latitude;
//    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
//    [nodesArray addObject:startNode];
//    
//    //终点
//    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
//    endNode.pos = [[BNPosition alloc] init];
//    endNode.pos.x = end.longitude;
//    endNode.pos.y = end.latitude;
//    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
//    [nodesArray addObject:endNode];
//    //发起路径规划
//    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
//}




//#pragma mark - //算路成功回调
//-(void)routePlanDidFinished:(NSDictionary *)userInfo
//{
//    NSLog(@"算路成功");
//    
//    //路径规划成功，开始导航
//    [BNCoreServices_UI showNaviUI: BN_NaviTypeReal delegete:nil isNeedLandscape:YES];
//}


@end
