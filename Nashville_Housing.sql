-- Cleaning Data

select *
from Portfolio.dbo.nashvillehousing

------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date format
select SaleDateConverted, CONVERT(date,SaleDate)
from Portfolio.dbo.nashvillehousing

UPDATE nashvillehousing
SET SaleDate = CONVERT(date,SaleDate);

ALTER TABLE nashvillehousing
Add SaleDateConverted date;

UPDATE nashvillehousing
SET SaleDateConverted = CONVERT(date,SaleDate)

-------------------------------------------------------------------------------------------------------------------------------------------

-- Populate proprety adress data
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio.dbo.nashvillehousing a
JOIN Portfolio.dbo.nashvillehousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio.dbo.nashvillehousing a
JOIN Portfolio.dbo.nashvillehousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---------------------------------------------------


-- Breaking out Address into Individual columns (Adress, City, State)
select PropertyAddress
from Portfolio.dbo.nashvillehousing

select 
SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address

from Portfolio.dbo.nashvillehousing


ALTER TABLE nashvillehousing
Add PropertySplitAddress Nvarchar(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE nashvillehousing
Add PropertySplitCity Nvarchar(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))



select *
from Portfolio.dbo.nashvillehousing


-- Split Owner address 

select OwnerAddress
from Portfolio.dbo.nashvillehousing


select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from Portfolio.dbo.nashvillehousing


ALTER TABLE nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE nashvillehousing
Add OwnerSplitCity Nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE nashvillehousing
Add OwnerSplitState Nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-- recheck if the coluomns are added in the table

select *
from Portfolio.dbo.nashvillehousing


----------------------------------------------------------------------------------------------

-- Change N and Y to No and Yes in "Sold as Vacant" field


select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Portfolio.dbo.nashvillehousing
Group By SoldAsVacant
Order By 2

select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from Portfolio.dbo.nashvillehousing

UPDATE nashvillehousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS
(
select *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
                 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				    UniqueID
					) row_num
from Portfolio.dbo.nashvillehousing
)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress
	             

----------------------------------------------------------------------------------------------------------------------
-- Delete Unused Data

select *
from Portfolio.dbo.nashvillehousing

ALTER TABLE Portfolio.dbo.nashvillehousing
DROP COLUMN OwnerAddress,SaleDate,TaxDistrict,PropertyAddress



