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
    public class BucketInventoryModel {

      private CosXml cosXml;

      BucketInventoryModel() {
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

      /// 设置存储桶清单任务
      public void PutBucketInventory()
      {
        //.cssg-snippet-body-start:[put-bucket-inventory]
        try
        {
          string inventoryId = "aInventoryId";
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          PutBucketInventoryRequest putRequest = new PutBucketInventoryRequest(bucket, inventoryId);
          putRequest.SetDestination("CSV", "100000000001", "examplebucket-1250000000", "ap-guangzhou","list1");
          putRequest.IsEnable(true);
          putRequest.SetScheduleFrequency("Daily");
          //执行请求
          PutBucketInventoryResult putResult = cosXml.PutBucketInventory(putRequest); 
          
          //请求成功
          Console.WriteLine(putResult.GetResultInfo());
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

      /// 获取存储桶清单任务
      public void GetBucketInventory()
      {
        //.cssg-snippet-body-start:[get-bucket-inventory]
        try
        {
          string inventoryId = "aInventoryId";
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          GetBucketInventoryRequest getRequest = new GetBucketInventoryRequest(bucket);
          getRequest.SetInventoryId(inventoryId);
          
          GetBucketInventoryResult getResult = cosXml.GetBucketInventory(getRequest);
          
          InventoryConfiguration configuration = getResult.inventoryConfiguration;
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

      /// 删除存储桶清单任务
      public void DeleteBucketInventory()
      {
        //.cssg-snippet-body-start:[delete-bucket-inventory]
        try
        {
          string inventoryId = "aInventoryId";
          // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
          string bucket = "examplebucket-1250000000";
          DeleteBucketInventoryRequest deleteRequest = new DeleteBucketInventoryRequest(bucket);
          deleteRequest.SetInventoryId(inventoryId);
          DeleteBucketInventoryResult deleteResult = cosXml.DeleteBucketInventory(deleteRequest);
          
          //请求成功
          Console.WriteLine(deleteResult.GetResultInfo());
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

      /// 列出所有存储桶清单任务
      public void ListBucketInventory()
      {
        //.cssg-snippet-body-start:[list-bucket-inventory]
        
        //.cssg-snippet-body-end
      }


      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        BucketInventoryModel m = new BucketInventoryModel();

        /// 设置存储桶清单任务
        m.PutBucketInventory();
        /// 获取存储桶清单任务
        m.GetBucketInventory();
        /// 删除存储桶清单任务
        m.DeleteBucketInventory();

        /// 列出所有存储桶清单任务
        m.ListBucketInventory();
        // .cssg-methods-pragma
      }
    }
}
