//
//  ViewController.m
//  LLBaiDuMapManager
//
//  Created by 李龙 on 16/7/29.
//  Copyright © 2016年 李龙. All rights reserved.
//

#import "ViewController.h"
#import "Constant.h"
#import "MyUtility.h"
#import "ZYHTBaiduMap.h"
#import "LLBaiDuMapManager.h"
#import "CustomBuddleView.h"


//DEBUG  模式下打印日志,当前行 并弹出一个警告
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line: %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif

@interface ViewController ()
{
    BMKMapView *_mapView;
}


@property (nonatomic,strong) UILabel *myTipLabel;
@property (nonatomic,strong) UILabel *myTipLabel2;

@end

@implementation ViewController

// 百度地图SDK中提供了定位功能和动画效果，v2.0.0版本开始使用OpenGL渲染，因此您需要在您的Xcode工程中引入CoreLocation.framework和QuartzCore.framework、OpenGLES.framework、SystemConfiguration.framework、CoreGraphics.framework、Security.framework。添加方式：在Xcode的Project -> Active Target ->Build Phases ->Link Binary With Libraries，添加这几个framework即可。
// 在TARGETS->Build Settings->Other Linker Flags 中添加-ObjC。
// 引入mapapi.bundle资源文件
// 引入头文件

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    [[LLBaiDuMapManager sharedInstance] ll_setDelegateNil];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[LLBaiDuMapManager sharedInstance] addDelegate];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self createMapView];
    [self createBtns];
    [self createCoverTips];
}


- (void)createMapView
{
    
    _mapView = [[LLBaiDuMapManager sharedInstance] ll_getBMKMapViewWithFrame:CGRectMake(0, 100, kScreenWidth, kScreenHeight - 100) setDelegate:nil];
    //加载地图完成
    [[LLBaiDuMapManager sharedInstance] ll_mapViewDidFinishLoading:^(BMKMapView *mapView) {
        
        ULog(@"BMKMapView控件初始化完成");
    }];
    [self.view addSubview:_mapView];
    
    [[LLBaiDuMapManager sharedInstance] ll_setUserLocationServiceConfig];
    [[LLBaiDuMapManager sharedInstance] ll_startUserLocationService];
    [[LLBaiDuMapManager sharedInstance] ll_didUpdateBMKUserLocation:^(BMKUserLocation *userLocation) {
        NSLog(@"%s %f,long %f",__FUNCTION__,userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
        NSString *updateLocation = [NSString stringWithFormat:@"userLocation: %f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
        _myTipLabel.text = updateLocation;
        
    }];
    
    [[LLBaiDuMapManager sharedInstance] ll_didUpdateUserHeadingn:^(BMKUserLocation *userLocation) {
        NSLog(@"%s heading is %@",__FUNCTION__,userLocation.heading);
        NSString *headingLocation = [NSString stringWithFormat:@"%@",userLocation.heading];
        _myTipLabel2.text = headingLocation;
    }];
}


//定位
- (void)localButtonOnClick{
    [[LLBaiDuMapManager sharedInstance] ll_startUserLocationService];
}


//放大地图
- (void)jiaBtnOnClick{
    [[LLBaiDuMapManager sharedInstance] ll_addZoomLevelWithChangeNumber:1];
}

//缩放地图
- (void)jianBtnOnClick{
    
    [[LLBaiDuMapManager sharedInstance] ll_reduceZoomLevelWithChangeNumber:1];
}






//搜索地址
- (void)searchPalce
{
    NSLog(@"%s",__FUNCTION__);
    
    
    
    //城市区域搜索配置信息
    [LLBaiDuMapManager sharedInstance].cityPageCapacity = 3; //设置显示搜索结果的数量
    
    //城市搜索(还可以是附近搜索):
    [[LLBaiDuMapManager sharedInstance] ll_doCitySearchDealWithKey:@"河北" success:^(NSArray *BMKPoiInfoArray, BMKSearchErrorCode *error, NSString *errorMsg) {
        
        int index = 0;
        for (BMKPoiInfo *item in BMKPoiInfoArray) {
            NSLog(@"%s  %@---%@",__FUNCTION__,item.name,item.address);
        }
        
        //添加大头针配置参数
        [LLBaiDuMapManager sharedInstance].isShowAnimatesDrop = YES;
        [LLBaiDuMapManager sharedInstance].pinImageName = @"weibo-lan";
        [LLBaiDuMapManager sharedInstance].pinColor = BMKPinAnnotationColorGreen;
        
        //********************* 添加大头针方式一 *********************
        for (BMKPoiInfo *poi in BMKPoiInfoArray) {
            
            CustomBuddleView *customer = [[CustomBuddleView alloc]initWithFrame:CGRectMake(0, 0, 220, 125)];
            customer.customerName = [NSString stringWithFormat:@"----->%d",index];
            
            [LLBaiDuMapManager sharedInstance].paopaoBMKActionPaopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:
                                                         customer];
            
//            [[LLBaiDuMapManager sharedInstance] ll_addAnnotationWithCoodinate:CLLocationCoordinate2DMake(poi.pt.latitude, poi.pt.
//                                                                                      longitude) withTitle:poi.name andSubTitle:poi.city toMapView:_mapView];
            
            [[LLBaiDuMapManager sharedInstance] ll_addAnnotationWithCoodinate:CLLocationCoordinate2DMake(poi.pt.latitude, poi.pt.
                                                                                                         longitude) withTitle:@"111111" andSubTitle:@"222222" toMapView:_mapView];
            
            index++;
        }
        
        
        //********************* 添加大头针方式二 *********************
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
        //        [LLBaiDuMapManager sharedInstance].paopaoBMKActionPaopaoViewArray = tempArray;
        
        //        // 移除之前的大头针
        //        [[LLBaiDuMapManager sharedInstance] ll_removeAnimations:_mapView.annotations fromMapVirew:_mapView];
        //
        //        // 添加到地图上
        //        [[LLBaiDuMapManager sharedInstance] ll_addAnnotationArray:array toMapView:_mapView];
        
        ULog(@"大头标签在河北呢,请缩小比例尺之后查看河北全境.大头针也可以点击哦~~~");

    } error:^(BMKSearchErrorCode *error, NSString *errorMsg) {
        
        
    }];
}

//地理编码
- (void)geocoderAction
{
    
    NSLog(@"%s",__FUNCTION__);
    
    [[LLBaiDuMapManager sharedInstance] ll_geoCodeSearchWithCity:@"上海市" withAddress:@"田子坊" success:^(BMKGeoCodeResult *result, BMKSearchErrorCode *error, NSString *errorMsg) {
        
        
        ULog(@"解析地址\"上海-田子坊\"完成,请缩小比例尺之后查看上海.大头针也可以点击哦~~~");
        
        // 移除之前的大头针
        [[LLBaiDuMapManager sharedInstance] ll_removeAnimations:_mapView.annotations fromMapVirew:_mapView];
        // 添加大头针
        [[LLBaiDuMapManager sharedInstance] ll_addAnnotationWithCoodinate:CLLocationCoordinate2DMake(result.location.latitude, result.location.longitude)
                                             withTitle:result.address
                                           andSubTitle:nil
                                             toMapView:_mapView];
        
        
    } error:^(BMKSearchErrorCode *error, NSString *errorMsg) {
        ULog(@"解析地址异常");
        
    }];
}

//反地理编码
- (void)reverseGeocoderAction
{
    
    NSLog(@"%s",__FUNCTION__);
    
//    (latitude = 31.214260914625513, longitude = 121.47498064783355)
//    乌镇: 东经120°54′,北纬30°64′
    
    CLLocationCoordinate2D cllocationCoordinate2D  = (CLLocationCoordinate2D){30.5, 120.5};
    
    [[LLBaiDuMapManager sharedInstance] ll_reverseGeoCodeSearchWith:cllocationCoordinate2D success:^(BMKReverseGeoCodeResult *result, BMKSearchErrorCode *error, NSString *errorMsg) {
        
        ULog(@"乌镇(30.54,120.5)-> 反地理编码成功 -> 周边检索成功,结果为:%@-%@",result.addressDetail.province,result.addressDetail.city);
        //TODO 这里可以直接进行周边查询
        
    } error:^(BMKSearchErrorCode *error, NSString *errorMsg) {
        ULog(@"反地理编码异常:%@",errorMsg);

    }];
}


// 是否打开热力图
- (void)heatMapAction
{
//    NSLog(@"%s",__FUNCTION__);
    [[LLBaiDuMapManager sharedInstance] ll_openOrCloseBaiduHeatMap:_mapView];
    ULog(@"打开了热力图");

}

// 是否打开交通路况
- (void)trafficAction
{
//    NSLog(@"%s",__FUNCTION__);
    [[LLBaiDuMapManager sharedInstance] ll_openOrCloseBaiduTraffic:_mapView];
    ULog(@"打开了交通状况图");
    
}

// 卫星图切换
- (void)mapTypeAction
{
//    NSLog(@"%s",__FUNCTION__);
    ULog(@"卫星图切换");
    [[LLBaiDuMapManager sharedInstance] ll_openOrCloseBaiduSatelliteType:_mapView];
}



//周边查询
- (void)nearAction{
    
    CLLocationCoordinate2D cllocationCoordinate2D  = (CLLocationCoordinate2D){30.5, 120.5};
    //发起周边检索
    [[LLBaiDuMapManager sharedInstance] ll_doNearBySearchDealWithKey:@"乌镇" andNearByCenter:cllocationCoordinate2D success:^(NSArray *BMKPoiInfoArray, BMKSearchErrorCode *error, NSString *errorMsg) {
//            NSLog(@"%s  %@",__FUNCTION__,BMKPoiInfoArray);
        ULog(@"乌镇(30.54,120.5)-> 周边检索成功,结果为:%@",BMKPoiInfoArray);
        
    } error:^(BMKSearchErrorCode *error, NSString *errorMsg) {
//            NSLog(@"%s  %@",__FUNCTION__,errorMsg);
        ULog(@"乌镇(30.54,120.5)-> 周边检索失败:%@",errorMsg);
        
    }];

    
}

#pragma mark ================ BMKRouteSearch:公交/开车/步行线路:未封装 ================
////公交线路
//- (void)metroAction
//{
//    
//    NSLog(@"%s",__FUNCTION__);
//    
//    //初始化检索对象
//    BMKRouteSearch *routeSearch = [[BMKRouteSearch alloc]init];
//    routeSearch.delegate = self;
//    
//    //发起检索
//    BMKPlanNode* start = [[BMKPlanNode alloc] init] ;
//    start.name = @"上地七街";
//    BMKPlanNode* end = [[BMKPlanNode alloc] init];
//    end.name = @"上地三街";
//    BMKTransitRoutePlanOption *transitRouteSearchOption = [[BMKTransitRoutePlanOption alloc]init];
//    transitRouteSearchOption.city= @"北京市";
//    transitRouteSearchOption.from = start;
//    transitRouteSearchOption.to = end;
//    BOOL flag = [routeSearch transitSearch:transitRouteSearchOption];
//    
//    if(flag)
//    {
//        NSLog(@"bus检索发送成功");
//    }
//    else
//    {
//        NSLog(@"bus检索发送失败");
//    }
//}
//
//#pragma mark - BMKRouteSearchDelegate
//-(void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKTransitRouteResult*)result
//                     errorCode:(BMKSearchErrorCode)error
//{
//    
//    
//    NSLog(@"%s",__FUNCTION__);
//    
//    if (error == BMK_SEARCH_NO_ERROR) {
//        //在此处理正常结果
//        
//        for (BMKTransitRouteLine *line in result.routes) {
//            //            ///路线长度 单位： 米
//            //            @property (nonatomic) int distance;
//            //            ///路线耗时 单位： 秒
//            //            @property (nonatomic, strong) BMKTime* duration;
//            //            ///路线起点信息
//            //            @property (nonatomic, strong) BMKRouteNode* starting;
//            //            ///路线终点信息
//            //            @property (nonatomic, strong) BMKRouteNode* terminal;
//            NSString *routeDescription = [NSString stringWithFormat:@"路程长度: %d\n路线耗时: %d小时%d分%d秒", line.distance, line.duration.hours, line.duration.minutes, line.duration.seconds];
//            NSLog(@"%@", routeDescription);
//        }
//    }
//    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
//        //当路线起终点有歧义时通，获取建议检索起终点
//        //result.routeAddrResult
//    }
//    else {
//        NSLog(@"抱歉，未找到结果");
//    }
//}






#pragma mark ================ UI部分 ================

- (void)createCoverTips{
    
    UIView *tipView = [[UIView alloc] initWithFrame:(CGRect){kScreenWidth-210,kScreenHeight-105,200,90}];
    tipView.backgroundColor = [UIColor whiteColor];
    _myTipLabel = ({
        UILabel *label = [MyUtility createLabelWithFrame:(CGRect){10,10,tipView.frame.size.width-20,35} title:@"- 未显示 -" font:[UIFont systemFontOfSize:12.00]];
        label.numberOfLines = 0;
        label.textColor = [UIColor blackColor];
        [tipView addSubview:label];
        label;
    });
    _myTipLabel2 = ({
        UILabel *label = [MyUtility createLabelWithFrame:(CGRect){10,_myTipLabel.frame.origin.y+35+10,tipView.frame.size.width-20,35} title:@"- 未显示 -" font:[UIFont systemFontOfSize:12.00]];
        label.numberOfLines = 0;
        label.textColor = [UIColor blackColor];
        [tipView addSubview:label];
        label;
    });
    
    [self.view addSubview:tipView];
}


- (void)createBtns
{
    UIButton *addSearchButton = [MyUtility createButtonWithFrame:CGRectMake(10, 30, 60, 20) title:@"搜地址" backgroundImageName:nil target:self action:@selector(searchPalce)];
    UIButton *geocoderButton = [MyUtility createButtonWithFrame:CGRectMake(80, 30, 60, 20) title:@"解析" backgroundImageName:nil target:self action:@selector(geocoderAction)];
    UIButton *reverseGeocoderButton = [MyUtility createButtonWithFrame:CGRectMake(150, 30, 60, 20) title:@"反解析" backgroundImageName:nil target:self action:@selector(reverseGeocoderAction)];
    UIButton *mapTypeButton = [MyUtility createButtonWithFrame:CGRectMake(220, 30, 60, 20) title:@"卫星图" backgroundImageName:nil target:self action:@selector(mapTypeAction)];
    UIButton *trafficButton = [MyUtility createButtonWithFrame:CGRectMake(10, 60, 60, 20) title:@"路况" backgroundImageName:nil target:self action:@selector(trafficAction)];
    UIButton *heatMapButton = [MyUtility createButtonWithFrame:CGRectMake(80, 60, 60, 20) title:@"热力图" backgroundImageName:nil target:self action:@selector(heatMapAction)];
    UIButton *nearByButton = [MyUtility createButtonWithFrame:CGRectMake(150, 60, 60, 20) title:@"周边查询" backgroundImageName:nil target:self action:@selector(nearAction)];
//    UIButton *metroButton = [MyUtility createButtonWithFrame:CGRectMake(150, 60, 60, 20) title:@"公交" backgroundImageName:nil target:self action:@selector(metroAction)];
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
//    [self.view addSubview:metroButton];
    [self.view addSubview:nearByButton];
    [self.view addSubview:localButton];
    [self.view addSubview:jiajian];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
