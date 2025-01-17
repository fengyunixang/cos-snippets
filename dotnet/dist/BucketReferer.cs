using COSXML.Common;
using COSXML.CosException;
using COSXML.Model;
using COSXML.Model.Object;
using COSXML.Model.Tag;
using COSXML.Model.Bucket;
using COSXML.Model.Service;
using COSXML.Utils;
using COSXML.Auth;
using COSXML.Transfer;
using System;
using COSXML;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace COSSnippet
{
    public class BucketRefererModel {

      private CosXml cosXml;

      BucketRefererModel() {
        CosXmlConfig config = new CosXmlConfig.Builder()
          .SetRegion("COS_REGION") // 设置默认的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
          .Build();
        
        string secretId = "SECRET_ID";   // 云 API 密钥 SecretId, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        string secretKey = "SECRET_KEY"; // 云 API 密钥 SecretKey, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        long durationSecond = 600;          //每次请求签名有效时长，单位为秒
        QCloudCredentialProvider qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, 
          secretKey, durationSecond);
        
        this.cosXml = new CosXmlServer(config, qCloudCredentialProvider);
      }

      /// 设置存储桶防盗链
      public void PutBucketReferer()
      {
        //.cssg-snippet-body-start:[put-bucket-cors]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          PutBucketRefererRequest request = new PutBucketRefererRequest(bucket);
          // 设置防盗链规则
          RefererConfiguration configuration = new RefererConfiguration();
          configuration.Status = "Enabled"; // 是否开启防盗链，枚举值：Enabled、Disabled
          configuration.RefererType = "White-List"; // 防盗链类型，枚举值：Black-List、White-List
          // 生效域名列表， 支持多个域名且为前缀匹配， 支持带端口的域名和 IP， 支持通配符*，做二级域名或多级域名的通配
          configuration.domainList = new DomainList(); 
          // 单条生效域名 例如www.qq.com/example，192.168.1.2:8080， *.qq.com
          configuration.domainList.AddDomain("*.domain1.com");
          configuration.domainList.AddDomain("*.domain2.com");
          // 是否允许空 Referer 访问，枚举值：Allow、Deny，默认值为 Deny
          configuration.EmptyReferConfiguration = "Deny";
          request.SetRefererConfiguration(configuration);
          //执行请求
          PutBucketRefererResult result = cosXml.PutBucketReferer(request);
          //请求成功
          Console.WriteLine(result.GetResultInfo());
        }
        catch (COSXML.CosException.CosClientException clientEx)
        {
          //请求失败
          Console.WriteLine("CosClientException: " + clientEx);
        }
        catch (COSXML.CosException.CosServerException serverEx)
        {
          //请求失败
          Console.WriteLine("CosServerException: " + serverEx.GetInfo());
        }
        
        //.cssg-snippet-body-end
      }

      /// 获取存储桶防盗链规则
      public void GetBucketReferer()
      {
        //.cssg-snippet-body-start:[get-bucket-cors]
        try
        {
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          GetBucketRefererRequest request = new GetBucketRefererRequest(bucket);
          // 执行请求
          GetBucketRefererResult result = cosXml.GetBucketReferer(request);
          Console.WriteLine(result.GetResultInfo());
          // Status参数
          Console.WriteLine(result.refererConfiguration.Status);
          // Referer名单类型
          Console.WriteLine(result.refererConfiguration.RefererType);
          // 名单中的域名列表
          foreach (string domain in result.refererConfiguration.domainList.domains)
          {
            Console.WriteLine(domain);
          }
        }
        catch (COSXML.CosException.CosClientException clientEx)
        {
          //请求失败
          Console.WriteLine("CosClientException: " + clientEx);
        }
        catch (COSXML.CosException.CosServerException serverEx)
        {
          //请求失败
          Console.WriteLine("CosServerException: " + serverEx.GetInfo());
        }
        
        //.cssg-snippet-body-end
      }
    
      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        BucketRefererModel m = new BucketRefererModel();

        /// 设置存储桶跨域规则
        m.PutBucketReferer();
        /// 获取存储桶跨域规则
        m.GetBucketReferer();
        // .cssg-methods-pragma
      }
    }
}
