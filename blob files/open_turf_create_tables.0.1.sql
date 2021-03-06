


SET ANSI_NULLS ON;

SET QUOTED_IDENTIFIER ON;


/* ************** Create PointDataSummary Table ***************** */

CREATE TABLE [PointDataSummary](
	[Id] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Guid] [nvarchar](100),
	[Name] [nvarchar](255)  DEFAULT ('') NOT NULL,
	[Description] [nvarchar](4000) NOT NULL,
	[Latitude] [decimal](10, 5) NOT NULL,
	[Longitude] [decimal](10, 5) NOT NULL,
	[LayerId] [nvarchar](40) NOT NULL,
	[Tag] [nvarchar](max) NULL,
	[RatingCount] [int] DEFAULT (0) NOT NULL,
	[RatingTotal] [bigint] DEFAULT (0) NOT NULL,
	[CommentCount] [int] DEFAULT (0) NOT NULL,
	[CreatedOn] [smalldatetime] DEFAULT GETUTCDATE() NOT NULL,
	[ModifiedOn] [smalldatetime] DEFAULT GETUTCDATE() NOT NULL,
	[CreatedById] [bigint] DEFAULT (0) NOT NULL
);


/* **************** Create PointDataComment Table *************** */

CREATE TABLE [PointDataComment](
	[Id] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Text] [nvarchar](4000) NOT NULL,
	[CreatedOn] [smalldatetime] DEFAULT GETUTCDATE() NOT NULL,
	[CreatedById] [bigint] NOT NULL,
	[SummaryId] [bigint] NOT NULL);

ALTER TABLE PointDataComment
ADD CONSTRAINT [FK_PointDataComment_PointDataSummary] FOREIGN KEY([SummaryId]) REFERENCES [dbo].[PointDataSummary] ([Id])
;


/* ****************** Create UserRole Table ****************** */

CREATE TABLE [UserRole](
	[Code] [smallint] NOT NULL PRIMARY KEY,
	[Name] [nvarchar](20) NOT NULL
);

/* Bit-flag Enum */
INSERT UserRole VALUES(0, 'Member');
INSERT UserRole VALUES(1, 'Moderator');
INSERT UserRole VALUES(2, 'Administrator');

/* ******************* Create UserAccess Table ******************* */

CREATE TABLE [UserAccess](
	[Code] [smallint] NOT NULL PRIMARY KEY,
	[Name] [nvarchar](20) NOT NULL
);

/* Normal Enum */
INSERT UserAccess VALUES(0, 'Normal');
INSERT UserAccess VALUES(1, 'Pending');
INSERT UserAccess VALUES(2, 'Deleted');
INSERT UserAccess VALUES(3, 'Banned');

/* ************** Create OAuthAccount Table ************ */

CREATE TABLE [OAuthAccount](
	[Id] [bigint] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[user_id] [bigint]  NOT NULL,
	[screen_name] [nvarchar](30) NOT NULL,
	[oauth_token] [nvarchar](255) NOT NULL,
	[oauth_token_secret] [nvarchar](255) NOT NULL,
	[oauth_service_id] [int] DEFAULT(1) NOT NULL,
	[UserRole] [smallint] DEFAULT (0) NOT NULL,
	[UserAccess] [smallint] DEFAULT (0) NOT NULL,
	[LastAccessedOn] [smalldatetime] NOT NULL,
	[TokenExpiry] [smalldatetime] NOT NULL,
	[profile_image_url] [nvarchar](255) DEFAULT ('') NOT NULL,
	[CreatedOn] [smalldatetime] DEFAULT GETUTCDATE() NOT NULL
);

/* Foreign Keys */

ALTER TABLE OAuthAccount
ADD CONSTRAINT [FK_OAuthAccount_UserRole] FOREIGN KEY([UserRole]) REFERENCES [dbo].[UserRole] ([Code]);

ALTER TABLE OAuthAccount
ADD CONSTRAINT [FK_OAuthAccount_UserAccess] FOREIGN KEY([UserAccess]) REFERENCES [dbo].[UserAccess] ([Code]);

/* Alter existing tables PointDataSummary and PointDataComment with FK for OAuthAccount */

ALTER TABLE PointDataSummary
ADD CONSTRAINT [FK_PointDataSummary_OAuthAccount] FOREIGN KEY([CreatedById]) REFERENCES [dbo].[OAuthAccount] ([Id]);

ALTER TABLE PointDataComment
ADD CONSTRAINT [FK_PointDataComment_OAuthAccount] FOREIGN KEY([CreatedById]) REFERENCES [dbo].[OAuthAccount] ([Id]);


/* Add system default OAuthAccount */

SET IDENTITY_INSERT OAuthAccount ON; -- turn off temporarily

INSERT INTO OAuthAccount (Id, user_id, screen_name, oauth_token, oauth_token_secret, UserRole, UserAccess, LastAccessedOn, TokenExpiry, oauth_service_id) 
	VALUES(0, 0, 'system', '', '', 2, 0, GETUTCDATE(), GETUTCDATE(), 1);

SET IDENTITY_INSERT OAuthAccount OFF; -- turn back on


/* *************** Create OAuthClientApp Table ****************** */

CREATE TABLE [OAuthClientApp](
	[Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Guid] [nvarchar](255) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Comment] [nvarchar](255) DEFAULT ('') NOT NULL,
	[ConsumerKey] [nvarchar](255) NOT NULL,
	[ConsumerSecret] [nvarchar](255) NOT NULL,
	[CallbackUrl] [nvarchar](1000) NOT NULL,
	[AppUrl] [nvarchar](1000) NOT NULL,
	[oauth_service_name] [nvarchar](50) DEFAULT ('Twitter') NOT NULL,
	[CreatedOn] [smalldatetime] DEFAULT GETUTCDATE()
);


/* *********************************************************************** 

   Below, add your Twitter app keys that are allowed to use ODAF. 
   Register at http://twitter.com/oauth_clients/new 
   Generate a Guid for each client that you want to give access. 
   This app guid is used to identify the client app in authentication calls. 
   
   The sample app record below is just an example, and does NOT work 
   
************************************************************************* */

/*
INSERT INTO OAuthClientApp (Guid, Name, Comment, ConsumerKey, ConsumerSecret, CallbackUrl, AppUrl) 
	VALUES('c1ec2c57-742b-415b-84a6-4d8ae5b53e9', 'Odafrance', 'Odafrance twitter', 
	'CvU6WC7QdKSau45INCU2KQ', '5wmeqy4zwXkoCgWiPaav0dEMbKvjNsR62g6Mn3tB4', 
	'http://odafrance.cloudapp.net/User/AuthorizeReturn', 'CHANGEME:app-url-here')
*/

/* Alter existing table OAuthAccount with FK for OAuthClientApp */

ALTER TABLE [OAuthAccount]
ADD CONSTRAINT [FK_OAuthAccount_OauthServiceId] FOREIGN KEY([oauth_service_id]) REFERENCES [dbo].[OAuthClientApp] ([Id]);







CREATE TABLE [PointDataSource] (
  [PointDataSourceId] [bigint]IDENTITY(1,1) NOT NULL PRIMARY KEY,
  [UniqueId] nvarchar(255) NOT NULL,
  [Title] nvarchar(255),
  [AuthorName] nvarchar(255),
  [AuthorEmail] nvarchar(255),
  [BoundaryPolygon] nvarchar(1000),
  [Active] [bit] DEFAULT (0) NOT NULL,
  [Description] nvarchar(500),
  [UpdatedOn] [smalldatetime] DEFAULT GETUTCDATE() NOT NULL,
  [CreatedOn] [smalldatetime] DEFAULT GETUTCDATE() NOT NULL,
);



CREATE TABLE [PointDataFeed] (
  [PointDataFeedId] [bigint]IDENTITY(1,1) NOT NULL PRIMARY KEY,
  [PointDataSourceId] [bigint] NOT NULL,
  [UniqueId] nvarchar(255) NOT NULL,
  [Title] nvarchar(255) NOT NULL,
  [Summary] nvarchar(500),
  [KMLFeedUrl] nvarchar(255),
  [ImageUrl] nvarchar(255),
  [IsRegion] [bit] DEFAULT (0) NOT NULL,
  [Active] [bit] DEFAULT (0) NOT NULL,
  [UpdatedOn] [smalldatetime] DEFAULT GETUTCDATE() NOT NULL,
  [CreatedOn] [smalldatetime] DEFAULT GETUTCDATE() NOT NULL,
);



ALTER TABLE PointDataFeed
ADD CONSTRAINT [FK_PointDataFeed_PointDataSource] FOREIGN KEY([PointDataSourceId]) REFERENCES [dbo].[PointDataSource] ([PointDataSourceId]);


/* ****************** Create PointDataLayer Table ********************/

CREATE TABLE [PointDataLayer] (
  [Id] [bigint]IDENTITY(1,1) NOT NULL PRIMARY KEY,
  [Guid] nvarchar(255) NOT NULL,
  [Name] nvarchar(50) NOT NULL,
  [IsSystem] [bit] DEFAULT (0),
  [PointDataSourceId] [bigint] NOT NULL,
  [CreatedOn] [smalldatetime] DEFAULT GETUTCDATE() NOT NULL,
);



/* *********************************************************************** 
 
 Views creation
 
************************************************************************* */

CREATE VIEW [dbo].[PointDataSummaryView]
AS
SELECT     dbo.PointDataSummary.Id, dbo.PointDataSummary.Guid, dbo.PointDataSummary.Name, dbo.PointDataSummary.Description, dbo.PointDataSummary.Latitude, dbo.PointDataSummary.Longitude, dbo.PointDataSummary.LayerId, dbo.PointDataSummary.Tag, dbo.PointDataSummary.RatingCount, dbo.PointDataSummary.RatingTotal, dbo.PointDataSummary.CommentCount, dbo.PointDataSummary.CreatedOn, dbo.PointDataSummary.ModifiedOn, dbo.PointDataSummary.CreatedById, dbo.OAuthAccount.screen_name, COUNT(dbo.PointDataComment.Id) AS Comments
FROM         dbo.PointDataSummary LEFT OUTER JOIN
                      dbo.OAuthAccount ON dbo.PointDataSummary.CreatedById = dbo.OAuthAccount.Id LEFT OUTER JOIN
                      dbo.PointDataComment ON dbo.PointDataSummary.Id = dbo.PointDataComment.SummaryId AND dbo.OAuthAccount.Id = dbo.PointDataComment.CreatedById
GROUP BY dbo.PointDataSummary.Id, dbo.PointDataSummary.Guid, dbo.PointDataSummary.Name, dbo.PointDataSummary.Description, dbo.PointDataSummary.Latitude, dbo.PointDataSummary.Longitude, dbo.PointDataSummary.LayerId, dbo.PointDataSummary.Tag, dbo.PointDataSummary.RatingCount, dbo.PointDataSummary.RatingTotal, dbo.PointDataSummary.CommentCount, dbo.PointDataSummary.CreatedOn, dbo.PointDataSummary.ModifiedOn, dbo.PointDataSummary.CreatedById, dbo.OAuthAccount.screen_name
;



CREATE VIEW [dbo].[PointDataCommentView]
AS
SELECT     dbo.PointDataComment.Id, dbo.PointDataComment.Text, dbo.PointDataComment.CreatedOn, dbo.PointDataComment.CreatedById, dbo.PointDataComment.SummaryId, dbo.OAuthAccount.screen_name, dbo.PointDataSummary.Name AS summary
FROM         dbo.PointDataComment LEFT OUTER JOIN
                      dbo.PointDataSummary ON dbo.PointDataComment.SummaryId = dbo.PointDataSummary.Id LEFT OUTER JOIN
                      dbo.OAuthAccount ON dbo.PointDataComment.CreatedById = dbo.OAuthAccount.Id AND dbo.PointDataSummary.CreatedById = dbo.OAuthAccount.Id
;

CREATE VIEW [dbo].[OAuthAccountView]
AS
SELECT     dbo.OAuthAccount.Id, dbo.OAuthAccount.user_id, dbo.OAuthAccount.screen_name, dbo.OAuthAccount.oauth_token, dbo.OAuthAccount.oauth_token_secret, dbo.OAuthAccount.oauth_service_id, dbo.OAuthAccount.UserRole, dbo.OAuthAccount.UserAccess, dbo.OAuthAccount.LastAccessedOn, dbo.OAuthAccount.TokenExpiry, dbo.OAuthAccount.profile_image_url, ISNULL(dbo.OAuthAccount.CreatedOn, GETUTCDATE()) AS CreatedOn, COUNT(dbo.PointDataSummary.Id) AS Summaries, COUNT(dbo.PointDataComment.Id) AS Comments
FROM         dbo.OAuthAccount LEFT OUTER JOIN
                      dbo.PointDataComment ON dbo.OAuthAccount.Id = dbo.PointDataComment.CreatedById LEFT OUTER JOIN
                      dbo.PointDataSummary ON dbo.OAuthAccount.Id = dbo.PointDataSummary.CreatedById AND dbo.PointDataComment.SummaryId = dbo.PointDataSummary.Id
GROUP BY dbo.OAuthAccount.Id, dbo.OAuthAccount.user_id, dbo.OAuthAccount.screen_name, dbo.OAuthAccount.oauth_token, dbo.OAuthAccount.oauth_token_secret, dbo.OAuthAccount.oauth_service_id, dbo.OAuthAccount.UserRole, dbo.OAuthAccount.UserAccess, dbo.OAuthAccount.LastAccessedOn, dbo.OAuthAccount.TokenExpiry, dbo.OAuthAccount.profile_image_url, dbo.OAuthAccount.CreatedOn
;

CREATE VIEW [dbo].[PointDataSourceView]
AS
SELECT     dbo.PointDataSource.PointDataSourceId, dbo.PointDataSource.UniqueId, dbo.PointDataSource.Title, dbo.PointDataSource.AuthorName, dbo.PointDataSource.AuthorEmail, dbo.PointDataSource.BoundaryPolygon, dbo.PointDataSource.Active, dbo.PointDataSource.Description, dbo.PointDataSource.UpdatedOn, dbo.PointDataSource.CreatedOn, COUNT(dbo.PointDataFeed.PointDataSourceId) AS Feeds, COUNT(dbo.PointDataLayer.PointDataSourceId) AS Layers
FROM         dbo.PointDataSource LEFT OUTER JOIN
                      dbo.PointDataFeed ON dbo.PointDataSource.PointDataSourceId = dbo.PointDataFeed.PointDataSourceId LEFT OUTER JOIN
                      dbo.PointDataLayer ON dbo.PointDataSource.PointDataSourceId = dbo.PointDataLayer.PointDataSourceId
GROUP BY dbo.PointDataSource.PointDataSourceId, dbo.PointDataSource.UniqueId, dbo.PointDataSource.Title, dbo.PointDataSource.AuthorName, dbo.PointDataSource.AuthorEmail, dbo.PointDataSource.BoundaryPolygon, dbo.PointDataSource.Active, dbo.PointDataSource.Description, dbo.PointDataSource.UpdatedOn, dbo.PointDataSource.CreatedOn
;


CREATE VIEW [dbo].[PointDataFeedView]
AS
SELECT     dbo.PointDataFeed.PointDataFeedId, dbo.PointDataFeed.PointDataSourceId, dbo.PointDataFeed.UniqueId, dbo.PointDataFeed.Title, dbo.PointDataFeed.Summary, dbo.PointDataFeed.KMLFeedUrl, dbo.PointDataFeed.ImageUrl, dbo.PointDataFeed.IsRegion, dbo.PointDataFeed.Active, dbo.PointDataFeed.UpdatedOn, dbo.PointDataFeed.CreatedOn, dbo.PointDataSource.Title AS DataSourceName
FROM         dbo.PointDataFeed LEFT OUTER JOIN
                      dbo.PointDataSource ON dbo.PointDataFeed.PointDataSourceId = dbo.PointDataSource.PointDataSourceId
;

ALTER TABLE PointDataLayer
ADD CONSTRAINT [FK_PointDataLayer_PointDataSource] FOREIGN KEY([PointDataSourceId]) REFERENCES [dbo].[PointDataSource] ([PointDataSourceId])
;

CREATE VIEW [dbo].[PointDataLayerView]
AS
SELECT     dbo.PointDataLayer.Id, dbo.PointDataLayer.Guid, dbo.PointDataLayer.Name, dbo.PointDataLayer.IsSystem, dbo.PointDataLayer.CreatedOn, dbo.PointDataLayer.PointDataSourceId, COUNT(dbo.PointDataSummary.Id) AS Expr1, dbo.PointDataSource.Title AS DataSourceName
FROM         dbo.PointDataSummary LEFT OUTER JOIN
                      dbo.PointDataLayer ON dbo.PointDataSummary.Id = dbo.PointDataLayer.Id LEFT OUTER JOIN
                      dbo.PointDataSource ON dbo.PointDataLayer.PointDataSourceId = dbo.PointDataSource.PointDataSourceId
GROUP BY dbo.PointDataLayer.Id, dbo.PointDataLayer.Guid, dbo.PointDataLayer.Name, dbo.PointDataLayer.IsSystem, dbo.PointDataLayer.CreatedOn, dbo.PointDataLayer.PointDataSourceId, dbo.PointDataSource.Title
;

/* *********************************************************************** 
 
 The Guids here correspond to the ATOM entries in the ATOM feeds of the
 app (where we get the KML sources from).
 All of them are 'system' layers, to differentiate them from user
 generated layers.
 
************************************************************************* */

/*
INSERT INTO PointDataSource
           (UniqueId, Title, AuthorName, AuthorEmail, BoundaryPolygon, Active, Description)
     VALUES ('c8d8c3f0-5290-468a-a756-b46320c5ac69' ,'Ville de Paris' ,'OGDI France','ogdifrance@live.fr', '"latitude":48.8566140,"longitude":2.3522219', 1, 'Catalogue de données ouvertes de la ville de Paris')

INSERT INTO PointDataSource
	   (UniqueId, Title, AuthorName, AuthorEmail, BoundaryPolygon, Active, Description)
VALUES ('4EDF9A51-4676-4fd2-BE27-8707875BA5BA' ,'City of Vancouver' ,'City of Vancouver Open Data','opendata@vancouver.ca', '"latitude":49.24169227,"longitude":-123.1042916', 1, 'City of Vancouver Open Data catalog')


INSERT INTO PointDataSource
           (UniqueId, Title, AuthorName, AuthorEmail, BoundaryPolygon, Active, Description)
VALUES ('b3e16ecf-d9b7-4191-9159-2f7c13c03e75' ,'Provence' ,'OGDI France','ogdifrance@live.fr', '"latitude":43.64218,"longitude":5.104004 ', 1, 'Catalogue de données ouvertes de la ville de Marseille')
	 
	 

INSERT INTO PointDataFeed
           (UniqueId, PointDataSourceId, Title, Summary, KMLFeedUrl, ImageUrl, IsRegion, Active)
VALUES ('3aceae60-50fb-49a8-ad9e-e553abdf421f', 1, 'Bornes pour véhicules électriques', 'Cet ensemble de données contient les coordonnées des bornes de rechargement pour véhicules électriques dans Paris', 'http://ogdifrancedataservice.cloudapp.net/v1/frOpenData/ParisElectricite/?$filter=info%20eq''BVE''%20&format=kml', 'http://odafrance.cloudapp.net/images/prise28.png', 0, 1)

INSERT INTO PointDataFeed
           (UniqueId, PointDataSourceId, Title, Summary, KMLFeedUrl, ImageUrl, IsRegion, Active)
VALUES ('3a70dc2c-8c4b-465d-9cea-99fbdc8c166d', 1, 'Toilettes publiques', 'Cet ensemble de données contient les coordonnées des sanisettes à Paris', 'http://ogdifrancedataservice.cloudapp.net/v1/frOpenData/Sanisettes/?$filter=&format=kml', 'http://odafrance.cloudapp.net/images/Toilettes28.png', 0, 1)

INSERT INTO PointDataFeed
           (UniqueId, PointDataSourceId, Title, Summary, KMLFeedUrl, ImageUrl, IsRegion, Active)
VALUES ('c86dab35-1640-4b96-bfb1-1adb87b03c61', 2, 'Community Centres', 'This spreadsheet contains the names and addresses of all of the Parks Board community centres in the City.  It also includes the Carnegie Centre which is administered by the Community Services Group rather than Parks and Recreation. The spreadsheet contains the name, address, and latitude and longitude of each community centre.', 'http://vancouverdataservice.cloudapp.net/v1/vancouver/CommunityCentres/?format=kml', 'http://vanguide.cloudapp.net/Images/communityPoint.png', 0, 1)

INSERT INTO PointDataFeed
           (UniqueId, PointDataSourceId, Title, Summary, KMLFeedUrl, ImageUrl, IsRegion, Active)
VALUES ('0C244261-26E3-49f9-8EE5-140145E90B6C', 2, 'Drinking Fountains', 'This spreadsheet contains the name, address and latitude and longitude of each of the City’s fire halls including one in the University Endowment Lands that serves the UEL and UBC.', 'http://vancouverdataservice.cloudapp.net/v1/vancouver/fireHalls/?format=kml', 'http://vanguide.cloudapp.net/Images/firehall.png', 0, 1)


INSERT INTO PointDataFeed
           (UniqueId, PointDataSourceId, Title, Summary, KMLFeedUrl, ImageUrl, IsRegion, Active)
VALUES ('ecc96199-3b89-4bb1-8c5d-7746c372a417', 3, 'Les musées', 'Cet ensemble de données contient la liste des musées des Bouches du Rhône', 'http://dataprovence.cloudapp.net:8080/v1/dataprovencetourisme/importPatio23/?$filter=&format=kml', 'http://odafrance.cloudapp.net/images/Education28.png', 0, 1)

INSERT INTO PointDataFeed
           (UniqueId, PointDataSourceId, Title, Summary, KMLFeedUrl, ImageUrl, IsRegion, Active)
VALUES ('54fcea51-d1a8-4998-b942-11f7fc93e5f7', 3, 'Les restaurants', 'Cet ensemble de données contient la liste des restaurants des Bouches du Rhône', 'http://dataprovence.cloudapp.net:8080/v1/dataprovencetourisme/importPatio51/?$filter=&format=kml', 'http://odafrance.cloudapp.net/images/school.png', 0, 1)

INSERT INTO PointDataFeed
           (UniqueId, PointDataSourceId, Title, Summary, KMLFeedUrl, ImageUrl, IsRegion, Active)
VALUES ('fe2f7a84-03cc-4183-9961-6f67e0c237b5', 3, 'Les parkings camping cars', 'Liste des parkings camping cars des Bouches-du-Rhône', 'http://dataprovence.cloudapp.net:8080/v1/dataprovencetourisme/importPatio41/?$filter=&format=kml', 'http://odafrance.cloudapp.net/images/park.png', 0, 1)

INSERT INTO PointDataFeed
           (UniqueId, PointDataSourceId, Title, Summary, KMLFeedUrl, ImageUrl, IsRegion, Active)
VALUES ('7e180b86-38cc-4ba9-ac04-5e7689dfa5b0', 3, 'Les loueurs de vélo', 'Des loueurs de vélo, VTT et vélo électriques du département des Bouches-du-Rhône', 'http://dataprovence.cloudapp.net:8080/v1/dataprovencetourisme/importPatio49/?$filter=&format=kml', 'http://odafrance.cloudapp.net/images/translink.png', 0, 1)

INSERT INTO PointDataFeed
           (UniqueId, PointDataSourceId, Title, Summary, KMLFeedUrl, ImageUrl, IsRegion, Active)
VALUES ('d84b9ca0-0f4e-41e2-a044-dd90b3f494de', 3, 'Les guides de montagne et moniteurs d''escalade', 'C''est une sélection des accompagnateurs en moyenne montagne et des moniteurs d''escalade diplômés qui travaillent dans une démarche respectueuse des sites naturels visités', 'http://dataprovence.cloudapp.net:8080/v1/dataprovencetourisme/importPatio47/?$filter=&format=kml', 'http://odafrance.cloudapp.net/images/park.png', 0, 1)


*/
