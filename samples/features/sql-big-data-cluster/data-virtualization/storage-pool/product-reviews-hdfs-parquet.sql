USE sales
GO

-- Create file format for parquet file with appropriate properties.
--
IF NOT EXISTS(SELECT * FROM sys.external_file_formats WHERE name = 'parquet_file')
    CREATE EXTERNAL FILE FORMAT parquet_file
    WITH (
        FORMAT_TYPE = PARQUET
    );


-- Create external table over HDFS data source (SqlStoragePool) in
-- SQL Server 2019 big data cluster. The SqlStoragePool data source
-- is a special data source that is available in any new database in
-- SQL Master instance.
--
CREATE EXTERNAL TABLE [product_reviews_hdfs_parquet]
("pr_review_sk" BIGINT , "pr_review_content" varchar(8000))
WITH
(
    DATA_SOURCE = SqlStoragePool,
	LOCATION = '/user/hive/warehouse/product_review_data',
    FILE_FORMAT = parquet_file
);
GO

-- Join external table with local tables
-- 
SELECT 
    p.pr_review_sk, pc.pr_review_content
  FROM product_reviews as p
  JOIN (SELECT TOP(10) * FROM product_reviews_hdfs_parquet) AS pc
    ON pc.pr_review_sk = p.pr_review_sk;
GO

DROP EXTERNAL TABLE [dbo].[product_reviews_hdfs_parquet];
GO