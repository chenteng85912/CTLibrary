//
//  TJPageController.m
//
//

#import "CTCustomePageController.h"

#define  DEVICE_WIDTH    self.view.frame.size.width

CGFloat const  TITLE_SCALE = 0.2;
CGFloat const  PAGE_HEAD_HEIGHT = 45.0;
CGFloat const  LINE_HEIGHT = 3.0;
CGFloat const  kMoreBtnWidth = 74.0;
NSInteger const MAX_BUTTON_NUMBER = 5;

@interface CTCustomePageController ()<UIScrollViewDelegate>

@property (assign, nonatomic) CGFloat titleBtnWidth;        //标题按钮宽度
@property (assign, nonatomic) CGFloat titleWidth;           //底部线条宽度
@property (strong, nonatomic) UIScrollView *contentScrView; //内容底部滚动视图
@property (strong, nonatomic) UIButton *curruntBtn;         //当前选中按钮
@property (strong, nonatomic) UIView *bottomLine;           //底部线条
@property (copy  , nonatomic) NSArray *RGBSelectedArr;      //按钮选中颜色RGB
@property (copy  , nonatomic) NSArray *RGBNormalArr;        //按钮正常颜色RGB

@end

@implementation CTCustomePageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self p_initUI];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark 界面布局
- (void)p_initUI{
    if (!_viewControllers) {
        return;
    }
    switch (_headBtnStyle) {
        case DefaultButtonView:
            _titleBtnWidth = DEVICE_WIDTH/MIN(_viewControllers.count, MAX_BUTTON_NUMBER);
            break;
        case HeadShowMoreBtnView:
            _titleBtnWidth = (DEVICE_WIDTH-kMoreBtnWidth)/MIN(_viewControllers.count, MAX_BUTTON_NUMBER);
            break;
        case NavigationButtonView:
            _titleBtnWidth = self.headScrView.frame.size.width/_viewControllers.count;
            break;
    }

    if (!_lineHeight) {
        _lineHeight = LINE_HEIGHT;
    }
    if (!_headBtnHeigth) {
        _headBtnHeigth = PAGE_HEAD_HEIGHT;
    }
    if (!_selectedColor) {
        _selectedColor = [UIColor blackColor];
    }
    if (!_normalColor) {
        _normalColor = [UIColor blackColor];
    }
    if (_selectedIndex>_viewControllers.count-1) {
        _selectedIndex = 0;
    }
    if (!_titleFont) {
        _titleFont = [UIFont systemFontOfSize:15];
    }
    //添加头部标题
    if (_headBtnStyle!=NavigationButtonView) {
        [self.view addSubview:self.headScrView];
    }
    for (int i = 0; i <_viewControllers.count; i++) {
        CGFloat btnY = 0;
        if (_isHiddenNav&&UIDevice.currentDevice.systemVersion.floatValue<11.0) {
            btnY = -20;
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(_titleBtnWidth*i, btnY, _titleBtnWidth, _headBtnHeigth)];
        btn.tag = i+100;
        if (_headBtnStyle==NavigationButtonView) {
            btn.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
        }
        [btn addTarget:self action:@selector(p_switchViewControllers:) forControlEvents:UIControlEventTouchUpInside];
        UIViewController *vc = _viewControllers[i];
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:vc.navigationItem.title forState:UIControlStateNormal];
        
        btn.titleLabel.font = _titleFont;
        if (i==_selectedIndex) {
            _curruntBtn = btn;
            [self p_setButScale:_curruntBtn withScale:1];
        }else{
            [btn setTitleColor:_normalColor forState:UIControlStateNormal];
        }
        [self.headScrView addSubview:btn];
        _titleWidth = [self p_strLenth:btn.currentTitle]*(1+TITLE_SCALE);
    }
   
    //添加底部线条
    if (_lineShowMode!=UnDisplayMode) {
      
        UIView *line = [UIView new];
        line.tag = 891101;
        line.backgroundColor = _selectedColor;
        if (_lineShowMode == AboveShowMode) {
            line.frame = CGRectMake(_titleBtnWidth/2-_titleWidth/2, 0, _titleWidth, _lineHeight);
        }else{
            if (_headBtnStyle==NavigationButtonView) {
                line.frame = CGRectMake(_titleBtnWidth/2-_titleWidth/2, _headBtnHeigth-_lineHeight-2, _titleWidth, _lineHeight);
            }else {
                line.frame = CGRectMake(_titleBtnWidth/2-_titleWidth/2, _headBtnHeigth-_lineHeight, _titleWidth, _lineHeight);
            }
        }
        line.layer.masksToBounds = YES;
        line.layer.cornerRadius = 1.0;
        self.bottomLine = line;
        [self.headScrView addSubview:line];
    }

    //添加内容
    [self.view addSubview:self.contentScrView];

    for (UIViewController *vc in _viewControllers) {
        [self addChildViewController:vc];
    }
    
    // 定位到指定位置
    CGPoint offset = self.contentScrView.contentOffset;
    
    offset.x = _selectedIndex * DEVICE_WIDTH;
    [self.contentScrView setContentOffset:offset animated:NO];
    
    [self scrollViewDidEndScrollingAnimation: self.contentScrView];

}

#pragma mark - <UIScrollViewDelegate>

/**
 *  当scrollView进行动画结束的时候会调用这个方法, 例如调用[self.contentScrollView setContentOffset:offset animated:YES];方法的时候
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    CGFloat offsetX = scrollView.contentOffset.x;
    
    NSInteger index = offsetX / width;
    
    _curruntBtn = [self.headScrView viewWithTag:index+100];
    _selectedIndex = index;
    [self p_refreshHeadView:index];
    
    if (self.scrollBlock) {
        self.scrollBlock(index);
    }
    UIViewController *willShowVc = self.childViewControllers[index];
    
    if([willShowVc isViewLoaded]) return;
    
    willShowVc.view.frame = CGRectMake(index * width, 0, width, height);
    
    [scrollView addSubview:willShowVc.view];
    
}

/**
 *  当手指抬起停止减速的时候会调用这个方法
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

/**
 *  scrollView滚动时调用
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat scale = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (scale<0||scale>_viewControllers.count-1) {
        return;
    }
    
    // 获取需要操作的的左边的button
    NSInteger leftIndex = scale;
    UIButton *leftBtn = [self.headScrView viewWithTag:leftIndex+100];
  
    // 获取需要操作的右边的button
    NSInteger rightIndex = scale+1;
    UIButton *rightBtn = (rightIndex == _viewControllers.count) ?  nil : [self.headScrView viewWithTag:rightIndex+100];

    // 右边的比例
    CGFloat rightScale = scale - leftIndex;
    // 左边比例
    CGFloat leftScale = 1- rightScale;
    
    // 设置比例
    [self p_setButScale:leftBtn withScale:leftScale];
    [self p_setButScale:rightBtn withScale:rightScale];
    
    if (_lineShowMode!=UnDisplayMode) {
        UIView *line = (UIView *)[self.headScrView viewWithTag:891101];
        line.center = CGPointMake(_titleBtnWidth*scale+_titleBtnWidth/2, line.center.y);
    }
}


#pragma mark 切换视图控制器
- (void)p_switchViewControllers:(UIButton *)btn{
    if (btn==_curruntBtn) {
        return;
    }
 
    _curruntBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
    
    [_curruntBtn setTitleColor:_normalColor forState:UIControlStateNormal];
    _curruntBtn = [self.headScrView viewWithTag:btn.tag];
    
    _selectedIndex = btn.tag-100;
    if (self.scrollBlock) {
        self.scrollBlock(_selectedIndex);
    }
 
    // 定位到指定位置
    CGPoint offset = self.contentScrView.contentOffset;
    
    offset.x = _selectedIndex * DEVICE_WIDTH;
    [self.contentScrView setContentOffset:offset animated:NO];
    
    [self p_refreshHeadView:btn.tag-100];
    
    // 取出需要显示的控制器
    UIViewController *willShowVc = self.childViewControllers[_selectedIndex];
    if([willShowVc isViewLoaded]) return;
    willShowVc.view.frame = CGRectMake(_selectedIndex * DEVICE_WIDTH, 0, DEVICE_WIDTH, self.contentScrView.frame.size.height);
    [self.contentScrView addSubview:willShowVc.view];
}

- (void)p_refreshHeadView:(NSInteger)index{
    if (_viewControllers.count<=MAX_BUTTON_NUMBER) {
        return;
    }
    CGPoint headOffset = self.headScrView.contentOffset;
    headOffset.x = _titleBtnWidth*MIN(index<2?0:index-2, _viewControllers.count-MAX_BUTTON_NUMBER);
    [self.headScrView setContentOffset:headOffset animated:YES];
}

#pragma mark 设置头部按钮大小渐变
- (void)p_setButScale:(UIButton *)btn withScale:(CGFloat)scale {
    if (![btn isKindOfClass:[UIButton class]]) {
        return;
    }

    CGFloat nred = [self.RGBNormalArr[0] floatValue];
    CGFloat ngreen = [self.RGBNormalArr[1] floatValue];
    CGFloat nblue = [self.RGBNormalArr[2] floatValue];
    
    CGFloat red = [self.RGBSelectedArr[0] floatValue];
    CGFloat green = [self.RGBSelectedArr[1] floatValue];
    CGFloat blue = [self.RGBSelectedArr[2] floatValue];

    // 颜色渐变
    CGFloat red1 = (red-nred)*scale+nred;
    CGFloat green1 = (green-ngreen)*scale+ngreen;
    CGFloat blue1 = (blue-nblue)*scale+nblue;
    [btn setTitleColor:[UIColor colorWithRed:red1 green:green1 blue:blue1 alpha:1.0] forState:UIControlStateNormal];

    // 大小缩放比例
//    CGFloat transformScale = 1 + (scale * TITLE_SCALE);
//    btn.transform = CGAffineTransformMakeScale(transformScale, transformScale);
}

- (CGFloat)p_strLenth:(NSString *)string {
    return [string boundingRectWithSize:CGSizeMake(MAXFLOAT, _headBtnHeigth) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleFont} context:nil].size.width;
}
- (void)switchChildrenVC:(NSInteger)seletedIndex {
    if (seletedIndex<0||seletedIndex>_viewControllers.count-1) {
        return;
    }
    UIButton *btn = [self.headScrView viewWithTag:seletedIndex+100];
    [self p_switchViewControllers:btn];
}
- (void)refreshHeadBtnAndLineColor:(UIColor *)nColor {
    self.selectedColor = nColor;
    self.RGBSelectedArr = nil;
    self.bottomLine.backgroundColor = self.selectedColor;
    [self.curruntBtn setTitleColor:self.selectedColor forState:UIControlStateNormal];
}
#pragma mark ------------------------------------ lazy
- (UIScrollView *)headScrView {
    if (_headScrView==nil) {
         _headScrView = UIScrollView.new;
        if (_headBtnStyle!=NavigationButtonView) {
            _headScrView.backgroundColor = [UIColor whiteColor];
        }
        switch (_headBtnStyle) {
            case DefaultButtonView:
                _headScrView.frame = CGRectMake(0, 0, self.view.frame.size.width, _headBtnHeigth);
                break;
            case HeadShowMoreBtnView:
                _headScrView.frame = CGRectMake(0, 0, self.view.frame.size.width-kMoreBtnWidth, _headBtnHeigth);
                break;
            case NavigationButtonView:
                _headScrView.frame = CGRectMake(0, 0, DEVICE_WIDTH-180, _headBtnHeigth);
                _headScrView.backgroundColor = [UIColor clearColor];
                break;
        }
        _headScrView.contentSize = CGSizeMake( _titleBtnWidth* _viewControllers.count, _headBtnHeigth);
        _headScrView.scrollEnabled = _viewControllers.count>MAX_BUTTON_NUMBER?true:false;
        _headScrView.showsHorizontalScrollIndicator = NO;
        _headScrView.bounces = _headScrView.scrollEnabled;
    }
    return _headScrView;
}
- (UIScrollView *)contentScrView {
    if (_contentScrView==nil) {
        _contentScrView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _headBtnHeigth, self.view.frame.size.width , self.view.frame.size.height-_headBtnHeigth)];
        if (_headBtnStyle==NavigationButtonView) {
            _contentScrView.frame = CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height);
        }
        _contentScrView.contentSize = CGSizeMake(self.view.frame.size.width*_viewControllers.count, _contentScrView.frame.size.height);
        _contentScrView.pagingEnabled = YES;
        _contentScrView.showsHorizontalScrollIndicator = NO;
        _contentScrView.directionalLockEnabled = YES;
        if (_viewControllers.count>1) {
            _contentScrView.delegate = self;
        }
    }
    return _contentScrView;
}

- (NSArray *)RGBSelectedArr {
    if (!_RGBSelectedArr) {
        CGFloat red = 0.0;
        CGFloat green = 0.0;
        CGFloat blue = 0.0;
        CGFloat alpha = 0.0;
        [_selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
        _RGBSelectedArr = @[@(red), @(green), @(blue), @(alpha)];
    }
    return _RGBSelectedArr;
}
- (NSArray *)RGBNormalArr {
    if (!_RGBNormalArr) {
        CGFloat red = 0.0;
        CGFloat green = 0.0;
        CGFloat blue = 0.0;
        CGFloat alpha = 0.0;
        [_normalColor getRed:&red green:&green blue:&blue alpha:&alpha];
        _RGBNormalArr = @[@(red), @(green), @(blue), @(alpha)];
    }
    return _RGBNormalArr;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
