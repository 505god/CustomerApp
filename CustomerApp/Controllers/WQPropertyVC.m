//
//  WQPropertyVC.m
//  CustomerApp
//
//  Created by 邱成西 on 15/5/17.
//  Copyright (c) 2015年 邱成西. All rights reserved.
//

#import "WQPropertyVC.h"

#import "BlockAlertView.h"

#import "WQTapImg.h"
#import "TextStepperField.h"

#define ColorTag 1000
#define SizeTag 100

@interface WQPropertyVC ()<WQNavBarViewDelegate,WQTapImgDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) WQTapImg *proImgView;
@property (nonatomic, strong) UILabel *priceLab;
@property (nonatomic, strong) UILabel *stockLab;

@property (nonatomic, strong) NSMutableArray *sizeArray;

@property (nonatomic, strong) TextStepperField *stepBtn;
@end

@implementation WQPropertyVC

-(void)dealloc {
    SafeRelease(_scrollView);
    SafeRelease(_proImgView);
    SafeRelease(_priceLab);
    SafeRelease(_stockLab);
    SafeRelease(_sizeArray);
    SafeRelease(_stepBtn);
}

-(void)leftBtnClickByNavBarView:(WQNavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(WQNavBarView *)navView {
    [Utility checkAlert];
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"confirmSelected", @"") message:[NSString stringWithFormat:NSLocalizedString(@"confirmSelectedPro", @""),self.selectedPro.colorName,self.selectedPro.sizeName,self.selectedPro.number]];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"") block:^{
        [[WQDataShare sharedService].alertArray removeAllObjects];
    }];
    [alert setDestructiveButtonWithTitle:NSLocalizedString(@"Confirm", @"") block:^{
        [[WQDataShare sharedService].alertArray removeAllObjects];
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectedProProperty:)]) {
            [self.delegate selectedProProperty:self.selectedPro];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    [alert show];
    [[WQDataShare sharedService].alertArray addObject:alert];
}

-(void)setViewData {
    
    self.sizeArray = [NSMutableArray array];
    
    self.proImgView = [[WQTapImg alloc]initWithFrame:(CGRect){10,10,60,60}];
    self.proImgView.delegate = self;
    NSArray *imgArray = [self.productObj.proImage componentsSeparatedByString:@"|"];
    self.proImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.proImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Host,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"assets_placeholder_picture"]];
    [self.scrollView addSubview:self.proImgView];
    
    self.priceLab = [[UILabel alloc] initWithFrame:(CGRect){self.proImgView.right+10,20,self.view.width-self.proImgView.right-10,20}];
    self.priceLab.textColor = COLOR(251, 0, 41, 1);
    [self.scrollView addSubview:self.priceLab];
    
    self.stockLab = [[UILabel alloc] initWithFrame:(CGRect){self.proImgView.right+10,self.priceLab.bottom,self.view.width-self.proImgView.right-10,20}];
    [self.scrollView addSubview:self.stockLab];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:(CGRect){10,self.proImgView.bottom+10,self.view.width-20,20}];
    label1.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"AddProductColor", @"")];
    label1.textColor = [UIColor lightGrayColor];
    label1.font = [UIFont systemFontOfSize:15];
    [self.scrollView addSubview:label1];
    
    
    CGFloat x = 10;
    CGFloat y = label1.bottom+5;
    for (int i=0; i<self.productObj.proImgArray.count; i++) {
        NSDictionary *aDic = (NSDictionary *)self.productObj.proImgArray[i];
        
        UIButton *btn = [self returnButton];
        if (self.view.width-x<120) {
            x = 10;
            y += 45;
        }
        btn.frame = (CGRect){x,y,120,40};
        x += 120+10;
        
        [btn setTitle:[aDic objectForKey:@"proColorName"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = [[aDic objectForKey:@"proColorId"]integerValue]+ColorTag;
        
        if ([[aDic objectForKey:@"proColorId"]integerValue]==self.selectedPro.colorId) {
            [btn setSelected:YES];
        }
        [self.scrollView addSubview:btn];
    }
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:(CGRect){10,y+50,self.view.width-20,20}];
    label2.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"SelectedProSize", @"")];
    label2.textColor = [UIColor lightGrayColor];
    label2.font = [UIFont systemFontOfSize:15];
    [self.scrollView addSubview:label2];
    
    x = 10;
    y = label2.bottom+5;
    CGFloat MAX = -1;
    for (int i=0; i<self.productObj.proImgArray.count; i++) {
        NSDictionary *aDic = (NSDictionary *)self.productObj.proImgArray[i];
        
        BOOL isExit = NO;
        if ([[aDic objectForKey:@"proColorId"]integerValue]==self.selectedPro.colorId) {
            isExit = YES;
        }
        NSArray *array = (NSArray *)[aDic objectForKey:@"proSizeArray"];
        for (int j=0; j<array.count; j++) {
            NSDictionary *dic = (NSDictionary *)array[j];
            
            if ([self.sizeArray containsObject:[dic objectForKey:@"productSizeId"]]) {
                if (isExit) {
                    UIButton *btnI = (UIButton *)[self.scrollView viewWithTag:([[dic objectForKey:@"productSizeId"]integerValue] + SizeTag)];
                    btnI.enabled = YES;
                }
            }else {
                [self.sizeArray addObject:[dic objectForKey:@"productSizeId"]];
                
                UIButton *btn = [self returnButton];
                if (self.view.width-x<120) {
                    x = 10;
                    y += 45;
                }
                btn.frame = (CGRect){x,y,120,40};
                x += 120+10;
                
                [btn setTitle:[dic objectForKey:@"productSizeName"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(selectSize:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = [[dic objectForKey:@"productSizeId"]integerValue]+SizeTag;
                
                
                if (isExit==YES) {
                    btn.enabled = YES;
                    if ([[dic objectForKey:@"productSizeId"]integerValue]==self.proObj.sizeId) {
                        [btn setSelected:YES];
                        
                        self.priceLab.text = [NSString stringWithFormat:@"%@ %@",[Utility returnMoneyWithType:self.productObj.moneyType],[dic objectForKey:@"productPrice"]];
                        self.stockLab.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"ProductStock", @""),[dic objectForKey:@"productStock"]];
                        
                        MAX = [[dic objectForKey:@"productStock"] integerValue];
                    }
                }else {
                    btn.enabled = NO;
                }
                
                [self.scrollView addSubview:btn];
            }
        }
    }
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:(CGRect){10,y+10,self.view.width-20,20}];
    label3.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"selectedProNumber", @"")];
    [label3 sizeToFit];
    label3.frame = (CGRect){10,y+50,label3.width,20};
    label3.textColor = [UIColor lightGrayColor];
    label3.font = [UIFont systemFontOfSize:15];
    [self.scrollView addSubview:label3];
    
    self.stepBtn = [[TextStepperField alloc]initWithFrame:(CGRect){10,label3.bottom+5,155,30}];
    self.stepBtn.Current = self.selectedPro.number;
    
    if (MAX>0) {
        self.stepBtn.Maximum = MAX;
    }
    
    self.stepBtn.Minimum=1;
    self.stepBtn.NumDecimals =3;
    self.stepBtn.IsEditableTextField=FALSE;
    [self.stepBtn addTarget:self
                     action:@selector(programmaticallyCreatedStepperDidStep:)
           forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.stepBtn];
    
    [self.scrollView setContentSize:CGSizeMake(self.view.width, self.stepBtn.bottom+20)];
    SafeRelease(label1);
    SafeRelease(label2);
    SafeRelease(label3);
}

-(UIButton *)returnButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:COLOR(130, 134, 137, 1) forState:UIControlStateHighlighted];
    [btn setTitleColor:COLOR(130, 134, 137, 1) forState:UIControlStateDisabled];
    [btn setTitleColor:COLOR(251, 0, 41, 1) forState:UIControlStateSelected];
    
    [btn setBackgroundColor:COLOR(244, 242, 242, 1)];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.layer.cornerRadius = 4;
    btn.layer.masksToBounds = YES;
    return btn;
}
#pragma mark - lifestyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航栏
    [self.navBarView setTitleString:NSLocalizedString(@"SelectedProperty", @"")];
    [self.navBarView.rightBtn setImage:[UIImage imageNamed:@"saveAct"] forState:UIControlStateNormal];
    [self.navBarView.rightBtn setImage:[UIImage imageNamed:@"saveNor"] forState:UIControlStateHighlighted];
    [self.navBarView.rightBtn setImage:[UIImage imageNamed:@"saveNor"] forState:UIControlStateDisabled];
    self.navBarView.rightBtn.enabled = NO;
    self.navBarView.navDelegate = self;
    [self.view addSubview:self.navBarView];
    
    self.selectedPro = [[WQSelectedProObj alloc]init];
    if (self.proObj) {
        self.selectedPro.colorId = self.proObj.colorId;
        self.selectedPro.colorName = self.proObj.colorName;
        self.selectedPro.sizeId = self.proObj.sizeId;
        self.selectedPro.sizeName = self.proObj.sizeName;
        self.selectedPro.number = self.proObj.number;
    }else {
        self.selectedPro.colorId = -1;
        self.selectedPro.sizeId = -1;
        self.selectedPro.number = 1;
    }
    
    [self setViewData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)checkRightBtn {
    if (self.proObj) {
        if (self.selectedPro.colorId>=0 && self.selectedPro.sizeId>=0 && self.selectedPro.number>0) {
            if (self.selectedPro.colorId!=self.proObj.colorId || self.selectedPro.sizeId!=self.proObj.sizeId || self.selectedPro.number!=self.proObj.number) {
                self.navBarView.rightBtn.enabled = YES;
            }else {
                self.navBarView.rightBtn.enabled = NO;
            }
        }else {
            self.navBarView.rightBtn.enabled = NO;
        }
    }else {
        if (self.selectedPro.colorId>=0 && self.selectedPro.sizeId>=0 && self.selectedPro.number>0) {
            self.navBarView.rightBtn.enabled = YES;
        }else {
            self.navBarView.rightBtn.enabled = NO;
        }
    }
}
#pragma mark - property
-(UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,self.view.width,self.view.height-self.navBarView.height}];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)tappedWithObject:(id) sender {
    [Utility showImage:self.proImgView];
}

-(void)selectColor:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    self.priceLab.text = @"";
    self.stockLab.text = @"";
    
    if (btn.selected) {
        [btn setSelected:NO];
        
        self.selectedPro.colorId = -1;
        self.selectedPro.sizeId = -1;
        
        for (int k=0; k<self.sizeArray.count; k++) {
            NSInteger sizeId = [self.sizeArray[k] integerValue];
            UIButton *btnSize = (UIButton *)[self.scrollView viewWithTag:(SizeTag+sizeId)];
            [btnSize setSelected:NO];
            [btnSize setEnabled:NO];
        }
        [self checkRightBtn];
    }else {
        for (int i=0; i<self.productObj.proImgArray.count; i++) {
            NSDictionary *aDic = (NSDictionary *)self.productObj.proImgArray[i];
            
            NSInteger colorId = [[aDic objectForKey:@"proColorId"]integerValue];
            
            if ((btn.tag-ColorTag)==colorId) {
                [btn setSelected:YES];
                self.selectedPro.colorId = colorId;
                self.selectedPro.colorName = [aDic objectForKey:@"proColorName"];
                self.selectedPro.sizeId = -1;
                
                [self checkRightBtn];
                
                [self.proImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Host,[aDic objectForKey:@"productImg"]]]];
                
                for (int k=0; k<self.sizeArray.count; k++) {
                    NSInteger sizeId = [self.sizeArray[k] integerValue];
                    
                    UIButton *btnSize = (UIButton *)[self.scrollView viewWithTag:(SizeTag+sizeId)];
                    [btnSize setSelected:NO];
                    [btnSize setEnabled:NO];
                    
                    NSArray *array = (NSArray *)[aDic objectForKey:@"proSizeArray"];
                    for (int j=0; j<array.count; j++) {
                        NSDictionary *dic = (NSDictionary *)array[j];
                        
                        if ([[dic objectForKey:@"productSizeId"]integerValue]==sizeId) {
                            [btnSize setEnabled:YES];
                        }
                    }
                }
            }else {
                UIButton *btnOther = (UIButton *)[self.scrollView viewWithTag:(ColorTag+colorId)];
                [btnOther setSelected:NO];
            }
        }
    }
}

-(void)selectSize:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        [btn setSelected:NO];
        
        self.selectedPro.sizeId = -1;
        
        self.priceLab.text = @"";
        self.stockLab.text = @"";
        
        [self checkRightBtn];
    }else {
        for (int k=0; k<self.sizeArray.count; k++) {
            NSInteger sizeId = [self.sizeArray[k] integerValue];
            UIButton *btnSize = (UIButton *)[self.scrollView viewWithTag:(SizeTag+sizeId)];
            [btnSize setSelected:NO];
        }
        
        [btn setSelected:YES];
        self.selectedPro.sizeId = btn.tag-SizeTag;
        
        for (int i=0; i<self.productObj.proImgArray.count; i++) {
            NSDictionary *aDic = (NSDictionary *)self.productObj.proImgArray[i];
            
            NSInteger colorId = [[aDic objectForKey:@"proColorId"]integerValue];
            
            if (self.selectedPro.colorId == colorId) {
                NSArray *array = (NSArray *)[aDic objectForKey:@"proSizeArray"];
                for (int j=0; j<array.count; j++) {
                    NSDictionary *dic = (NSDictionary *)array[j];
                    
                    NSInteger sizeId = [[dic objectForKey:@"productSizeId"]integerValue];
                    if (sizeId == self.selectedPro.sizeId) {
                        self.selectedPro.sizeName = [dic objectForKey:@"productSizeName"];
                        
                        self.priceLab.text = [NSString stringWithFormat:@"%@ %@",[Utility returnMoneyWithType:self.productObj.moneyType],[dic objectForKey:@"productPrice"]];
                        self.stockLab.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"ProductStock", @""),[dic objectForKey:@"productStock"]];
                        
                        self.stepBtn.Maximum = [[dic objectForKey:@"productStock"] integerValue];
                        
                        if ((NSInteger)self.stepBtn.Current > [[dic objectForKey:@"productStock"] integerValue]) {
                            self.stepBtn.Current = [[dic objectForKey:@"productStock"] floatValue];
                            self.selectedPro.number = [[dic objectForKey:@"productStock"] integerValue];
                        }
                        
                        
                        [self checkRightBtn];
                        break;
                    }
                }
                
                break;
            }
        }
    }
}

- (void)programmaticallyCreatedStepperDidStep:(TextStepperField *)stepper {
    if (stepper.TypeChange == TextStepperFieldChangeKindNegative) {
        self.selectedPro.number --;
    }
    else {
        self.selectedPro.number ++;
    }
}
@end
