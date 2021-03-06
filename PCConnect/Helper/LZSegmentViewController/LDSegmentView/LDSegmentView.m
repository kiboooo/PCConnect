//
//  LDSegmentView.m
//  UIPageViewController-OC
//
//  Created by Artron_LQQ on 2017/2/17.
//  Copyright © 2017年 Artup. All rights reserved.
//

#import "LDSegmentView.h"

@interface LDSegmentView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic, strong) NSMutableArray *dataSources;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, copy) segmentBlock selectBlock;
@end

@implementation LDSegmentView

+ (instancetype)segmentViewWithDatas:(NSArray<NSString *> *)datas {
    
    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:datas.count];
    
    BOOL isDefault = YES;
    for (NSString *str in datas) {
        LDSegmentModel *model = [[LDSegmentModel alloc]init];
        model.title = str;
        model.count = datas.count;
        if (isDefault) {
            model.selected = YES;
            isDefault = NO;
        }
        [tmpArr addObject:model];
    }
    
    LDSegmentView *segment = [[LDSegmentView alloc]init];
    segment.dataSources = [NSMutableArray arrayWithArray:tmpArr];
    
    return segment;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        _selectedColor = [UIColor colorWithRed:253.0/255.0 green:154.0/255.0 blue:17.0/255.0 alpha:1];
        _normalColor = [UIColor colorWithRed:110.0/255.0 green:190.0/255.0 blue:199.0/255.0 alpha:1];
        _fontSize = 15.0;
        [self.collection registerClass:[LDSegmentCell class] forCellWithReuseIdentifier:@"LDSegmentViewCellID"];
    }
    
    return self;
}
- (void)reloadData {
    
    [self.collection reloadData];
}

- (void)selectedIndexWithBlock:(segmentBlock)block {
    
    _selectBlock = block;
}

#pragma mark - setters
- (void)setDatas:(NSArray<NSString *> *)datas {
    _datas = datas;
    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:datas.count];
    
    BOOL isDefault = YES;
    for (NSString *str in datas) {
        LDSegmentModel *model = [[LDSegmentModel alloc]init];
        model.title = str;
        model.fontSize = self.fontSize;
        model.count = self.dataSources.count;
        if (isDefault) {
            model.selected = YES;
            isDefault = NO;
        }
        [tmpArr addObject:model];
    }
    
    self.dataSources = [NSMutableArray arrayWithArray:tmpArr];
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    if (self.datas.count > 0) {
        for (LDSegmentModel *model in self.datas) {
            model.fontSize = fontSize;
        }
    }
}

- (void)setDataSources:(NSMutableArray *)dataSources {
    _dataSources = dataSources;
    [self.collection reloadData];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animation:(BOOL)animation {
    _selectedIndex = selectedIndex;
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    
    [self moveLineToIndexPath:path animation:NO];
    [self.collection scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animation];
    
    for (LDSegmentModel *model in self.dataSources) {
        model.selected = NO;
    }
    
    LDSegmentModel *model = [self.dataSources objectAtIndex:selectedIndex];
    model.selected = YES;
    
    [self.collection reloadData];
    
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self setSelectedIndex:selectedIndex animation:YES];
}
#pragma mark - Getter
- (UIView *)line {
    if (_line == nil) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = _selectedColor;
        
        [self.collection addSubview:_line];
    }
    
    return _line;
}

#pragma mark - UICollectionView & UICollectionViewDelegate & UICollectionViewDataSource
#pragma mark - UICollectionView
- (UICollectionView *)collection {
    if (_collection == nil) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 4;
        UICollectionView *collection = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        
        collection.delegate = self;
        collection.dataSource = self;
        collection.backgroundColor = self.backgroundColor;
        collection.showsVerticalScrollIndicator = NO;
        collection.showsHorizontalScrollIndicator = NO;
        [self addSubview:collection];
        
        _collection = collection;
    }
    
    return _collection;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataSources.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LDSegmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LDSegmentViewCellID" forIndexPath:indexPath];
    
    cell.selectedColor = self.selectedColor;
    cell.normalColor = self.normalColor;
    cell.fontSize = self.fontSize;
    
    LDSegmentModel *model = [self.dataSources objectAtIndex:indexPath.row];
    cell.title = model.title;
    cell.isSelected = model.selected;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath  {
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self setSelectedIndex:indexPath.row animation:YES];
    
    
    // 代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentView:didSelectedIndex:)]) {
        
        [self.delegate segmentView:self didSelectedIndex:indexPath.row];
    }
    // block 回调
    if (self.selectBlock) {
        self.selectBlock(indexPath.row);
    }
}

#pragma mark - UICollectionViewFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LDSegmentModel *model = [self.dataSources objectAtIndex:indexPath.row];
    model.count = self.dataSources.count;
    return CGSizeMake(model.width, kScreenRatio * 50);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 4, 0, 4);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
    [self moveLineToIndexPath:path animation:YES];
}

#pragma mark - 移动横线
- (void)moveLineToIndexPath:(NSIndexPath *)indexPath animation:(BOOL)animation {
    
    LDSegmentCell *cell = (LDSegmentCell *)[self.collection cellForItemAtIndexPath:indexPath];
    
    CGRect lineBounds = self.line.bounds;
    lineBounds.size.width = cell.bounds.size.width;
    
    CGPoint lineCenter = self.line.center;
    lineCenter.x = cell.center.x;
    
    if (animation) {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.line.bounds = lineBounds;
            self.line.center = lineCenter;
        }];
    } else {
        
        self.line.bounds = lineBounds;
        self.line.center = lineCenter;
    }
    
}
#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collection.backgroundColor = self.backgroundColor;
    self.collection.frame = self.bounds;
    
    LDSegmentModel *model = [self.dataSources firstObject];
    model.count = self.dataSources.count;
    self.line.frame = CGRectMake(4, CGRectGetHeight(self.frame) - 2, model.width, 2);
    
    [self setSelectedIndex:self.selectedIndex animation:NO];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

///************************************************************************************************************************************************
#pragma LDSegmentCell
static CGFloat __fontSize;
@interface LDSegmentCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation LDSegmentCell
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:17.0 * kScreenRatio];
        
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}
- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    
    self.titleLabel.textColor = isSelected ? _selectedColor : _normalColor;
}
- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = 17.0 * kScreenRatio;
    
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    __fontSize = 17.0 * kScreenRatio;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _selectedColor = [UIColor colorWithRed:253.0/255.0 green:154.0/255.0 blue:17.0/255.0 alpha:1];
        _normalColor = [UIColor colorWithRed:110.0/255.0 green:190.0/255.0 blue:199.0/255.0 alpha:1];
        _fontSize = 17.0 * kScreenRatio;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.backgroundColor = self.backgroundColor;
    self.titleLabel.frame = self.bounds;
}
@end



@implementation LDSegmentModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _selected = NO;
        _fontSize = 17.0 * kScreenRatio;
    }
    
    return self;
}

- (CGFloat)width {
    if (_width <= 0) {
        if (self.count < 3) {
            CGFloat wid = kScreenWidht / self.count;
            _width = wid;
        } else {
            CGFloat wid = kScreenRatio * 100;
            _width = wid;
        }
    }
    return _width;
}

@end


