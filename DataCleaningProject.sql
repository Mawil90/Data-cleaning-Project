/*
Cleaning Data in SQL Queries 

*/

Select * 
From SQLPORTFOLIO..NashvilleHousing

--Update SaleDate to get rid of empty time information

Select SaleDateConverted, CONVERT(Date, SaleDate) 
From SQLPORTFOLIO..NashvilleHousing

Alter Table NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data 

Select * 
From SQLPORTFOLIO..NashvilleHousing
Order by ParcelID


Select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLPORTFOLIO..NashvilleHousing a
Join SQLPORTFOLIO..NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
	Where a.PropertyAddress is null 

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLPORTFOLIO..NashvilleHousing a
Join SQLPORTFOLIO..NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
	Where a.PropertyAddress is null 

--Breaking out Address into individual columns(Address, City, State)

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
From SQLPORTFOLIO..NashvilleHousing

Alter Table NashvilleHousing 
Add PropertySplitAddress NVarChar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing 
Add PropertySplitCity  NVarChar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SQLPORTFOLIO..NashvilleHousing

Alter Table NashvilleHousing 
Add OwnerSplitAddress NVarChar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table NashvilleHousing 
Add OwnerSplitCity  NVarChar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter Table NashvilleHousing 
Add OwnerSplitState  NVarChar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--Change Y and N to Yes and No  in "Sold as Vacant" field

Select Distinct (SoldAsVacant)
From SQLPORTFOLIO..NashvilleHousing

Select SoldasVacant, COUNT(SoldAsVacant)
From SQLPORTFOLIO..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
,CASE WHEN SoldasVacant = 'Y' THEN 'YES'
	WHEN SoldasVacant = 'N' THEN 'NO'
	ELSE SoldasVacant
	END
From SQLPORTFOLIO..NashvilleHousing


Update NashvilleHousing
Set SoldasVacant =
CASE WHEN SoldasVacant = 'Y' THEN 'YES'
	WHEN SoldasVacant = 'N' THEN 'NO'
	ELSE SoldasVacant
	END


--Remove Duplicates 
WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePRice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From SQLPORTFOLIO..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1


--Delete Unused Columns 

Select *
From SQLPORTFOLIO..NashvilleHousing

ALTER TABLE SQLPORTFOLIO..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress

