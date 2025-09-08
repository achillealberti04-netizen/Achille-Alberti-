
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Select SaleDateConverted, CONVERT(Date,SaleDate) 
From "master"..NashvilleHousing nas

Update NashvilleHousing
	Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing 
	Set SaleDateConverted = CONVERT(Date,SaleDate);


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Select *
From "master"..NashvilleHousing 
	 Where PropertyAddress is null 
Order by ParcelID

Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From "master"..NashvilleHousing a
JOIN "master"..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Update a 
Set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From "master"..NashvilleHousing a
JOIN "master"..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Select 
Substring(PropertyAddress, 1, Charindex(',',PropertyAddress) -1) as Adress, 
Substring(PropertyAddress, Charindex(',',PropertyAddress) -1, Len(PropertyAddress)) as Adress
From "master"..NashvilleHousing 
Order by ParcelID

Alter Table NashvilleHousing 
Add SplitPropertyAdress Nvarchar(255);

Update NashvilleHousing 
	Set SplitPropertyAdress = Substring(PropertyAddress, 1, Charindex(',',PropertyAddress) -1);

Alter Table NashvilleHousing 
Add SplitPropertyCity Nvarchar(255);

Update NashvilleHousing 
	Set SplitPropertyCity = Substring(PropertyAddress, Charindex(',',PropertyAddress) -1, Len(PropertyAddress));

Select OwnerAddress
From "master"..NashvilleHousing 

Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From "master"..NashvilleHousing 

Alter Table NashvilleHousing 
Add SplitOwnerAdress Nvarchar(255);

Update NashvilleHousing 
	Set SplitOwnerAdress = Parsename(Replace(OwnerAddress, ',', '.'), 3);

Alter Table NashvilleHousing 
Add SplitOwnerCity Nvarchar(255);

Update NashvilleHousing 
	Set SplitOwnerCity = Parsename(Replace(OwnerAddress, ',', '.'), 2);

Alter Table NashvilleHousing 
Add SplitOwnerST Nvarchar(255);

Update NashvilleHousing 
	Set SplitOwnerST = Parsename(Replace(OwnerAddress, ',', '.'), 1)

Select *
From "master"..NashvilleHousing 


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacation" field
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Select Distinct (SoldAsVacant), count(SoldAsVacant)
From "master"..NashvilleHousing 
Group by SoldAsVacant
	Order by 2


Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant 
	END 
From "master"..NashvilleHousing;


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Dublicates
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM "master"..NashvilleHousing
)
SELECT *
FROM RowNumCTE

Select * 
From RowNumCTE
	Where row_num > 1 
	Order by PropertyAddress


WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM "master"..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Unuse Columns  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 

Alter Table "master"..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From "master"..NashvilleHousing






