//
//  ContentViewController.m
//  SearchForAirTickets
//
//  Created by Alexandr Evtodiy on 25.03.2021.
//

#import "ContentViewController.h"

@interface ContentViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@end

@implementation ContentViewController

#pragma mark - Initialisation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self config];
    }
    return self;
}

#pragma mark - Config

- (void) config {
    [self configImageView];
    [self configTitleLabel];
    [self configContentLabel];
}

- (void) configImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 100.0, [UIScreen mainScreen].bounds.size.height/2 - 100.0, 200.0, 200.0)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.cornerRadius = 8.0;
    self.imageView.clipsToBounds = YES;
    [self.view addSubview:self.imageView];
}

- (void) configTitleLabel {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 100.0, CGRectGetMinY(self.imageView.frame) - 61.0, 200.0, 21.0)];
    self.titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightHeavy];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
}

- (void) configContentLabel {
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 100.0, CGRectGetMaxY(self.imageView.frame) + 20.0, 200.0, 21.0)];
    self.contentLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.contentLabel];
}

#pragma mark - Public

- (void)setContentText:(NSString *)contentText {
    _contentText = contentText;
    self.contentLabel.text = contentText;
    float height = heightForText(contentText, self.contentLabel.font, 200.0);
    self.contentLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 100.0, CGRectGetMaxY(self.imageView.frame) + 20.0, 200.0, height);
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

#pragma mark - Private

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    float height = heightForText(title, self.titleLabel.font, 200.0);
    self.titleLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 100.0, CGRectGetMinY(self.imageView.frame) - 40.0 - height, 200.0, height);
}

float heightForText(NSString *text, UIFont *font, float width) {
    if (text && [text isKindOfClass:[NSString class]]) {
        CGSize size = CGSizeMake(width, FLT_MAX);
        CGRect needLabel = [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:font} context:nil];
        return ceilf(needLabel.size.height);
    }
    return 0.0;
}

@end
