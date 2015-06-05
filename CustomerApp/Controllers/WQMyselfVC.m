//
//  WQMyselfVC.m
//  CustomerApp
//
//  Created by 邱成西 on 15/5/12.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "WQMyselfVC.h"

#import "WQMainRightCell.h"

#import "JKImagePickerController.h"
#import "WQEditNameVC.h"
#import "WQCustomerOrderVC.h"
#import "WQMessageVC.h"

#import "BlockAlertView.h"
#import "WQLocalDB.h"

@interface WQMyselfVC ()<UITableViewDelegate,UITableViewDataSource,JKImagePickerControllerDelegate,WQEditNameVCDelegate,MBProgressHUDDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, assign) BOOL isNewMessage;

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@end

@implementation WQMyselfVC

-(void)dealloc {
    SafeRelease(_tableView.delegate);
    SafeRelease(_tableView);
    SafeRelease(_hud);
    SafeRelease(_payPalConfig);
    
}

#pragma mark - lifestyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.payPalConfig = [[PayPalConfiguration alloc] init];
    self.payPalConfig.merchantName = [WQDataShare sharedService].storeObj.storeName;
    self.payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    self.payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    self.payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionNone;
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
    self.payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    
    //导航栏
    [self.navBarView setTitleString:NSLocalizedString(@"MyselfVC", @"")];
    [self.navBarView.rightBtn setHidden:YES];
    [self.navBarView.leftBtn setHidden:YES];
    [self.view addSubview:self.navBarView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:@"newMessage" object:nil];
    
    self.isNewMessage = [WQDataShare sharedService].myselfPoint;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [WQAPIClient cancelConnection];
    [self.interfaceTask cancel];
    self.interfaceTask = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newMessage" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - property

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,self.view.width,self.view.height-self.navBarView.height} style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view insertSubview:_tableView belowSubview:self.navBarView];
    }
    return _tableView;
}

-(MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc]initWithView:self.view];
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.animationType = MBProgressHUDAnimationZoom;
        [self.view addSubview:_hud];
    }
    return _hud;
}

#pragma mark - tableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0 && indexPath.row==0) {
        return 70;
    }
    return NavgationHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"classCell";
    
    WQMainRightCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[WQMainRightCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    [cell.headerImageView setHidden:YES];
    
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            [cell.headerImageView setHidden:NO];
            [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Host,[WQDataShare sharedService].userObj.userHead]] placeholderImage:[UIImage imageNamed:@"assets_placeholder_picture"]];
            cell.titleLab.text = NSLocalizedString(@"Header", @"");
        }else if (indexPath.row==1) {
            cell.titleLab.text = NSLocalizedString(@"nickName", @"");
            cell.detailLab.text = [NSString stringWithFormat:@"%@",[WQDataShare sharedService].userObj.userName];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.section==1) {
        cell.titleLab.text = NSLocalizedString(@"customerOrder", @"");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.section==2){
        cell.titleLab.text = NSLocalizedString(@"chatRecodr", @"");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [cell setIsRedPoint:self.isNewMessage];
        
    }
//    else if (indexPath.section==3){
//        cell.titleLab.text = NSLocalizedString(@"paypalAuthorization", @"");
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
    else if (indexPath.section==3){
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = NSLocalizedString(@"LogOut", @"");
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            __block JKImagePickerController *imagePicker = [[JKImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsMultipleSelection = NO;
            imagePicker.minimumNumberOfSelection = 1;
            imagePicker.maximumNumberOfSelection = 1;
            [self presentViewController:imagePicker animated:YES completion:^{
                SafeRelease(imagePicker);
            }];
        }else if (indexPath.row==1) {
            __block WQEditNameVC *imagePicker = [[WQEditNameVC alloc]init];
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:^{
                SafeRelease(imagePicker);
            }];
        }
    }else if (indexPath.section==1) {
        WQCustomerOrderVC *orderVC = [[WQCustomerOrderVC alloc]init];
        [self.navigationController pushViewController:orderVC animated:YES];
        SafeRelease(orderVC);
    }else if (indexPath.section==2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isNewMessage" object:@"-1" userInfo:nil];
        
        if ([[WQDataShare sharedService].messageArray containsObject:[NSString stringWithFormat:@"%ld",[WQDataShare sharedService].storeObj.storeId]]) {
            [[WQDataShare sharedService].messageArray removeObject:[NSString stringWithFormat:@"%ld",[WQDataShare sharedService].storeObj.storeId]];
        }
        
        WQMessageVC *messageVC = [[WQMessageVC alloc]init];
        [self.navigationController pushViewController:messageVC animated:YES];
        SafeRelease(messageVC);
    }
//    else if (indexPath.section==3) {
//        NSSet *scopeValues = [NSSet setWithArray:@[kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeAddress, kPayPalOAuth2ScopePhone]];
//        
//        __block PayPalProfileSharingViewController *profileSharingPaymentViewController = [[PayPalProfileSharingViewController alloc] initWithScopeValues:scopeValues configuration:self.payPalConfig delegate:self];
//        [self.view.window.rootViewController presentViewController:profileSharingPaymentViewController animated:YES completion:^{
//            SafeRelease(profileSharingPaymentViewController);
//        }];
//    }
    else if (indexPath.section==3) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Alert Title" message:NSLocalizedString(@"confirmLogOut", @"")];
        
        [alert setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"") block:nil];
        [alert setDestructiveButtonWithTitle:NSLocalizedString(@"LogOut", @"") block:^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[WQAPIClient sharedClient] POST:@"/rest/login/logout" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                
                [[WQLocalDB sharedWQLocalDB] deleteLocalStroeWithCompleteBlock:nil];
                [[WQLocalDB sharedWQLocalDB] deleteLocalUserWithCompleteBlock:^(BOOL finished) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    if (finished) {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionCookies"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [self.appDel.xmppManager goOffline];
                        [self.appDel.xmppManager teardownStream];
                        self.appDel.xmppManager = nil;
                        [WQDataShare sharedService].userObj = nil;
                        [WQDataShare sharedService].storeObj = nil;
                        
                        [self.appDel showRootVC];
                    }
                }];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
            }];
        }];
        [alert show];
    }
}

#pragma mark - JKImagePickerControllerDelegate

- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets{
    [self.hud show:YES];
    
    __weak typeof(self) weakSelf = self;
    JKAssets *asset = (JKAssets *)assets[0];
    __block UIImage *image = nil;
    ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
    [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            UIImage *tempImg = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
            image = [Utility dealImageData:tempImg];//图片处理
            SafeRelease(tempImg);
        }
    } failureBlock:^(NSError *error) {
        [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"PhotoSelectedError", @"")];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
            [weakSelf saveShopHeaderWithImg:image];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
    }];
}
- (void)imagePickerControllerDidCancel:(JKImagePickerController *)imagePicker {
    [imagePicker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - WQEditNameVCDelegate
- (void)editNameVCDidChange:(WQEditNameVC *)editNameVC {
    WQMainRightCell *cell = (WQMainRightCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.detailLab.text = editNameVC.nameTxt.text;
    
    [WQDataShare sharedService].userObj.userName = editNameVC.nameTxt.text;
    
    [editNameVC dismissViewControllerAnimated:YES completion:^{
        
        [[WQLocalDB sharedWQLocalDB] saveUserDataToLocal:[WQDataShare sharedService].userObj completeBlock:^(BOOL finished) {
        }];
    }];
}
- (void)editNameVCDidCancel:(WQEditNameVC *)editNameVC {
    [editNameVC dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - 上传图像：头像、店铺logo
-(void)saveShopHeaderWithImg:(UIImage *)image {
    self.hud.mode = MBProgressHUDModeDeterminate;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"https://120.24.64.85:8443/rest/img/uploadHeader" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1)  name:@"imgFile" fileName:@"imgFile.jpeg" mimeType:@"image/jpeg"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    NSProgress *progress = nil;
    
    self.uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        [progress removeObserver:self forKeyPath:@"fractionCompleted"];
        [self.hud hide:YES];
        [self.hud removeFromSuperview];
        self.hud = nil;
        if (!error) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *jsonData=(NSDictionary *)responseObject;
                
                if ([[jsonData objectForKey:@"status"]integerValue]==1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        WQMainRightCell *cell = (WQMainRightCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cell.headerImageView.image = image;
                        
                        NSDictionary *aDic = (NSDictionary *)[jsonData objectForKey:@"returnObj"];
                        
                        [WQDataShare sharedService].userObj.userHead = [aDic objectForKey:@"img"];
                        
                        [[WQLocalDB sharedWQLocalDB] saveUserDataToLocal:[WQDataShare sharedService].userObj completeBlock:^(BOOL finished) {
                        }];
                    });
                }else {
                    [WQPopView showWithImageName:@"picker_alert_sigh" message:[jsonData objectForKey:@"msg"]];
                }
            }
        }else {
            [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"InterfaceError", @"")];
        }
    }];
    [self.uploadTask resume];
    
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hud.progress = progress.fractionCompleted;
        });
        
    }
}

-(void)newMessage:(NSNotification *)notification  {
    self.isNewMessage = [[notification object] boolValue];
    
    [self.tableView reloadData];
}


#pragma mark PayPalProfileSharingDelegate methods

- (void)payPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController
             userDidLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization {
    
    [profileSharingViewController dismissViewControllerAnimated:YES completion:^{
        [self sendProfileSharingAuthorizationToServer:profileSharingAuthorization];
    }];
}

- (void)userDidCancelPayPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController {
    [profileSharingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendProfileSharingAuthorizationToServer:(NSDictionary *)authorization {
    // TODO: Send authorization to server
    NSLog(@"Here is your authorization:\n\n%@\n\nSend this to your server to complete profile sharing setup.", authorization);
}



@end
