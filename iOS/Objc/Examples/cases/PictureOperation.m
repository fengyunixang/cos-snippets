#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>
#import <QCloudCOSXML/QCloudPutObjectWatermarkRequest.h>

@interface PictureOperation : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation PictureOperation

- (void)setUp {
    // 注册默认的 COS 服务
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1253653367";
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-guangzhou";//服务地域名称，可用的地域请参考注释
    endpoint.useHTTPS = true;
    configuration.endpoint = endpoint;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];

    // 脚手架用于获取临时密钥
    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
}

- (void) fenceQueue:(QCloudCredentailFenceQueue * )queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];
    //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
    credential.secretID = @"COS_SECRETID";
    credential.secretKey = @"COS_SECRETKEY";
    credential.token = @"COS_TOKEN";
    /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
    credential.startDate = [[[NSDateFormatter alloc] init] dateFromString:@"startTime"]; // 单位是秒
    credential.expirationDate = [[[NSDateFormatter alloc] init] dateFromString:@"expiredTime"];
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc]
        initWithCredential:credential];
    continueBlock(creator, nil);
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator, NSError *error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);
        }
    }];
}

/**
 * 上传时图片处理
 */
- (void)uploadWithPicOperation {
    //.cssg-snippet-body-start:[objc-upload-with-pic-operation]
    QCloudPutObjectWatermarkRequest* put = [QCloudPutObjectWatermarkRequest new];
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    put.object = @"exampleobject";
    // 存储桶名称，格式为 BucketName-APPID
    put.bucket = @"examplebucket-1250000000";
    
    put.body =  [@"123456789" dataUsingEncoding:NSUTF8StringEncoding];
    QCloudPicOperations * op = [[QCloudPicOperations alloc]init];
    
    // 是否返回原图信息。0表示不返回原图信息，1表示返回原图信息，默认为0
    op.is_pic_info = NO;
    QCloudPicOperationRule * rule = [[QCloudPicOperationRule alloc]init];
    
    // 处理结果的文件路径名称，如以/开头，则存入指定文件夹中，否则，存入原图文件存储的同目录
    rule.fileid = @"test";
    
    // 盲水印文字，需要经过 URL 安全的 Base64 编码。当 type 为3时必填，type
    rule.text = @"123"; // 水印文字只能是 [a-zA-Z0-9]
    
    // 盲水印类型，有效值：1 半盲；2 全盲；3 文字
    rule.type = QCloudPicOperationRuleText;
    op.rule = @[rule];
    put.picOperations = op;
    [put setFinishBlock:^(id outputObject, NSError *error) {
       
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutWatermarkObject:put];
    //.cssg-snippet-body-end
}

/**
 * 对云上数据进行图片处理
 */
- (void)processWithPicOperation {
    //.cssg-snippet-body-start:[objc-process-with-pic-operation]
    QCloudCICloudDataOperationsRequest* put = [QCloudCICloudDataOperationsRequest new];
    
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    put.object = @"exampleobject";
    // 存储桶名称，格式为 BucketName-APPID
    put.bucket = @"examplebucket-1250000000";
    
    QCloudPicOperations * op = [[QCloudPicOperations alloc]init];
    
    // 是否返回原图信息。0表示不返回原图信息，1表示返回原图信息，默认为0
    op.is_pic_info = NO;
    QCloudPicOperationRule * rule = [[QCloudPicOperationRule alloc]init];
    
    // 处理结果的文件路径名称，如以/开头，则存入指定文件夹中，否则，存入原图文件存储的同目录
    rule.fileid = @"test";
    
    // 盲水印文字，需要经过 URL 安全的 Base64 编码。当 type 为3时必填，type
    rule.text = @"123"; // 水印文字只能是 [a-zA-Z0-9]
    
    // 盲水印类型，有效值：1 半盲；2 全盲；3 文字
    rule.type = QCloudPicOperationRuleText;
    op.rule = @[rule];
    put.picOperations = op;
    [put setFinishBlock:^(id outputObject, NSError *error) {
       
    }];
    [[QCloudCOSXMLService defaultCOSXML] CloudDataOperations:put];
    //.cssg-snippet-body-end
}

/**
 * 上传时添加盲水印
 */
- (void)putObjectWithWatermark {
    //不支持
    //.cssg-snippet-body-start:[objc-put-object-with-watermark]
    QCloudPutObjectWatermarkRequest* put = [QCloudPutObjectWatermarkRequest new];

    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    put.object = @"exampleobject";
    // 存储桶名称，格式为 BucketName-APPID
    put.bucket = @"examplebucket-1250000000";

    put.body =  [@"123456789" dataUsingEncoding:NSUTF8StringEncoding];
    QCloudPicOperations * op = [[QCloudPicOperations alloc]init];

    // 是否返回原图信息。0表示不返回原图信息，1表示返回原图信息，默认为0
    op.is_pic_info = NO;
    QCloudPicOperationRule * rule = [[QCloudPicOperationRule alloc]init];

    // 处理结果的文件路径名称，如以/开头，则存入指定文件夹中，否则，存入原图文件存储的同目录
    rule.fileid = @"test";

    // 盲水印图片在cos上的地址：如http://ci-1253653367.cos.ap-guangzhou.myqcloud.com/watermark_icon.png
     rule.imageURL = @"watermarkURL";
     //操作：有效值 :QCloudPicOperationRuleActionPut:添加盲水印  QCloudPicOperationRuleActionExtrac:提取盲水印
     rule.actionType =QCloudPicOperationRuleActionPut;
    // 盲水印类型，有效值：QCloudPicOperationRuleHalf 半盲；QCloudPicOperationRuleFull: 全盲；QCloudPicOperationRuleText 文字
    rule.type = QCloudPicOperationRuleFull;
    op.rule = @[rule];
    put.picOperations = op;
    [put setFinishBlock:^(QCloudPutObjectWatermarkResult *outputObject, NSError *error) {
       
    }];
    [[QCloudCOSXMLService defaultCOSXML] PutWatermarkObject:put];
    //.cssg-snippet-body-end
}

/**
 * 下载时添加盲水印
 */
- (void)downloadObjectWithWatermark {
    //不支持
    //.cssg-snippet-body-start:[objc-download-object-with-watermark]
    QCloudGetObjectRequest * request = [QCloudGetObjectRequest new];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";

    //处理参数，规则参见：https://cloud.tencent.com/document/product/460/19017
    request.watermarkRule = @"watermark/3/type/2/image/aHR0cDovL2NpLTEyNTM2NTMzNjcuY29zLmFwLWd1YW5nemhvdS5teXFjbG91ZC5jb20vcHJvdGVjdGlvbl9ibGluZF93YXRlcm1hcmtfaWNvbi5wbmc=";

    // 设置下载的路径 URL，如果设置了，文件将会被下载到指定路径中
    request.downloadingURL = [NSURL fileURLWithPath:@"Local File Path"];

    // 本地已下载的文件大小，如果是从头开始下载，请不要设置
    request.localCacheDownloadOffset = 100;

    // 监听下载结果
    [request setFinishBlock:^(id outputObject, NSError *error) {
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
    }];

    // 监听下载进度
    [request setDownProcessBlock:^(int64_t bytesDownload,
                                   int64_t totalBytesDownload,
                                   int64_t totalBytesExpectedToDownload) {
        
        // bytesDownload                   新增字节数
        // totalBytesDownload              本次下载接收的总字节数
        // totalBytesExpectedToDownload    本次下载的目标字节数
    }];

    [[QCloudCOSXMLService defaultCOSXML] GetObject :request];
    //.cssg-snippet-body-end
}
/**
 * 图片审核
 */
- (void)sensitiveContentRecognition{
    //不支持
    //.cssg-snippet-body-start:[objc-sensitive-content-recognition]
    QCloudGetRecognitionObjectRequest *request = [QCloudGetRecognitionObjectRequest new];
    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";
    //  对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "dir1/object1"
    request.object = @"exampleobject";
    
    // 支持多种类型同时审核
    request.detectType = QCloudRecognitionPorn | QCloudRecognitionAds;
    
    [request setFinishBlock:^(QCloudGetRecognitionObjectResult *_Nullable outputObject, NSError *_Nullable error) {
        NSLog(@"%@", outputObject);
    }];

    [[QCloudCOSXMLService defaultCOSXML] GetRecognitionObject:request];
    //.cssg-snippet-body-end
}

/**
 * 下载时进行图片处理
 */
- (void)downloadWithPicOperation {
    //.cssg-snippet-body-start:[objc-download-with-pic-operation]
    
    //.cssg-snippet-body-end
}




// .cssg-methods-pragma

- (void)testPictureOperation {
    // 上传时图片处理
    [self uploadWithPicOperation];

    // 对云上数据进行图片处理
    [self processWithPicOperation];
        
    // 上传时添加盲水印
    [self putObjectWithWatermark];
        
    // 下载时添加盲水印
    [self downloadObjectWithWatermark];
        
    // 图片审核
    [self sensitiveContentRecognition];

    // 下载时进行图片处理
    [self downloadWithPicOperation];
        
  
        
    // .cssg-methods-pragma
}

@end
