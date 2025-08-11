-- DW para gestion de ventas que puedan medir los niveles de venta por cantidad y precio 
-- Creacion de Base de datos y Procedimientos almacenados

IF DB_ID('DWVentasTailSpinToys') IS NULL
    CREATE DATABASE DWVentasTailSpinToys;
GO

USE DWVentasTailSpinToys;
GO

--Esquema 

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dw')
    EXEC('CREATE SCHEMA dw');
GO

-- DimProducto

IF OBJECT_ID('dw.DimProducto') IS NOT NULL DROP TABLE dw.DimProducto;
CREATE TABLE dw.DimProducto (
  ProductKey       int IDENTITY(1,1) PRIMARY KEY,

  ProductID        int            NOT NULL,
  ProductSKU       nvarchar(50)   NOT NULL,
  ProductName      nvarchar(50)   NOT NULL,
  ProductCategory  nvarchar(50)   NOT NULL,
  ItemGroup        nvarchar(50)   NOT NULL,
  KitType          nvarchar(50)   NOT NULL,
  Channels         tinyint        NOT NULL,
  Demographic      nvarchar(50)   NOT NULL,
  RetailPrice      decimal(18,2)  NOT NULL,

  Activo           bit            NOT NULL DEFAULT 1,
  FechaInicio      datetime2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
  FechaFin         datetime2(0)   NULL
);

CREATE UNIQUE INDEX UX_DimProducto_NK_Activo1
  ON dw.DimProducto(ProductID) WHERE Activo = 1;
CREATE UNIQUE INDEX UX_DimProducto_NK_FechaInicio
  ON dw.DimProducto(ProductID, FechaInicio);
ALTER TABLE dw.DimProducto WITH CHECK ADD CONSTRAINT CK_DimProducto_Fechas
  CHECK ( (Activo = 1 AND FechaFin IS NULL)
       OR (Activo = 0 AND FechaFin IS NOT NULL AND FechaFin > FechaInicio) );

-- Fila Bolson
SET IDENTITY_INSERT dw.DimProducto ON;
IF NOT EXISTS (SELECT 1 FROM dw.DimProducto WHERE ProductKey = 0)
INSERT INTO dw.DimProducto (ProductKey, ProductID, ProductSKU, ProductName, ProductCategory, ItemGroup, KitType, Channels, Demographic, RetailPrice, Activo, FechaInicio, FechaFin)
    VALUES (0, -1, N'DESCONOCIDA', N'Desconocido', N'Desconocido', N'Desconocido', N'Desconocido', 0, N'Desconocido', 0.00, 1, '19000101', NULL);
SET IDENTITY_INSERT dw.DimProducto OFF;
GO


--DimGeografia

IF OBJECT_ID('dw.DimGeografia') IS NOT NULL DROP TABLE dw.DimGeografia;
CREATE TABLE dw.DimGeografia (
  GeografiaKey   int IDENTITY(1,1) PRIMARY KEY,
  
  StateID        int            NOT NULL,
  StateCode      nvarchar(50)    NOT NULL,
  StateName      nvarchar(50)   NOT NULL,
  TimeZone       nvarchar(50)   NOT NULL,
  RegionID       int            NOT NULL,
  RegionName     nvarchar(50)   NOT NULL,
  
  Activo         bit            NOT NULL DEFAULT 1,
  FechaInicio    datetime2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
  FechaFin       datetime2(0)   NULL
);

CREATE UNIQUE INDEX UX_DimGeografia_NK_Activo1
  ON dw.DimGeografia(StateID) WHERE Activo = 1;
CREATE UNIQUE INDEX UX_DimGeografia_NK_FechaInicio
  ON dw.DimGeografia(StateID, FechaInicio);
ALTER TABLE dw.DimGeografia WITH CHECK ADD CONSTRAINT CK_DimGeografia_Fechas
  CHECK ( (Activo = 1 AND FechaFin IS NULL)
       OR (Activo = 0 AND FechaFin IS NOT NULL AND FechaFin > FechaInicio) );

SET IDENTITY_INSERT dw.DimGeografia ON;
IF NOT EXISTS (SELECT 1 FROM dw.DimGeografia WHERE GeografiaKey = 0)
INSERT INTO dw.DimGeografia (GeografiaKey, StateID, StateCode, StateName, TimeZone, RegionID, RegionName, Activo, FechaInicio, FechaFin)
VALUES (0, -1, N'Desconocido', N'Desconocido', N'Desconocido', -1, N'Desconocido', 1, '19000101', NULL);
SET IDENTITY_INSERT dw.DimGeografia OFF;
GO


--DimPromocion

IF OBJECT_ID('dw.DimPromocion') IS NOT NULL DROP TABLE dw.DimPromocion;
CREATE TABLE dw.DimPromocion (
  PromocionKey  int IDENTITY(1,1) PRIMARY KEY,

  PromotionCode nvarchar(20)   NOT NULL,
  Descripcion   nvarchar(200)  NULL,
  Activo        bit            NOT NULL DEFAULT 1,
  FechaInicio   datetime2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
  FechaFin      datetime2(0)   NULL
);

CREATE UNIQUE INDEX UX_DimPromocion_NK_Activo1
  ON dw.DimPromocion(PromotionCode) WHERE Activo = 1;
CREATE UNIQUE INDEX UX_DimPromocion_NK_FechaInicio
  ON dw.DimPromocion(PromotionCode, FechaInicio);
ALTER TABLE dw.DimPromocion WITH CHECK ADD CONSTRAINT CK_DimPromocion_Fechas
  CHECK ( (Activo = 1 AND FechaFin IS NULL)
       OR (Activo = 0 AND FechaFin IS NOT NULL AND FechaFin > FechaInicio) );

SET IDENTITY_INSERT dw.DimPromocion ON;
IF NOT EXISTS (SELECT 1 FROM dw.DimPromocion WHERE PromocionKey = 0)
INSERT INTO dw.DimPromocion (PromocionKey, PromotionCode, Descripcion, Activo, FechaInicio, FechaFin)
VALUES (0, N'DESCONOCIDO', N'Desconocido', 1, '19000101', NULL);
SET IDENTITY_INSERT dw.DimPromocion OFF;
GO

--DimOficinaVentas

IF OBJECT_ID('dw.DimOficinaVentas') IS NOT NULL DROP TABLE dw.DimOficinaVentas;
CREATE TABLE dw.DimOficinaVentas (
  OficinaVentasKey int IDENTITY(1,1) PRIMARY KEY,

  SalesOfficeID    int            NOT NULL,
  AddressLine1     nvarchar(100)  NOT NULL,
  AddressLine2     nvarchar(100)  NULL,
  City             nvarchar(50)   NOT NULL,
  StateID          int            NOT NULL,
  StateName      nvarchar(50)   NOT NULL,
  PostalCode       nchar(5)       NOT NULL,
  Telephone        nvarchar(20)   NULL,
  Facsimile        nvarchar(20)   NULL,
  Email            nvarchar(50)   NULL,

  Activo           bit            NOT NULL DEFAULT 1,
  FechaInicio      datetime2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
  FechaFin         datetime2(0)   NULL
);

CREATE UNIQUE INDEX UX_DimOficina_NK_Activo1
  ON dw.DimOficinaVentas(SalesOfficeID) WHERE Activo = 1;
CREATE UNIQUE INDEX UX_DimOficina_NK_FechaInicio
  ON dw.DimOficinaVentas(SalesOfficeID, FechaInicio);
ALTER TABLE dw.DimOficinaVentas WITH CHECK ADD CONSTRAINT CK_DimOficina_Fechas
  CHECK ( (Activo = 1 AND FechaFin IS NULL)
       OR (Activo = 0 AND FechaFin IS NOT NULL AND FechaFin > FechaInicio) );

SET IDENTITY_INSERT dw.DimOficinaVentas ON;
IF NOT EXISTS (SELECT 1 FROM dw.DimOficinaVentas WHERE OficinaVentasKey = 0)
INSERT INTO dw.DimOficinaVentas (OficinaVentasKey, SalesOfficeID, AddressLine1, AddressLine2, City, StateID, StateName,PostalCode, Telephone, Facsimile, Email, Activo, FechaInicio, FechaFin)
VALUES (0, -1, N'Desconocido', 'Desconocido', N'Desconocido', -1, 'Desconocido', N'00000', 'No hay telefono', 'Desconocido', 'No hay email', 1, '19000101', NULL);
SET IDENTITY_INSERT dw.DimOficinaVentas OFF;
GO

--DimTiempo

IF OBJECT_ID('dw.DimTiempo') IS NOT NULL DROP TABLE dw.DimTiempo;
create table dw.DimTiempo
(TiempoKey int primary key, --Llave surrogada
Fecha datetime not null,
Dia tinyint not null,
Mes tinyint not null,
Anio smallint not null)
go

IF NOT EXISTS (SELECT 1 FROM dw.DimTiempo WHERE TiempoKey = 0)
INSERT INTO dw.DimTiempo (TiempoKey, Fecha,Dia ,Mes, Anio )
VALUES (0, '',0,0,0);
GO


--FactVentas

IF OBJECT_ID('dw.FactVentas') IS NOT NULL DROP TABLE dw.FactVentas;
CREATE TABLE dw.FactVentas (
  FactVentasKey   bigint IDENTITY(1,1) PRIMARY KEY,


  OrderDateKey    int            NOT NULL,  
  ShipDateKey     int            NULL,       
  ProductKey      int            NOT NULL,   
  GeografiaKey    int            NOT NULL,   
  PromocionKey    int            NOT NULL    CONSTRAINT DF_FV_PromocionKey     DEFAULT (0),
  OficinaVentasKey int           NOT NULL    CONSTRAINT DF_FV_OficinaVentasKey DEFAULT (0), 

  OrderNumber     nchar(10)      NOT NULL,
  Quantity        int            NOT NULL,
  UnitPrice       decimal(9,2)   NOT NULL,
  DiscountAmount  decimal(9,2)   NOT NULL,
  CustomerStateID int            NOT NULL,
);

ALTER TABLE dw.FactVentas
  ADD CONSTRAINT FK_FV_OrderDate
      FOREIGN KEY (OrderDateKey)    REFERENCES dw.DimTiempo(TiempoKey);

ALTER TABLE dw.FactVentas
  ADD CONSTRAINT FK_FV_ShipDate
      FOREIGN KEY (ShipDateKey)     REFERENCES dw.DimTiempo(TiempoKey);

ALTER TABLE dw.FactVentas
  ADD CONSTRAINT FK_FV_Product
      FOREIGN KEY (ProductKey)      REFERENCES dw.DimProducto(ProductKey);

ALTER TABLE dw.FactVentas
  ADD CONSTRAINT FK_FV_Geografia
      FOREIGN KEY (GeografiaKey)    REFERENCES dw.DimGeografia(GeografiaKey);

ALTER TABLE dw.FactVentas
  ADD CONSTRAINT FK_FV_Promocion
      FOREIGN KEY (PromocionKey)    REFERENCES dw.DimPromocion(PromocionKey);

ALTER TABLE dw.FactVentas
  ADD CONSTRAINT FK_FV_Oficina
      FOREIGN KEY (OficinaVentasKey) REFERENCES dw.DimOficinaVentas(OficinaVentasKey);
GO


/*Procedimientos almacenados*/

--Actaulizar DimGeografia
create or alter procedure [dw].[ActualizarGeografia](@GeografiaKey int, @StateCode nvarchar(50), @StateName nvarchar(50), 
@TimeZone nvarchar(50), @RegionID int, @RegionName nvarchar(50))

AS
Begin

declare @StateCodeActual nvarchar(50), 
		@StateNameActual nvarchar(50), 
		@TimeZoneActual nvarchar(50), 
		@RegionIDActual int, 
		@RegionNameActual nvarchar(50),
		@StateID int 

select @StateCodeActual=StateCode, @StateNameActual=StateName, @TimeZoneActual=TimeZone, @RegionIDActual=RegionID,
@RegionNameActual=RegionName, @StateID=StateID
from dw.DimGeografia 
where GeografiaKey=@GeografiaKey

if(@StateCodeActual<>@StateCode or @StateNameActual<>@StateName or @TimeZoneActual<>@TimeZone or  
@RegionIDActual<>@RegionID or @RegionNameActual<>@RegionName)
begin
	update dw.DimGeografia set Activo=0, fechafin=getdate() where GeografiaKey=@GeografiaKey
	insert into dw.DimGeografia (StateID, StateCode, StateName, TimeZone, RegionID, RegionName)
	values(@StateID, @StateCode,@StateName,@TimeZone,@RegionID,@RegionName)
end
end


--Actualizar DimProducto
create or alter procedure [dw].[ActualizarProducto](@ProductKey int, @ProductSKU nvarchar(50),@ProductName nvarchar(50), 
@ProductCategory nvarchar(50), @ItemGroup nvarchar(50), @KitType nvarchar(50), @Channels tinyint, @Demographic nvarchar(50), @RetailPrice decimal(18,2))
AS
Begin

declare @ProductSKUActual nvarchar(50),
        @ProductNameActual nvarchar(50),
        @ProductCategoryActual nvarchar(50),
        @ItemGroupActual nvarchar(50),
        @KitTypeActual nvarchar(50),
        @ChannelsActual tinyint,
        @DemographicActual nvarchar(50),
        @RetailPriceActual decimal(18,2),
        @ProductID int

select @ProductSKUActual=ProductSKU, @ProductNameActual=ProductName, @ProductCategoryActual=ProductCategory, @ItemGroupActual=ItemGroup,
@KitTypeActual=KitType, @ChannelsActual=Channels, @DemographicActual=Demographic, @RetailPriceActual=RetailPrice, @ProductID=ProductID
from dw.DimProducto 
Where ProductKey=@ProductKey

if(@ProductSKUActual<>@ProductSKU or @ProductNameActual<>@ProductName or @ProductCategoryActual<>@ProductCategory or @ItemGroupActual<>@ItemGroup or
@KitTypeActual<>@KitType or @ChannelsActual<>@Channels or @DemographicActual<>@Demographic or @RetailPriceActual<>@RetailPrice)
begin
    update dw.DimProducto set Activo=0, fechafin=getdate() where ProductKey=@ProductKey
    insert into dw.DimProducto (ProductID, ProductSKU, ProductName, ProductCategory, ItemGroup, KitType, Channels, Demographic, RetailPrice)
    Values(@ProductID, @ProductSKU, @ProductName, @ProductCategory, @ItemGroup, @KitType, @Channels, @Demographic, @RetailPrice)

end
end


-- Actualizar DimProducto

Create or Alter Procedure [dw].[ActualizarPromocion](@PromocionKey int, @PromotionCode nvarchar(20), @Descripcion nvarchar(200))
as 
begin

declare @PromotionCodeActual nvarchar(20),
        @DescripcionActual nvarchar(200)

select @PromotionCodeActual=PromotionCode,
@DescripcionActual=Descripcion
from dw.DimPromocion 
where PromocionKey=@PromocionKey

if(@PromotionCodeActual<>@PromotionCode or @DescripcionActual<>@Descripcion)
begin
    update dw.DimPromocion set Activo=0, FechaFin=getdate() where PromocionKey=@PromocionKey - 1
    insert into dw.DimPromocion (PromotionCode, Descripcion)
    values(@PromotionCode, @Descripcion)
end
end


-- Actualizar DimOficinaVentas

create or alter Procedure [dw].[ActualizarOficinaVentas] (@OficinaVentasKey int, @AddressLine1 nvarchar(100), @AddressLine2 nvarchar(100),
@City nvarchar(50), @StateID int, @StateName nvarchar(50), @PostalCode nchar(5), @Telephone nvarchar(20), @Facsimile nvarchar(20),
@Email nvarchar(50))
AS
BEGIN 
Declare @AddressLine1Actual nvarchar(100),
        @AddressLine2Actual nvarchar(100),
        @CityActual nvarchar(50),
        @StateIDActual int,
        @StateNameActual nvarchar(50),
        @PostalCodeActual nchar(5),
        @TelephoneActual nvarchar(20),
        @FacsimileActual nvarchar(20),
        @EmailActual nvarchar(50),
        @SalesOfficeID int

select @AddressLine1Actual=AddressLine1, @AddressLine2Actual=AddressLine2, @CityActual=City, @StateIDActual=StateID,
@StateNameActual=StateName, @PostalCodeActual=PostalCode, @TelephoneActual=Telephone, @FacsimileActual=Facsimile,
@EmailActual=Email, @SalesOfficeID=SalesOfficeID
from dw.DimOficinaVentas 
where OficinaVentasKey=@OficinaVentasKey

if(@AddressLine1Actual<>@AddressLine1 or @AddressLine2Actual<>@AddressLine2 or @CityActual<>@City or @StateIDActual<>@StateID or 
@StateNameActual<>@StateName or @PostalCodeActual<>@PostalCode or @TelephoneActual<>@Telephone or @FacsimileActual<>@Facsimile or 
@EmailActual<>@Email)
begin
    update dw.DimOficinaVentas set Activo=0, FechaFin=GETDATE() where OficinaVentasKey=@OficinaVentasKey
    insert into dw.DimOficinaVentas(SalesOfficeID, AddressLine1, AddressLine2, City, StateID, StateName, PostalCode, Telephone, Facsimile, Email)
    values (@SalesOfficeID, @AddressLine1, @AddressLine2, @City, @StateID, @StateName, @PostalCode, @Telephone, @Facsimile, @Email)
end
end


-- Llenar DimTiempo--------------------------------------------------------------------------------
-- =========================================================
-- Parámetros de rango de fechas
-- =========================================================
DECLARE @FechaInicio DATE = '2010-01-01';
DECLARE @FechaFin    DATE = '2035-12-31';

;WITH Calendario AS
(
    SELECT @FechaInicio AS Fecha
    UNION ALL
    SELECT DATEADD(DAY, 1, Fecha)
    FROM   Calendario
    WHERE  Fecha < @FechaFin
)
INSERT INTO dw.DimTiempo (TiempoKey, Fecha, Dia, Mes, Anio)
SELECT
    ROW_NUMBER() OVER (ORDER BY Fecha) AS TiempoKey,  -- 1..N (0 ya reservado)
    CAST(Fecha AS DATETIME)             AS Fecha,
    DAY(Fecha)                          AS Dia,
    MONTH(Fecha)                        AS Mes,
    YEAR(Fecha)                         AS Anio
FROM Calendario
OPTION (MAXRECURSION 0);

-- Verifica
SELECT TOP (10) * FROM dw.DimTiempo ORDER BY TiempoKey;
