//
//  ViewController.m
//  VideoPlayer
//
//  Created by 范逸潇 on 2016/11/29.
//  Copyright © 2016年 范逸潇. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#define LookViewWidth  150.0f
#define Main_Width  self.view.frame.size.width
#define Base_Left  0.0f
#define Left_Margin 20.0f
#define item_padding 0.0f
@interface ViewController ()<UIScrollViewDelegate>
{
    NSArray * assetArray;
    
    NSTimer * currentTime;
}

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIImageView *WaterImage;

@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *item;
@property (nonatomic,strong) AVAsset *oneAsset;

@property(nonatomic,assign)BOOL  allowPlay;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allowPlay = YES;
    // Do any additional setup after loading the view, typically from a nib.
     self.oneAsset =   [AVAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"yoze2021" ofType:@"mp4"]]];
    AVAsset *secondAsset =   [AVAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"yoze2022" ofType:@"mp4"]]];
    AVAsset *thirdAsset =   [AVAsset assetWithURL:[NSURL URLWithString:@"http://files.yoze.im/upload/20160928/20160928051326160_0.mp4"]];
        AVAsset *thirdAsset1 =   [AVAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"yoze2023" ofType:@"mp4"]]];
            AVAsset *thirdAsset2 =   [AVAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"yoze2024" ofType:@"mp4"]]];
    
//    assetArray = @[self.oneAsset,secondAsset,thirdAsset,thirdAsset1,thirdAsset2];
    
     assetArray = @[self.oneAsset];
    
    self.item =[AVPlayerItem playerItemWithAsset:assetArray[0]];

    self.player = [[AVPlayer alloc]initWithPlayerItem:self.item ];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.frame = self.headerView.bounds;


    [self.headerView.layer insertSublayer:self.playerLayer atIndex:0];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(playNextVideo)
     
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
     
                                               object:self.item ];
    

    [self  configureWithScrollView];
    
    currentTime=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(coutLabelPlus) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:currentTime forMode:NSDefaultRunLoopMode];
}
#pragma mark ---- INIT
-(void)configureWithScrollView{
    for (int i = 0; i<assetArray.count; i++) {
    
        UIView * aView = [[UIView alloc]initWithFrame:CGRectMake((150 +item_padding)*i+Left_Margin, 0, 150, 100)];
        UIImageView * iamge =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 100)];
        iamge.image = [self  thumbnailImageForVideo:assetArray[i] atTime:1];
        [aView addSubview:iamge];
        aView.backgroundColor = [UIColor lightGrayColor];
        UITapGestureRecognizer  * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCustomView:)];
        [aView addGestureRecognizer:tap];
        [self.scrollView addSubview:aView];
    }
    [self.scrollView setContentSize:CGSizeMake(150*assetArray.count+item_padding*(assetArray.count-1)+Main_Width, 0)];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    self.scrollView.bounces = NO;
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
}

#pragma mark ----- play
-(void)playNextVideo{
    if (assetArray.count>0) {
        NSInteger  index = [assetArray indexOfObject:self.oneAsset];
        if (assetArray.count -1>= index+1) {
            [self  updateAsset:[assetArray objectAtIndex:index+1]:NO] ;
        }else{
            [self  updateAsset: [assetArray firstObject]:NO];
        }
    }
}

-(IBAction)playBtnClick:(UIButton *)sender{
    sender.selected   = !sender.selected;
    if (sender.selected) {
        [self.player play];
        self.allowPlay = YES;
    }else{
        [self.player pause];
        self.allowPlay = NO;
    }
}
#pragma mark --- Private
-(void)coutLabelPlus{
    if (self.player&&self.item&&self.playerLayer&&self.allowPlay) {
        CMTime time = self.player.currentTime;
        if (time.timescale<=0||self.item.duration.timescale<=0)  return;
        CGFloat currentTimes = time.value*1.0f /time.timescale;
         CGFloat sumTime = self.item.duration.value*1.0f/self.item.duration.timescale;
        CGFloat  directScale = currentTimes/sumTime;
        CGFloat baseOffest =[assetArray indexOfObject:self.oneAsset]*( LookViewWidth+item_padding);
        [self.scrollView setContentOffset:CGPointMake(Base_Left+baseOffest+ LookViewWidth*directScale, 0) animated:NO];
       
        
        if ( [assetArray indexOfObject:self.oneAsset] ==2 ) {
            self.WaterImage.image = [UIImage imageNamed:@"waterLayer"];
        }else{
            self.WaterImage.image = [[UIImage alloc] init];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.dragging) {
        [self.player pause];
        self.allowPlay = NO;
        self.playBtn.selected = NO;
        CGFloat percent = (scrollView.contentOffset.x-Base_Left)/150;
        if (percent>=assetArray.count) return;
        [self updateAsset: [assetArray  objectAtIndex:percent] :YES];
          percent =  (scrollView.contentOffset.x -Base_Left- floor(percent) * LookViewWidth)/LookViewWidth;
        
        double dpercent=[[NSNumber numberWithFloat:percent] doubleValue];
        double cuttime=self.oneAsset.duration.value*(dpercent);
        NSLog(@"NSStringFromCGPoint(scrollView.contentOffset) == %f",cuttime);
        CMTime begintime=CMTimeMake(cuttime, self.oneAsset.duration.timescale);
        [_player seekToTime:begintime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        
    }else{

    }
}
-(void)updateAsset:(AVAsset *)asset :(BOOL)isDrag{
    if ([self.oneAsset isEqual:asset]&&isDrag) return;
    self.oneAsset = nil;
    self.oneAsset =asset;
    self.item =[AVPlayerItem playerItemWithAsset:self.oneAsset];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNextVideo) name:AVPlayerItemDidPlayToEndTimeNotification object:self.item ];
    [self.player replaceCurrentItemWithPlayerItem:self.item];
    if (self.allowPlay) {
        [self.player  play];
    }

}

#pragma mark ---- 截取每一帧
//获取视频中图片
- (UIImage*) thumbnailImageForVideo:(AVAsset *)asset atTime:(NSTimeInterval)time {
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil] ;
//    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    assetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    assetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(time, asset.duration.timescale) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]  : nil;
    
    return thumbnailImage;
}
-(void)tapCustomView:(UIGestureRecognizer *)tap{
    
}
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
//    
//    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
//        
//        NSArray *loadedTimeRanges = [self.item loadedTimeRanges];
//        
//        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
//        
//        float startSeconds = CMTimeGetSeconds(timeRange.start);
//        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
//        NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
//        CMTime duration = self.item.duration;
//        CGFloat totalDuration = CMTimeGetSeconds(duration);
//        NSLog(@"下载进度：%.2f", timeInterval / totalDuration);
//    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
//        NSLog(@"缓冲不足暂停了");
//        //        self.playBtn.selected = NO;
//        
//    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
//        NSLog(@"缓冲达到可播放程度了");
//        //由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
//        //        [self.player play];
//    }
//}
//-(void)addObserverWithItem{
//    //监听PlayerItem这个类
//    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//    [self.item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//    [self.item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
//    [self.item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
//}
//-(void)removeObserverWithItem{
//    [self.item removeObserver:self forKeyPath:@"status"];
//    [self.item removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    [self.item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
//    [self.item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
//    
//}
@end
