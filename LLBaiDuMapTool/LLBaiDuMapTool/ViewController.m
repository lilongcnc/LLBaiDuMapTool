//
//  ViewController.m
//  LLBaiDuMapTool
//
//  Created by 李龙 on 16/7/29.
//  Copyright © 2016年 李龙. All rights reserved.
//

#import "ViewController.h"
#import "Constant.h"
#import "MyUtility.h"
#import "ZYHTBaiduMap.h"
#import "LLBaiDuMapTool.h"
#import "CustomBuddleView.h"



@interface ViewController ()
{
    BMKMapView *_mapView;
}


@property (nonatomic,strong) LLBaiDuMapTool *myBaiDuMapTool;

@end

@implementation ViewController{
    CGFloat screenW;
    CGFloat screenH;
}
// 百度地图SDK中提供了定位功能和动画效果，v2.0.0版本开始使用OpenGL渲染，因此您需要在您的Xcode工程中引入CoreLocation.framework和QuartzCore.framework、OpenGLES.framework、SystemConfiguration.framework、CoreGraphics.framework、Security.framework。添加方式：在Xcode的Project -> Active Target ->Build Phases ->Link Binary With Libraries，添加这几个framework即可。
// 在TARGETS->Build Settings->Other Linker Flags 中添加-ObjC。
// 引入mapapi.bundle资源文件
// 引入头文件

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    [_myBaiDuMapTool ll_setDelegateNil];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_myBaiDuMapTool addDelegate];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    screenW = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    screenH = [UIApplication sharedApplication].keyWindow.bounds.size.height;
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myBaiDuMapTool = [LLBaiDuMapTool new];
    

    [self createMapView];
    [self createBtns];
    //    [self createAnnotations];
    
    
    
    
}

- (void)createMapView
{
    
    _mapView = [_myBaiDuMapTool ll_getBMKMapViewWithFrame:CGRectMake(0, 100, kScreenWidth, kScreenHeight - 100) setDelegate:nil];
    //加载地图完成
    [_myBaiDuMapTool ll_mapViewDidFinishLoading:^(BMKMapView *mapView) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"BMKMapView控件初始化完成" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alert show];
    }];
    [self.view addSubview:_mapView];
    
    [_myBaiDuMapTool ll_setUserLocationServiceConfig];
    [_myBaiDuMapTool ll_startUserLocationService];
    [_myBaiDuMapTool ll_didUpdateBMKUserLocation:^(BMKUserLocation *userLocation) {
        NSLog(@"%s %f,long %f",__FUNCTION__,userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
        
    }];
    
    [_myBaiDuMapTool ll_didUpdateUserHeadingn:^(BMKUserLocation *userLocation) {
        NSLog(@"%s heading is %@",__FUNCTION__,userLocation.heading);
    }];
}

//定位
- (void)localButtonOnClick{
    [_myBaiDuMapTool ll_startUserLocationService];
}



//放大地图
- (void)jiaBtnOnClick{
    [_myBaiDuMapTool ll_addZoomLevelWithChangeNumber:1];
}
//缩放地图
- (void)jianBtnOnClick{
    [_myBaiDuMapTool ll_reduceZoomLevelWithChangeNumber:1];
}


// 是否打开热力图
- (void)heatMapAction
{
    
    NSLog(@"%s",__FUNCTION__);
    [_myBaiDuMapTool ll_openOrCloseBaiduHeatMap:_mapView];
}

// 是否打开路况
- (void)trafficAction
{
    
    NSLog(@"%s",__FUNCTION__);
    [_myBaiDuMapTool ll_openOrCloseBaiduTraffic:_mapView];
    
}

// 地图类型
- (void)mapTypeAction
{
    
    NSLog(@"%s",__FUNCTION__);
    [_myBaiDuMapTool ll_openOrCloseBaiduSatelliteType:_mapView];
}

- (void)metroAction
{
    
    NSLog(@"%s",__FUNCTION__);
    
    //初始化检索对象
    BMKRouteSearch *routeSearch = [[BMKRouteSearch alloc]init];
    routeSearch.delegate = self;
    
    //发起检索
    BMKPlanNode* start = [[BMKPlanNode alloc] init] ;
    start.name = @"上地七街";
    BMKPlanNode* end = [[BMKPlanNode alloc] init];
    end.name = @"上地三街";
    BMKTransitRoutePlanOption *transitRouteSearchOption = [[BMKTransitRoutePlanOption alloc]init];
    transitRouteSearchOption.city= @"北京市";
    transitRouteSearchOption.from = start;
    transitRouteSearchOption.to = end;
    BOOL flag = [routeSearch transitSearch:transitRouteSearchOption];
    
    if(flag)
    {
        NSLog(@"bus检索发送成功");
    }
    else
    {
        NSLog(@"bus检索发送失败");
    }
}

- (void)searchPalce
{
    NSLog(@"%s",__FUNCTION__);
    
    //城市区域搜索配置信息
    _myBaiDuMapTool.cityPageCapacity = 3; //设置显示搜索结果的数量
    
    //城市搜索
    [_myBaiDuMapTool ll_doCitySearchDealWithKey:@"河北" result:^(NSArray *BMKPoiInfoArray, NSString *errorMsg) {
        
        int index = 0;
        for (BMKPoiInfo *item in BMKPoiInfoArray) {
            NSLog(@"%s  %@---%@",__FUNCTION__,item.name,item.address);
        }
        
        
        //添加大头针配置参数
        _myBaiDuMapTool.isShowAnimatesDrop = YES;
        //        _myBaiDuMapTool.pinImageName = @"weibo-lan";
        //        _myBaiDuMapTool.pinColor = BMKPinAnnotationColorGreen;
        
        
        //********************* 添加大头针一 *********************
        for (BMKPoiInfo *poi in BMKPoiInfoArray) {
            
            CustomBuddleView *customer = [[CustomBuddleView alloc]initWithFrame:CGRectMake(0, 0, 220, 125)];
            customer.customerName = [NSString stringWithFormat:@"----->%d",index];
            _myBaiDuMapTool.paopaoBMKActionPaopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:
                                                         customer];
            
            [_myBaiDuMapTool ll_addAnnotationWithCoodinate:CLLocationCoordinate2DMake(poi.pt.latitude, poi.pt.
                                                                                      longitude) withTitle:poi.name andSubTitle:poi.city toMapView:_mapView];
            
            index++;
        }
        
        
        //********************* 添加大头针二 *********************
        //        NSMutableArray *array = [NSMutableArray array];
        //        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:10];
        //        for (BMKPoiInfo *poi in BMKPoiInfoArray) {
        //            // 创建一个大头针对象
        //            BMKPointAnnotation *anno = [[BMKPointAnnotation alloc] init];
        //            anno.coordinate = CLLocationCoordinate2DMake(poi.pt.latitude, poi.pt.longitude);
        //            anno.title = poi.name;
        //            anno.subtitle = poi.city;
        //            [array addObject:anno];
        //
        //            //添加自定义大头针view
        //            CustomBuddleView *customer = [[CustomBuddleView alloc]initWithFrame:CGRectMake(0, 0, 220, 125)];
        //            customer.customerName = [NSString stringWithFormat:@"----->%d",index];
        //            BMKActionPaopaoView *paopaoBMKView = [[BMKActionPaopaoView alloc] initWithCustomView:
        //                                                         customer];
        //            [tempArray addObject:paopaoBMKView];
        //
        //            index++;
        //        }
        //
        //        //设置自定义大头针数组
        //        _myBaiDuMapTool.paopaoBMKActionPaopaoViewArray = tempArray;
        
        //        // 移除之前的大头针
        //        [_myBaiDuMapTool ll_removeAnimations:_mapView.annotations fromMapVirew:_mapView];
        //
        //        // 添加到地图上
        //        [_myBaiDuMapTool ll_addAnnotationArray:array toMapView:_mapView];
        
        
    }];
    
}



- (void)geocoderAction
{
    
    NSLog(@"%s",__FUNCTION__);
    
    BMKGeoCodeSearch *geocoderSearcher =[[BMKGeoCodeSearch alloc]init];
    geocoderSearcher.delegate = self;
    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geoCodeSearchOption.city= @"上海市";
    geoCodeSearchOption.address = @"田子坊";
    BOOL flag = [geocoderSearcher geoCode:geoCodeSearchOption];
    if (flag)
    {
        NSLog(@"geo检索发送成功");
    }
    else
    {
        NSLog(@"geo检索发送失败");
    }
    
}

- (void)reverseGeocoderAction
{
    
    NSLog(@"%s",__FUNCTION__);
    
    //    (latitude = 31.214260914625513, longitude = 121.47498064783355)
    //    乌镇: 东经120°54′,北纬30°64′
    
    BMKGeoCodeSearch *geocoderSearcher =[[BMKGeoCodeSearch alloc]init];
    geocoderSearcher.delegate = self;
    
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){30.5, 120.5};
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [geocoderSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}

- (void)obtainBundleIdentifier
{
    
    NSLog(@"%s",__FUNCTION__);
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSLog(@"%@", bundleIdentifier);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - BMKRouteSearchDelegate
-(void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKTransitRouteResult*)result
                     errorCode:(BMKSearchErrorCode)error
{
    
    
    NSLog(@"%s",__FUNCTION__);
    
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        
        for (BMKTransitRouteLine *line in result.routes) {
            //            ///路线长度 单位： 米
            //            @property (nonatomic) int distance;
            //            ///路线耗时 单位： 秒
            //            @property (nonatomic, strong) BMKTime* duration;
            //            ///路线起点信息
            //            @property (nonatomic, strong) BMKRouteNode* starting;
            //            ///路线终点信息
            //            @property (nonatomic, strong) BMKRouteNode* terminal;
            NSString *routeDescription = [NSString stringWithFormat:@"路程长度: %d\n路线耗时: %d小时%d分%d秒", line.distance, line.duration.hours, line.duration.minutes, line.duration.seconds];
            NSLog(@"%@", routeDescription);
        }
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        //当路线起终点有歧义时通，获取建议检索起终点
        //result.routeAddrResult
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    NSLog(@"%s",__FUNCTION__);
    
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        
        // 创建大头针
        BMKPointAnnotation *anno = [[BMKPointAnnotation alloc] init];
        anno.coordinate = CLLocationCoordinate2DMake(result.location.latitude, result.location.longitude);
        anno.title = result.address;
        
        // 移除之前的大头针
        [_mapView removeAnnotations:_mapView.annotations];
        // 添加到地图上
        [_mapView addAnnotation:anno];
        
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}

// 接收反向地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error {
    
    //
    //    NSLog(@"%s",__FUNCTION__);
    //
    //
    //  if (error == BMK_SEARCH_NO_ERROR) {
    //
    //      // 在此处理正常结果
    //      NSLog(@"%@", result.address);
    //
    //      //发起检索
    //      BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    //      option.pageCapacity = 10;
    //      option.location = result.location;
    //      option.keyword = @"乌镇";
    //      BOOL flag = [_searcher poiSearchNearBy:option];
    //      if (flag)
    //      {
    //          NSLog(@"周边检索发送成功");
    //      }
    //
    //  }
    //  else {
    //      NSLog(@"抱歉，未找到结果");
    //  }
}



- (void)createBtns
{
    UIButton *addSearchButton = [MyUtility createButtonWithFrame:CGRectMake(10, 30, 60, 20) title:@"搜地址" backgroundImageName:nil target:self action:@selector(searchPalce)];
    UIButton *geocoderButton = [MyUtility createButtonWithFrame:CGRectMake(80, 30, 60, 20) title:@"解析" backgroundImageName:nil target:self action:@selector(geocoderAction)];
    UIButton *reverseGeocoderButton = [MyUtility createButtonWithFrame:CGRectMake(150, 30, 60, 20) title:@"反解析" backgroundImageName:nil target:self action:@selector(reverseGeocoderAction)];
    UIButton *mapTypeButton = [MyUtility createButtonWithFrame:CGRectMake(220, 30, 60, 20) title:@"卫星图" backgroundImageName:nil target:self action:@selector(mapTypeAction)];
    UIButton *trafficButton = [MyUtility createButtonWithFrame:CGRectMake(10, 60, 60, 20) title:@"路况" backgroundImageName:nil target:self action:@selector(trafficAction)];
    UIButton *heatMapButton = [MyUtility createButtonWithFrame:CGRectMake(80, 60, 60, 20) title:@"热力图" backgroundImageName:nil target:self action:@selector(heatMapAction)];
    UIButton *metroButton = [MyUtility createButtonWithFrame:CGRectMake(150, 60, 60, 20) title:@"公交" backgroundImageName:nil target:self action:@selector(metroAction)];
    UIButton *localButton = [MyUtility createButtonWithFrame:CGRectMake(15, self.view.frame.size.height-35-50, 45, 45) title:@"" backgroundImageName:@"dingwei2" target:self action:@selector(localButtonOnClick)];
    
    
    UIImageView *jiajian = [[UIImageView alloc]init];
    jiajian.frame = CGRectMake(self.view.frame.size.width - 10 - 40, self.view.frame.size.height - 60 - 50 - 86, 41, 86);
    jiajian.image = [UIImage imageNamed:@"ditu"];
    jiajian.userInteractionEnabled = YES;
    
    
    UIButton *jiaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiaBtn setImage:[UIImage imageNamed:@"jia"] forState:UIControlStateNormal];
    jiaBtn.frame = CGRectMake(0, 0, 41, 43);
    [jiaBtn addTarget:self action:@selector(jiaBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [jiajian addSubview:jiaBtn];
    
    UIButton *jianBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jianBtn setImage:[UIImage imageNamed:@"jian"] forState:UIControlStateNormal];
    jianBtn.frame = CGRectMake(0,42, 41, 43);
    [jianBtn addTarget:self action:@selector(jianBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [jiajian addSubview:jianBtn];
    
    
    [self.view addSubview:addSearchButton];
    [self.view addSubview:geocoderButton];
    [self.view addSubview:reverseGeocoderButton];
    [self.view addSubview:mapTypeButton];
    [self.view addSubview:trafficButton];
    [self.view addSubview:heatMapButton];
    [self.view addSubview:metroButton];
    [self.view addSubview:localButton];
    [self.view addSubview:jiajian];
}




@end
