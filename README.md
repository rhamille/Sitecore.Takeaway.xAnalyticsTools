# Sitecore.Takeaway.xAnalyticsTools
Sitecore Experience Analytics data extraction tools and options.

xAnalytics Tools covers quick wins for data extraction from the out-of-the-box analytics data that Sitecore provides.

This would allow users / data analysts to quickly and easily pull the latest data from Experience Analytics in Sitecore.

##PowerPivot for Excel

Using PowerPivot for Excel, allows data analysts to leverage on familiar tools when slicing and dicing data to get further insights.

Pre-requisites

1. Read-only access to Experience Analytics Reporting Database. Please check with your administrator and request for access and details such as server name and database name as well as user account to use.
 
2. Execute Sitecore.Takeaway.xAnalytics.ReportingTools.sql in your Sitecore Reporting Database. The script will create different sets of Fact tables views based on the different types of dimensions and segments available in Sitecore. Please check with your administrator if you or they can execute the script on your behalf.

PowerPivot for Excel is ideal for relatively small amount of data



##Sitecore xAnalyticsDW (Sitecore Analytics in Azure SQL Data Warehouse)

*//TODO*


##Sitecore xAnalyticsETL (Sitecore Analytics ETL from MongoDB to RDMS)

*//TODO*


##Sitecore xAnalyticsCUBE (Sitecore Analytics in SQL Server Analysis Services - SSAS)

*//TODO*
