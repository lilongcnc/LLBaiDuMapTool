//
//  ZYHTBaiDuMapTool.h
//  BusinessAreaPlat
//
//  Created by 李龙 on 16/6/20.
//
//

#import <Foundation/Foundation.h>
#import "ZYHTBaiduMap.h"


typedef NS_ENUM(NSInteger, LLBMKPinAnnotationColor) {
    LLBMKPinAnnotationColorRed = 0,
    LLBMKPinAnnotationColorGreen,
    LLBMKPinAnnotationColorPurple
};

//搜索
typedef void(^searchOptionResultSuccessBlock)(NSArray *BMKPoiInfoArray, BMKSearchErrorCode *error, NSString *errorMsg);
typedef void(^searchOptionResultErrorBlock)(BMKSearchErrorCode *error,NSString *errorMsg);

//地理编码
typedef void(^getGeoCodeResultSuccessBlock)(BMKGeoCodeResult *result, BMKSearchErrorCode *error, NSString *errorMsg);
typedef void(^getGeoCodeResultErrorBlock)(BMKSearchErrorCode *error,NSString *errorMsg);

//反地理编码
typedef void(^getReverseGeoCodeResultSuccessBlock)(BMKReverseGeoCodeResult *result, BMKSearchErrorCode *error, NSString *errorMsg);
typedef void(^getReverseGeoCodeResultErrorBlock)(BMKSearchErrorCode *error,NSString *errorMsg);





typedef void(^didUpdateBMKUserLocationBlock)(BMKUserLocation *userLocation);
typedef void(^didUpdateUserHeadingnBlock)(BMKUserLocation *userLocation);
typedef void(^didFailToLocateUserWithErrorBlock)(NSError *error);
typedef void(^mapViewDidFinishLoadingBlock)(BMKMapView *mapView);


@interface LLBaiDuMapTool : NSObject

/**
 *  初始化BMKMapView相关
 */
- (BMKMapView *)ll_getBMKMapViewWithFrame:(CGRect)myRect setDelegate:(id<BMKMapViewDelegate>)mapDelegate;
-(void)ll_mapViewDidFinishLoading:(mapViewDidFinishLoadingBlock)block;

- (void)addDelegate;
- (void)ll_setDelegateNil;







//-------------------------- 热力图层,路况,卫星图, --------------------------
/**
 *  打开/关闭百度城市热力图图层（百度自有数据）
 *
 *  @param _mapView 已经创建的BMKMapView对象
 */
- (void)ll_openOrCloseBaiduHeatMap:(BMKMapView *)_mapView;

/**
 *  打开/关闭公路路况地图
 *
 *  @param _mapView 已经创建的BMKMapView对象
 */
- (void)ll_openOrCloseBaiduTraffic:(BMKMapView *)_mapView;

/**
 *  打开/关闭卫星模式
 *
 *  @param _mapView 已经创建的BMKMapView对象
 */
- (void)ll_openOrCloseBaiduSatelliteType:(BMKMapView *)_mapView;









//-------------------------- 检索相关 --------------------------
/**
 *  周边云检索(对于分页和显示数量参数个人修改)
 *
 *  @param keyWord 关键字
 *  @param center  中心
 *  @param block   回调代码块
 */
@property (nonatomic,assign) int cityPpageIndex;
@property (nonatomic,assign) int cityPageCapacity; //在调用方法前赋值
-(void)ll_doNearBySearchDealWithKey:(NSString *)keyWord andNearByCenter:(CLLocationCoordinate2D)center success:(searchOptionResultSuccessBlock)successBlock error:(searchOptionResultErrorBlock)errorBlock;




/**
 *  本地城市区域内-云检索
 *
 *  @param keyWord 搜索关键字
 *  @param block   回调代码块
 */
@property (nonatomic,assign) int nearByPpageIndex;
@property (nonatomic,assign) int nearByPageCapacity; //在调用方法前赋值
-(void)ll_doCitySearchDealWithKey:(NSString *)keyWord success:(searchOptionResultSuccessBlock)successBlock error:(searchOptionResultErrorBlock)errorBlock;











//-------------------------- 添加大头针相关 --------------------------
/**
 *  默认大头针的颜色
 */
@property (nonatomic,assign) LLBMKPinAnnotationColor pinColor;
/**
 *  是否开启大头针动画
 */
@property (nonatomic,assign) BOOL isShowAnimatesDrop;
/**
 *  大头针图像
 */
@property (nonatomic,copy) NSString *pinImageName;


// 注意: 不能设置UIView然后在代理房中生成BMKActionPaopaoView,会出现只有第一个大头针才有view等等奇葩问题
/**
 *  单个传入大头针自定义视图
 */
@property (nonatomic,strong) BMKActionPaopaoView *paopaoBMKActionPaopaoView;

/**
 *  传入大头针自定义视图
 *  注意:导入数量必须和传入大头针数量相匹配,这个属性建议结合:`ll_addAnnotationArray:toMapView:`一起使用,具体使用参考案例代码
 */
@property (nonatomic,strong) NSArray *paopaoBMKActionPaopaoViewArray;


//移除一组标注
- (void)ll_removeAnimations:(NSArray *)annotationArray fromMapVirew:(BMKMapView *)mapView;
//移除标注
- (void)ll_removeAnimation:(id<BMKAnnotation>)annotation fromMapVirew:(BMKMapView *)mapView;

// 添加大头针数据模型
- (void)ll_addAnnotationWithCoodinate:(CLLocationCoordinate2D)coor withTitle:(NSString *)title andSubTitle:(NSString *)subTitle toMapView:(BMKMapView *)mapView;

//添加大头针模型数组
- (void)ll_addAnnotationArray:(NSArray *)annotationArray toMapView:(BMKMapView *)mapView;



//-------------------------- 地理编码和反地理编码 --------------------------
/**
 *  地理编码
 *
 *  @param cityStr      城市
 *  @param addressStr   地区
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 */
- (void)ll_geoCodeSearchWithCity:(NSString *)cityStr withAddress:(NSString *)addressStr success:(getGeoCodeResultSuccessBlock)successBlock error:(getGeoCodeResultErrorBlock)errorBlock;

/**
 *  反地理编码
 *
 *  @param cllocationCoordinate2D 地理位置
 *  @param successBlock           成功回调
 *  @param errorBlock             反地理回调
 */
- (void)ll_reverseGeoCodeSearchWith:(CLLocationCoordinate2D)cllocationCoordinate2D success:(getReverseGeoCodeResultSuccessBlock)successBlock error:(getReverseGeoCodeResultErrorBlock)errorBlock;






//-------------------------- 开启定位 --------------------------
//开始执行定位
- (void)ll_startUserLocationService;
//关闭定位
- (void)ll_stopUserLocationService;
//设置定位相关配置
- (void)ll_setUserLocationServiceConfig;

//定位更新block(可以根据实际需求选择实现)
-(void)ll_didUpdateBMKUserLocation:(didUpdateBMKUserLocationBlock)block;

-(void)ll_didUpdateUserHeadingn:(didUpdateUserHeadingnBlock)block;

-(void)ll_didFailToLocateUserWithError:(didFailToLocateUserWithErrorBlock)block;












//-------------------------- 缩放和放大地图 --------------------------
- (void)ll_addZoomLevelWithChangeNumber:(int)changeNumber;
- (void)ll_reduceZoomLevelWithChangeNumber:(int)changeNumber;











//-------------------------- 和导航相关 --------------------------
/**
 *  根据两点经纬度进行导航
 *
 *  @param begin 开始坐标
 *  @param end   结束坐标
 */
- (void)startNaviWithBeginCoor:(CLLocationCoordinate2D)begin endCoor:(CLLocationCoordinate2D)end;

@end
