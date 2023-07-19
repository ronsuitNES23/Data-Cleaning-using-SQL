--- Cleaning Data
Select *
From nashville_housing


--- Standardizing dates

Select ProperDate, CONVERT(Date, SaleDate)
From nashville_housing

Update nashville_housing
SET SaleDate = CONVERT(Date,SaleDate)

select *
FROM nashville_housing

ALTER TABLE nashville_housing
ADD ProperDate Date;

Update nashville_housing
SET ProperDate = CONVERT(Date,SaleDate)

select *
FROM nashville_housing




--- populating address
SELECT *
FROM nashville_housing
-- where PropertyAddress is NULL
ORDER BY ParcelID 


-- To populate the address, we'd have to JOIN the dataset on its self

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] -- this means that the UniqueID's will not duplicate
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--- Breaking out Address into Individual Columns (Address, City, State)
-- We wil use subqueries and a CHAR index
SELECT PropertyAddress
FROM nashville_housing
-- where PropertyAddress is NULL
--ORDER BY ParcelID 

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1), LEN(PropertyAddress)) AS address
FROM nashville_housing

SELECT
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS address
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD PropertySplitAddress NVARCHAR(255);

Update nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE nashville_housing
ADD PropertySplitCity NVARCHAR(255);

Update nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT*
FROM nashville_housing

-- Trying to change the owner address

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as state,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as city,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as street
FROM nashville_housing
ORDER BY city desc

ALTER TABLE nashville_housing
ADD OwnerSplitState NVARCHAR(255);

Update nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE nashville_housing
ADD OwnerSplitCity NVARCHAR(255);

Update nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE nashville_housing
ADD OwnerSplitStreet NVARCHAR(255);

Update nashville_housing
SET OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


SELECT*
FROM nashville_housing

-- Change Y and N to Yes and No in "Sold as Vacant" field



SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

--Using a CASE Statement

SELECT SoldAsVacant
,	CASE WHEN SoldAsVacant  = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N'THEN 'No'
	ELSE SoldAsVacant
	END
FROM nashville_housing

Update nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant  = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N'THEN 'No'
	ELSE SoldAsVacant
	END








-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num

FROM nashville_housing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1



SELECT *
FROM nashville_housing







-- Delete Unused Columns



ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

SELECT *
FROM nashville_housing