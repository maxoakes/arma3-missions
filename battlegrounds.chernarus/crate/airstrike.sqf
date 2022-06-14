package removeAction addActionBomb;
openMap true;
_clicked = false;
onMapSingleClick "

	[_pos] execVM 'crate\spawnPlane.sqf';
	
	_clicked = true; onMapSingleClick ''; 
	openMap false; 
	true;
	";