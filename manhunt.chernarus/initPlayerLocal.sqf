params ["_player", "_didJIP"];

//create diary entry for all players
_player createDiaryRecord ["Diary", [localize "STR_DIARY_INITIAL_TITLE", localize "STR_DIARY_INITIAL_TEXT"], taskNull, "", false];
_player createDiaryRecord ["Diary", [localize "STR_DIARY_ENEMIES_TITLE", localize "STR_DIARY_ENEMIES_TEXT"], taskNull, "", false];