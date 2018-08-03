exports.INSERT_USER_PROFILE =
`INSERT INTO userprofiles \
(\
Id,\
FirstName,\
LastName,\
UserId,\
ProfilePictureUri,\
Rating,\
Ranking,\
TotalDistance,\
TotalTrips,\
TotalTime,\
HardStops,\
HardAccelerations,\
FuelConsumption,\
MaxSpeed,\
CreatedAt,\
UpdatedAt,\
Deleted\
) \
SELECT \
Id,\
FirstName,\
LastName,\
UserId,\
ProfilePictureUri,\
Rating,\
Ranking,\
TotalDistance,\
TotalTrips,\
TotalTime,\
HardStops,\
HardAccelerations,\
FuelConsumption,\
MaxSpeed,\
GETDATE(),\
GETDATE(),\
Deleted \
FROM OPENJSON(@UserProfileJson) \
WITH (
Id nvarchar(128),\
FirstName nvarchar(max),\
LastName nvarchar(max),\
UserId nvarchar(max),\
ProfilePictureUri nvarchar(max),\
Rating int,\
Ranking int,\
TotalDistance float(53),\
TotalTrips bigint,\
TotalTime bigint,\
HardStops bigint,\
HardAccelerations bigint,\
FuelConsumption float(53),\
MaxSpeed float(53),\
Deleted bit\
) AS JSON`;

exports.SELECT_USER_PROFILE_BY_ID=
 'select * from userprofiles where id = @user_profile_id FOR JSON PATH';

exports.SELECT_USER_PROFILES=
 'select * FROM userprofiles FOR JSON PATH';

exports.DELETE_USER_PROFILE=
 'UPDATE userprofiles SET Deleted = 1 WHERE id = @user_profile_id';