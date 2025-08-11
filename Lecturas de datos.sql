--Scripts para leer de la base de datos fuente 

select * from Region;

Select * from State;

use [TailspinToys2020-US]
go


Select distinct TimeZone from State;

--Leer DimGeografia

SELECT
  s.StateID,
  s.StateCode,
  s.StateName,
  ISNULL(case TimeZone
  when 'AKST' THEN 'Hora estándar de Alaska'
  when 'CST' THEN 'Hora estándar del centro'
  when 'EST' THEN 'Hora estándar del este'
  when 'HST' THEN 'Hora estándar de Hawái-Aleutianas'
  when 'MST' THEN 'Hora estándar de la montaña'
  when 'PST' THEN 'Hora estándar del Pacífico'
  else s.TimeZone END, 'Zona horario no definida') as ZonaHoraria,
  s.RegionID,
  r.RegionName
FROM dbo.[State] AS s
LEFT JOIN dbo.[Region] AS r
  ON r.RegionID = s.RegionID



--Leer DimProducto

select 
p.ProductID,
p.ProductSKU,
p.ProductName,
p.ProductCategory,
p.ItemGroup,
case KitType 
when 'RTF' THEN 'Listo para Volar'
when 'KIT' THEN 'Kit de Montaje'
else p.KitType END as KitType,
p.Channels,
p.Demographic,
p.RetailPrice
from Product AS p


-- Leer DimPromocion

select 
distinct PromotionCode,
descripcion = 'Sin Descripcion'
from Sales as sal where PromotionCode IS NOT NULL

select * from SalesOffice


-- Leer DimOficinaVentas

select so.SalesOfficeID, so.AddressLine1, so.AddressLine2, so.City, s.StateID, s.StateName,
so.PostalCode, so.Telephone, so.Facsimile, so.Email
from SalesOffice as so
inner join State as s
on so.StateID=s.StateID

-- Leer FactVentas

use [TailspinToys2020-US];
SELECT
    s.OrderNumber,
    s.Quantity,
    s.UnitPrice,
    s.DiscountAmount,
    s.CustomerStateID,        -- FK al estado del cliente
    s.PromotionCode,
    s.ProductID,
    s.ShipDate,
    s.OrderDate,
    st.StateID              -- Es el mismo valor que CustomerStateID
FROM dbo.Sales AS s
INNER JOIN dbo.State AS st
    ON st.StateID = s.CustomerStateID;

use DWVentasTailSpinToys;
select * from dw.FactVentas

use [TailspinToys2020-US];
SELECT
    isNULL(s.OrderNumber, '') AS OrderNumber,
    s.Quantity,
    s.UnitPrice,
    s.DiscountAmount,
    s.CustomerStateID,
    isNULL(so_pick.SalesOfficeID, -1) as SalesOfficeID,   -- Oficina elegida por estado (TOP 1)
    isNULL(s.PromotionCode, 'DESCONOCIDO') AS PromotionCode, 
    s.ProductID,
    isNULL(CAST(s.ShipDate AS datetime ), CONVERT(datetime,'19000101',112)) as ShipDate,
    isNULL(CAST(s.OrderDate AS datetime), CONVERT(datetime,'19000101',112)) as OrderDate,
    st.StateID
FROM Sales AS s
INNER JOIN State AS st
    ON st.StateID = s.CustomerStateID
OUTER APPLY (
    SELECT TOP 1 so.SalesOfficeID
    FROM SalesOffice AS so
    WHERE so.StateID = st.StateID
    ORDER BY so.SalesOfficeID
) AS so_pick;

