//
//  WQInfoVC.m
//  App
//
//  Created by 邱成西 on 15/2/3.
//  Copyright (c) 2015年 Just Do It. All rights reserved.
//

#import "WQInfoVC.h"
#import "WQInputText.h"
#import "UIView+XD.h"
#import "WQTapImg.h"

#import "JKImagePickerController.h"

@interface WQInfoVC ()<UITextFieldDelegate,WQNavBarViewDelegate,WQTapImgDelegate,JKImagePickerControllerDelegate>

@property (nonatomic, strong) WQTapImg *headerImageView;

@property (nonatomic, strong) UITextField *nameText;
@property (nonatomic, strong) UITextField *codeText;

@property (nonatomic, strong) UITextField *userText;

@property (nonatomic, strong) UITextField *passwordText;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSString *headerImgString;

@end

@implementation WQInfoVC

-(void)leftBtnClickByNavBarView:(WQNavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - lifestyle

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏
    if (self.type==0) {
        [self.navBarView setTitleString:NSLocalizedString(@"addInfo", @"")];
    }else {
        [self.navBarView setTitleString:NSLocalizedString(@"logInPassword", @"")];
    }
    [self.navBarView.rightBtn setHidden:YES];
    self.navBarView.isShowShadow = YES;
    self.navBarView.navDelegate = self;
    [self.view addSubview:self.navBarView];
    
    [self setupInputRectangle];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [WQAPIClient cancelConnection];
    [self.interfaceTask cancel];
    self.interfaceTask = nil;
    
    [self.view endEditing:YES];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - 添加输入框

- (void)setupInputRectangle {
    CGFloat userY = self.navBarView.bottom+20;
    
    CGFloat centerX = [UIScreen mainScreen].bounds.size.width * 0.5;
    WQInputText *inputText = [[WQInputText alloc] init];
    
    if (self.type==0) {
        self.headerImageView = [[WQTapImg alloc]initWithFrame:(CGRect){20,userY,80,80}];
        self.headerImageView.layer.masksToBounds = YES;
        self.headerImageView.delegate = self;
        self.headerImageView.layer.cornerRadius = 6;
        self.headerImageView.image = [UIImage imageNamed:@"assets_placeholder_picture"];
        [self.view addSubview:self.headerImageView];
        
        UILabel *alertLab = [[UILabel alloc]initWithFrame:CGRectZero];
        alertLab.text = NSLocalizedString(@"headerAlert", @"");
        alertLab.font = [UIFont systemFontOfSize:15];
        [alertLab sizeToFit];
        alertLab.frame = (CGRect){self.headerImageView.right+10,userY+40,alertLab.width,alertLab.height};
        [self.view addSubview:alertLab];
        SafeRelease(alertLab);
        
        userY += 100;
        
        self.nameText = [inputText setupWithIcon:@"login_name" textY:userY centerX:centerX point:NSLocalizedString(@"nickName", @"")];
        self.nameText.delegate = self;
        [self.nameText setReturnKeyType:UIReturnKeyNext];
        [self.view addSubview:self.nameText];
        
        userY = self.nameText.bottom+5;
        
        self.codeText = [inputText setupWithIcon:@"login_pwd" textY:userY centerX:centerX point:NSLocalizedString(@"customerCode", @"")];
        self.codeText.delegate = self;
        [self.codeText setReturnKeyType:UIReturnKeyNext];
        [self.view addSubview:self.codeText];
        
        userY = self.codeText.bottom+5;
    }
    
    //帐号
    self.userText = [inputText setupWithIcon:@"login_pwd" textY:userY centerX:centerX point:NSLocalizedString(@"logInPassword", @"")];
    self.userText.delegate = self;
    [self.userText setSecureTextEntry:YES];
    [self.userText setReturnKeyType:UIReturnKeyNext];
    [self.view addSubview:self.userText];
    
    //密码
    CGFloat passwordY = self.userText.bottom + 5;
    self.passwordText = [inputText setupWithIcon:@"login_pwd" textY:passwordY centerX:centerX point:NSLocalizedString(@"confirmPassword", @"")];
    [self.passwordText setReturnKeyType:UIReturnKeyDone];
    [self.passwordText setSecureTextEntry:YES];
    self.passwordText.delegate = self;
    [self.view addSubview:self.passwordText];
    
    //登录
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.width = self.userText.width;
    loginBtn.height = 40;
    loginBtn.x = self.passwordText.left;
    loginBtn.y = self.passwordText.bottom + 20;
    [loginBtn setTitle:NSLocalizedString(@"submit", @"") forState:UIControlStateNormal];
    loginBtn.backgroundColor = COLOR(251, 0, 41, 1);
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitleColor:COLOR(130, 134, 137, 1) forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    SafeRelease(loginBtn);SafeRelease(inputText);
    
    [self.view bringSubviewToFront:self.navBarView];
}
-(void)submit {
    [self.view endEditing:YES];
    [self.hud show:YES];
    
    NSString *msg = @"";
    
    if (self.type==0) {
        if (self.nameText.text.length==0) {
            msg = NSLocalizedString(@"logInNickNameError", @"");
        }else if (self.codeText.text.length==0) {
            msg = NSLocalizedString(@"logInCodeError", @"");
        }else if (self.userText.text.length==0) {
            msg = NSLocalizedString(@"logInPasswordError", @"");
        }else if (![self.userText.text isEqualToString:self.passwordText.text]){
            msg = NSLocalizedString(@"confirmPasswordError", @"");
        }
        
        if (msg.length>0) {
            [WQPopView showWithImageName:@"picker_alert_sigh" message:msg];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }else {
            [self resignUser];
        }
        
    }else {
        if (self.userText.text.length==0) {
            msg = NSLocalizedString(@"logInPasswordError", @"");
        }else if (![self.userText.text isEqualToString:self.passwordText.text]){
            msg = NSLocalizedString(@"confirmPasswordError", @"");
        }
        
        if (msg.length>0) {
            [WQPopView showWithImageName:@"picker_alert_sigh" message:msg];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }else {
            self.interfaceTask = [[WQAPIClient sharedClient] POST:@"/rest/login/resetUserPassword" parameters:@{@"userPhone":self.phoneNumber,@"userPassword":self.passwordText.text} success:^(NSURLSessionDataTask *task, id responseObject) {
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *jsonData=(NSDictionary *)responseObject;
                    
                    if ([[jsonData objectForKey:@"status"]integerValue]==1) {
                        [self.appDel showRootVC];
                    }else {
                        [WQPopView showWithImageName:@"picker_alert_sigh" message:[jsonData objectForKey:@"msg"]];
                    }
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"InterfaceError", @"")];
            }];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.type==0) {
        CGRect frame = self.headerImageView.frame;
        if (frame.origin.y == self.navBarView.bottom+20) {
            [UIView animateWithDuration:0.25 animations:^{
                for (UIView *view in self.view.subviews) {
                    if ([view isKindOfClass:[WQNavBarView class]]) {
                        
                    }else {
                        CGRect frame = view.frame;
                        frame.origin.y -= 40;
                        view.frame = frame;
                    }
                }
            }];
        }
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.type==0) {
        CGRect frame = self.headerImageView.frame;
        if (frame.origin.y == self.navBarView.bottom-20) {
            [UIView animateWithDuration:0.25 animations:^{
                for (UIView *view in self.view.subviews) {
                    if ([view isKindOfClass:[WQNavBarView class]]) {
                        
                    }else {
                        CGRect frame = view.frame;
                        frame.origin.y += 40;
                        view.frame = frame;
                    }
                }
            }];
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameText) {
        return [self.codeText becomeFirstResponder];
    }if (textField == self.codeText) {
        return [self.userText becomeFirstResponder];
    }else if (textField == self.userText) {
        return [self.passwordText becomeFirstResponder];
    } else {
        return [self.passwordText resignFirstResponder];
    }
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)tappedWithObject:(id) sender {
    __block JKImagePickerController *imagePicker = [[JKImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsMultipleSelection = NO;
    imagePicker.minimumNumberOfSelection = 1;
    imagePicker.maximumNumberOfSelection = 1;
    [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:^{
        SafeRelease(imagePicker);
    }];
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
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
    }];
    
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        weakSelf.headerImageView.image = image;
        
        [weakSelf saveShopHeaderWithImg:image];
    }];
}
- (void)imagePickerControllerDidCancel:(JKImagePickerController *)imagePicker {
    [imagePicker dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)saveShopHeaderWithImg:(UIImage *)image {
    self.hud.mode = MBProgressHUDModeDeterminate;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"https://120.24.64.85:8443/rest/login/uploadHeader" parameters:@{@"userPhone":self.phoneNumber} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
                    NSDictionary *aDic = (NSDictionary *)[jsonData objectForKey:@"returnObj"];
                    
                    self.headerImgString = [aDic objectForKey:@"img"];
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


-(void)resignUser{
    self.interfaceTask = [[WQAPIClient sharedClient] POST:@"/rest/login/shopUserRegister" parameters:@{@"userPhone":self.phoneNumber,@"userPassword":self.passwordText.text,@"userName":self.nameText.text,@"registerCode":self.codeText.text,@"headerImg":self.headerImgString} success:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonData=(NSDictionary *)responseObject;
            
            if ([[jsonData objectForKey:@"status"]integerValue]==1) {
                [self.appDel showRootVC];
            }else {
                [WQPopView showWithImageName:@"picker_alert_sigh" message:[jsonData objectForKey:@"msg"]];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [WQPopView showWithImageName:@"picker_alert_sigh" message:NSLocalizedString(@"InterfaceError", @"")];
    }];
}



@end
