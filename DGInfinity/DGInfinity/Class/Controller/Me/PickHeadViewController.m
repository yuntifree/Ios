//
//  PickHeadViewController.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/21.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "PickHeadViewController.h"
#import "UserInfoCGI.h"
#import "PickHeadCell.h"
#import "PickHeadModel.h"
#import "PickHeadSectionHeader.h"

@interface PickHeadViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *_collectionView;
    
    NSMutableArray *_male;
    NSMutableArray *_female;
}
@end

@implementation PickHeadViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _male = [NSMutableArray arrayWithCapacity:3];
        _female = [NSMutableArray arrayWithCapacity:3];
    }
    return self;
}

- (NSString *)title
{
    return @"选择头像";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpSubViews];
    [self getDefHead];
}

- (void)setUpSubViews
{
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(66, 105);
    layout.sectionInset = UIEdgeInsetsMake(8, 56 * (kScreenWidth / 375), 8, 56 * (kScreenWidth / 375));
    
    [_collectionView registerNib:[UINib nibWithNibName:@"PickHeadCell" bundle:nil] forCellWithReuseIdentifier:@"PickHeadCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"PickHeadSectionHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PickHeadSectionHeader"];
}

- (void)getDefHead
{
    [UserInfoCGI getDefHead:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *male = data[@"male"];
                if ([male isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *info in male) {
                        PickHeadModel *model = [PickHeadModel createWithInfo:info];
                        [_male addObject:model];
                    }
                }
                NSArray *female = data[@"female"];
                if ([female isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *info in female) {
                        PickHeadModel *model = [PickHeadModel createWithInfo:info];
                        [_female addObject:model];
                    }
                }
                [_collectionView reloadData];
            }
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (void)modUserHead:(NSString *)headurl
{
    [SVProgressHUD show];
    [UserInfoCGI modUserInfo:@"headurl" value:headurl complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNCModHead object:headurl];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return _male.count;
    } else {
        return _female.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PickHeadCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PickHeadCell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row < _male.count) {
            [cell setPickHeadValue:_male[indexPath.row]];
        }
    } else {
        if (indexPath.row < _female.count) {
            [cell setPickHeadValue:_female[indexPath.row]];
        }
    }
    __weak typeof(self) wself = self;
    cell.HeadTap = ^ (NSString *headurl) {
        [wself modUserHead:headurl];
    };
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    PickHeadSectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PickHeadSectionHeader" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        [header setIcon:@"ico_sex_man"];
    } else {
        [header setIcon:@"ico_sex_woman"];
    }
    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, 44);
}

@end
