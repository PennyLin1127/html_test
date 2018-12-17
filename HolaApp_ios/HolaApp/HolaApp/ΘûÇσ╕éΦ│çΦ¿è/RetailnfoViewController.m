//
//  RetailnfoViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/4/11.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "RetailnfoViewController.h"
#import "SQLiteManager.h"
#import "RetailinfoTableViewCell.h"
#import "URLib.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface RetailnfoViewController ()
{
    CLLocationManager *locationManager;
    BOOL show;
    WhichOfFilter filterType;
    showStoreByWhat loadDataType;
}

@end

@implementation RetailnfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init pickerView
    self.pickView.delegate=self;
    [self.pickView setHidden:YES];
    [self.toolBar setHidden:YES];
    show=YES;
    
    // init pickerView data source
    self.areaPickerArray = [NSArray arrayWithArray:[SQLiteManager getRegionData]];
    NSLog(@"areaPickerArray %lu",(unsigned long)self.areaPickerArray.count);
    
    // init filterType
    filterType=areaFilter;
    
    // init CLLocationManager
    locationManager = [[CLLocationManager alloc] init];
    [self getCurrentLocation];
    
    //註冊 RetailinfoTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:@"RetailinfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    // init mutable
//    self.LineUrlArray=[[NSMutableArray alloc]initWithCapacity:0];
    self.laloDataArray=[[NSMutableArray alloc]initWithCapacity:0];
    self.distances=[[NSMutableArray alloc]initWithCapacity:0];
    self.distancesIndex=[[NSMutableArray alloc]initWithCapacity:0];
    self.firsTimeStoreArray=[[NSMutableArray alloc]initWithCapacity:0];
    
    // 初始經緯度array
    self.tempArray4HolaData=[[NSArray alloc]initWithArray:[SQLiteManager getPositionData]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated{
    
    if (self.currentLocation !=nil) {
        // get laloDataArray data from SQL
        [self getSqlPositionData];
        // get min distances
        [self getMinDistancesAndIndex];
    }
}



-(void)getMinDistancesAndIndex{
    
    for (CLLocation *location in self.laloDataArray) {
        CLLocationDistance distance = [self.currentLocation distanceFromLocation:location];
        NSLog(@"SHOW_DIST: %f", distance);
        NSNumber *num=[NSNumber numberWithDouble:distance];
        [self.distances addObject:num];
    }
    
    for (int i=0; i<self.laloDataArray.count; i++) {
        // 找出陣列最小值->最短距離
        NSNumber *min=[self.distances valueForKeyPath:@"@min.self"];
        // 找出最小值的index
        NSInteger indexValue=[self.distances indexOfObject:min];
        NSNumber *indexNum=[NSNumber numberWithInteger:indexValue+1];
        // 存入最小值的index
        [self.distancesIndex addObject:indexNum];
        // 刪掉目前最小值
        [self.distances removeObjectAtIndex:indexValue];
        // 加入最大值在剛刪除最小值的index
        NSInteger maxVaule=999999;
        NSNumber *maxNum=[NSNumber numberWithInteger:maxVaule];
        [self.distances insertObject:maxNum atIndex:indexValue];
    }
    NSLog(@"self.distanceIndex%@",self.distancesIndex);
    
    //  設定loadDataType tag，有最短距離的distancesIndex次數，才讓tableView data source row讀資料
    if (self.distancesIndex.count!=0) {
        loadDataType=showShortDistanceByGPS;
        
        // 載入最短路徑到tableView data source row讀資料
        
        // 把最短路徑index給SQL -> 吐出全部由近到遠的距離array
        NSArray *temArray=[SQLiteManager getShortestDistanceStoreData:self.distancesIndex];
        // init storeArray4TableView
        self.storeArray4TableView=[[NSMutableArray alloc]initWithArray:temArray];
        [self.tableView reloadData];
        
        // save user default
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:self.storeArray4TableView forKey:@"showAllShortDistanceByGPS"];
        [defaults synchronize];
        
    }else{
        loadDataType=showStoreBySelected;
    }
    
}

#pragma mark - button action

- (IBAction)areaButton:(id)sender {
    filterType=areaFilter;
    loadDataType=showStoreBySelected;
    [self.pickView reloadAllComponents];
    if (show==YES) {
        [self.pickView setHidden:NO];
        [self.toolBar setHidden:NO];
        show=NO;
    }else{
        [self.pickView setHidden:YES];
        [self.toolBar setHidden:YES];
        show=YES;
    }
}


- (IBAction)storeButton:(id)sender {
    filterType=storeFilter;
    loadDataType=showStoreBySelected;
    [self.pickView reloadAllComponents];
    if (show==YES) {
        [self.pickView setHidden:NO];
        [self.toolBar setHidden:NO];
        show=NO;
    }else{
        [self.pickView setHidden:YES];
        [self.toolBar setHidden:YES];
        show=YES;
    }
}


- (IBAction)searchButton:(id)sender {
    loadDataType=showStoreBySelected;
    NSString *empStr=@"";
    
    // GA -- 按搜尋就記
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/store"]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/store"]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
    
    if (self.vchStoreName==empStr||self.vchStoreName==nil)
    {
        // 搜區域
        NSArray *temArray=[SQLiteManager getStoreData:self.areaId];
        // init storeArray4TableView
        self.storeArray4TableView=[[NSMutableArray alloc]initWithArray:temArray];
        [self.tableView reloadData];
    }
    else
    {
        // 搜單一門市
        NSArray *temArray=[SQLiteManager getSingleStoreData:self.storeId];
        // init storeArray4TableView
        self.storeArray4TableView=[[NSMutableArray alloc]initWithArray:temArray];
        [self.tableView reloadData];
        
    }
    
    // 若pickerView沒滾動就按done,default 設定北部地區
    if ([self.areaStr isEqualToString:@"北部地區"]&& self.vchStoreName==nil)
    {
        // 搜區域
        NSArray *temArray=[SQLiteManager getStoreData:@"1"];
        // init storeArray4TableView
        self.storeArray4TableView=[[NSMutableArray alloc]initWithArray:temArray];
        [self.tableView reloadData];
    
    }
    else if ([self.areaStr isEqualToString:@"北部地區"] && self.vchStoreName!=nil)
    {
        // 搜單一門市
        NSArray *temArray=[SQLiteManager getSingleStoreData:self.storeId];
        // init storeArray4TableView
        self.storeArray4TableView=[[NSMutableArray alloc]initWithArray:temArray];
        [self.tableView reloadData];
    }
    self.vchStoreName=nil;
}


- (IBAction)cancelButton:(id)sender {
    [self.pickView setHidden:YES];
    [self.toolBar setHidden:YES];
    show=YES;
}


- (IBAction)doneButton:(id)sender {
    [self.pickView setHidden:YES];
    [self.toolBar setHidden:YES];
    show=YES;
    
    if (filterType==areaFilter)
    {
        // show label text after done
        self.areaLabel.text=self.areaStr;
        self.storeLabel.text=@"";
        
        // 若pickerView沒滾動，default 第一次設北部地區
        if (self.areaLabel.text==nil) {
            self.areaStr=@"北部地區";
            self.areaLabel.text=self.areaStr;
            // 取出北部地區下的店給store picker
            self.firsTimeStoreArray=[NSMutableArray arrayWithArray:[SQLiteManager getStoreData:@"1"]];
            filterType=firstTimeStore;
            
            // 抓取儲存各區域店陣列
            NSArray *temArray=[SQLiteManager getStoreData:@"1"];
            self.storeArray=[[NSMutableArray alloc]init];
            NSString *empStr=@"";
            NSDictionary *empStrDic=@{@"vchStoreName":empStr};
            [self.storeArray addObject:empStrDic];
            [self.storeArray addObjectsFromArray:temArray];

        }
        
    } else if (filterType==storeFilter)
    {
        // show label text after done
        self.areaLabel.text=self.areaStr;
        self.storeLabel.text=self.vchStoreName;
    }
    
}

-(void)callPhone:(UIButton*)sender {
    UIButton *button=sender;

    NSString *TEL=button.titleLabel.text;
    if (TEL.length>16) {
        TEL=[button.titleLabel.text substringToIndex:12];
    }else{
        TEL=button.titleLabel.text;
    }
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",TEL]];
    [[UIApplication sharedApplication] openURL:phoneUrl];
}


- (void)goToMap:(UIButton*)sender {
    UIButton *button=sender;
    
    //獲得緯經度
    self.dblLatitude=[self.storeArray4TableView[button.tag]objectForKey:@"dblLatitude"];
    self.dblLongtitude=[self.storeArray4TableView[button.tag]objectForKey:@"dblLongtitude"];
    
    NSString *laloStr=[NSString stringWithFormat:@"%@,%@",self.dblLatitude,self.dblLongtitude];
    NSString *googleMapStr=[HOLA_STORE_MAP stringByAppendingString:laloStr];
    NSLog(@"googleMapStr %@",googleMapStr);
    NSURL *url=[[NSURL alloc]initWithString:googleMapStr];
    //跳出去連google map
    [[UIApplication sharedApplication]openURL:url];
    
}

-(void)goToLINE:(UIButton*)sender{
    UIButton *button=sender;
    NSString *openLineUrlStr=[self.storeArray4TableView[button.tag]objectForKey:@"vchLine"];

    NSURL *url=[[NSURL alloc]initWithString:openLineUrlStr];
    //跳出去連LINE，加LINE好友
    [[UIApplication sharedApplication]openURL:url];
}


#pragma mark - get location

-(void)getCurrentLocation{
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // 使用者授權狀況
    if ([locationManager respondsToSelector:@selector
         (requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
}

-(void)getSqlPositionData{
    
    // 取出SQL裡所有的經緯度資料，準備來比對
    for (NSDictionary *dic in self.tempArray4HolaData) {
        
        NSString *Lat = [[dic objectForKey:@"dblLatitude"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString* Long = [[dic objectForKey:@"dblLongtitude"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        double Latdouble = [Lat doubleValue];
        double Longdouble = [Long doubleValue];
        
        NSArray *tempArray=[NSArray arrayWithObjects:[[CLLocation alloc]initWithLatitude:Latdouble  longitude:Longdouble],nil];
        [self.laloDataArray addObjectsFromArray:tempArray];
    }
    NSLog(@"laloDataArray %lu",(unsigned long)self.laloDataArray.count);
}

#pragma mark - CLLocationManagerDelegate
// GPS無法取得會到這
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    // 若GPS座標無法取得，請不要跳訊息, 請預設北部地區的全部! ->又改成由北到南全部
    loadDataType=showStoreBySelected;
//    NSString *taipeiStr=@"1";
//    NSArray *temArray=[SQLiteManager getStoreData:taipeiStr];
    
    // save user default
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"showAllShortDistanceByGPS"]==nil) {
        
        // 若第一次開啟，沒有GPS會撈北中南東的店
        NSArray *tempRegionArray=[SQLiteManager getRegionData];
        NSArray *temArray=[SQLiteManager getAllStoreData:tempRegionArray];
        
        // init storeArray4TableView
        self.storeArray4TableView=[[NSMutableArray alloc]initWithArray:temArray];
    }
    
    else{
        // 之後沒有GPS但之前有抓到，顯示之前的
        // init storeArray4TableView
        self.storeArray4TableView=[[NSMutableArray alloc]initWithArray:[defaults objectForKey:@"showAllShortDistanceByGPS"]];
    }
    
        [self.tableView reloadData];
   
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    self.currentLocation = newLocation;
    
    if (self.currentLocation != nil) {
        
        // 目前當下的經緯度
        self.latitudeValue=self.currentLocation.coordinate.latitude;
        self.longitudeValue=self.currentLocation.coordinate.longitude;
        NSLog(@"latitude is %.6f , longitude is %.6f",self.latitudeValue,self.longitudeValue);
        //        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        //        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    // Stop Location Manager - for save power
    [locationManager stopUpdatingLocation];
}

#pragma mark - pickerView dataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (filterType==areaFilter)
    {
        return self.areaPickerArray.count;
    }
    else if (filterType==storeFilter)
    {
        return self.storeArray.count;
    }
    else if (filterType==firstTimeStore)
    {
        return self.storeArray.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (filterType==areaFilter) {
        
        NSString *regionStr=[[self.areaPickerArray objectAtIndex:row]objectForKey:@"vchRegionName"];
        return regionStr;
    }
    else if (filterType==storeFilter)
    {
        
        NSString *storeStr=[[self.storeArray objectAtIndex:row]objectForKey:@"vchStoreName"];
        return storeStr;
    }
    else if (filterType==firstTimeStore)
    {
        NSString *firstTimeStoreStr=[[self.storeArray objectAtIndex:row]objectForKey:@"vchStoreName"];
        return firstTimeStoreStr;
    }
    return nil;
}

#pragma mark - pickerView delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (filterType==areaFilter)
    {
        // 儲存區域名稱，區域代號
        self.areaStr=[[self.areaPickerArray objectAtIndex:row]objectForKey:@"vchRegionName"];
        self.areaId=[[self.areaPickerArray objectAtIndex:row]objectForKey:@"regionId"];
        
        // 抓取儲存各區域店陣列
        NSArray *temArray=[SQLiteManager getStoreData:self.areaId];
        self.storeArray=[[NSMutableArray alloc]init];
        NSString *empStr=@"";
        NSDictionary *empStrDic=@{@"vchStoreName":empStr};
        [self.storeArray addObject:empStrDic];
        [self.storeArray addObjectsFromArray:temArray];
        
        
    }
    else if (filterType==storeFilter)
    {
        // 儲存店名
        self.vchStoreName=[[self.storeArray objectAtIndex:row]objectForKey:@"vchStoreName"];
        // 儲存店id
        self.storeId=[[self.storeArray objectAtIndex:row]objectForKey:@"regionId"];
        NSLog(@"select %@",self.vchStoreName);
    }
    
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   //contect view 高度這邊設133
    return 215;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (loadDataType==showShortDistanceByGPS) {
        
        NSLog(@"distancesIndex.count %lu",(unsigned long)self.distancesIndex.count);
        return self.distancesIndex.count;
        
    }else if (loadDataType==showStoreBySelected){
        
        NSLog(@"storeArray4TableView %lu",(unsigned long)self.storeArray4TableView.count);
        return self.storeArray4TableView.count;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentify=@"Cell";
    
    RetailinfoTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentify];
    
    if (cell==nil) {
        cell=[[RetailinfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    
    NSString *addressStr=@"地址：";
    NSString *phoneStr=@"TEL：";
    
    cell.storeName.text=[self.storeArray4TableView[indexPath.row]objectForKey:@"vchStoreName"];
    
    [cell.telButton setTitle:[self.storeArray4TableView[indexPath.row]objectForKey:@"vchPhone"] forState:UIControlStateNormal];
        
    cell.address.text=[addressStr stringByAppendingString:[self.storeArray4TableView[indexPath.row]objectForKey:@"vchStoreAddress"]];
    NSString *openTime = [self.storeArray4TableView[indexPath.row]objectForKey:@"vchOpenTime"];    
    
    cell.openTimeStrLabel.text=openTime;
    
    // 設定phone button action
    cell.telButton.tag=indexPath.row;
    [cell.telButton addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
    
    // set tag for map button action
    cell.reviewMap.tag=indexPath.row;
    [cell.reviewMap addTarget:self action:@selector(goToMap:) forControlEvents:UIControlEventTouchUpInside];
    
    // 設定LINE出現與否
    NSString *openLineUrlStr=[self.storeArray4TableView[indexPath.row]objectForKey:@"vchLine"];
    if ([openLineUrlStr isEqual:@""]) {
        [cell.openLINE setHidden:YES];
//        [self.LineUrlArray addObject:openLineUrlStr];
    }else{
        [cell.openLINE setHidden:NO];
//        [self.LineUrlArray addObject:openLineUrlStr];
    }
    // 設定LINE button action
    cell.openLINE.tag=indexPath.row;
    [cell.openLINE addTarget:self action:@selector(goToLINE:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

/*
 SQL store data
 NSDictionary *dic = @{@"regionId": regionId, @"vchStoreId":vchStoreId, @"vchStoreName":vchStoreName,@"vchStoreAddress":vchStoreAddress,@"dblLatitude":dblLatitude,@"dblLongtitude":dblLongtitude,@"vchPhone":vchPhone};
 */
@end
