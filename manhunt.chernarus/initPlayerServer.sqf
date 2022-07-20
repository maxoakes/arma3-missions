params ["_playerUnit", "_didJIP"];

//create diary entry for all players
_playerUnit createDiaryRecord [
	"Diary", 
	[localize "STR_DIARY_INITIAL_TITLE", localize "STR_DIARY_INITIAL_TEXT"], 
	taskNull, "", false
];