select * from Region;

Select * from State;




Select distinct TimeZone from State;

--Leer DimGeografia

SELECT
  s.StateID,
  s.StateCode,
  s.StateName,
  ISNULL(case TimeZone
  when 'AKST' THEN 'Hora est�ndar de Alaska'
  when 'CST' THEN 'Hora est�ndar del centro'
  when 'EST' THEN 'Hora est�ndar del este'
  when 'HST' THEN 'Hora est�ndar de Haw�i-Aleutianas'
  when 'MST' THEN 'Hora est�ndar de la monta�a'
  when 'PST' THEN 'Hora est�ndar del Pac�fico'
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


select * from product

