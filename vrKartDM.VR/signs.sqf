_zoraZone = _this select 0;
_zoraPos = getPos _zoraZone;

_sizeZone = triggerArea _zoraZone;
_angle = _sizeZone select 2;
_radius = _sizeZone select 0; // needs to be a circle with equal a and b
_distanceBetweenPosts = 20; // meters
_count = round((2 * 3.14592653589793 * _radius) / _distanceBetweenPosts);
_step = 360/_count;

for "_x" from 0 to _count do
{
	_a = (_zoraPos select 0)+(sin(_angle)*_radius);
	_b = (_zoraPos select 1)+(cos(_angle)*_radius);

	_pos = [_a,_b,(_zoraPos select 2) + 0];
	_angle = _angle + _step;
	
	//Land_VR_Block_01_F
	//Land_VR_CoverObject_01_stand_F
	
	_post = "Land_VR_Block_01_F" createVehicle _pos;
	_post setPos _pos;
	_post setDir (_angle + 90);
};

