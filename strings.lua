function data()

	return {
		en = {
			["arr_i18n"] = "Arr",
			["arrival_i18n"] = "Arrival",
			["dep_i18n"] = "Dep",
			["departure_i18n"] = "Departure",
			["unbunch_time_i18n"] = "Unbunch Time";
			["unbunch_i18n"] = "Unbunch",
			["timetable_i18n"] = "Timetable",
			["timetables_i18n"] = "Timetables",
			["line_i18n"] = "Line",
			["lines_i18n"] = "Lines",
			["time_min_i18n"] = "min",
			["time_sec_i18n"] = "sec",
			["stations_i18n"] = "Stations",
			["frequency_i18n"] = "Frequency",
			["journey_time_i18n"] = "Journey Time",
			["arr_dep_i18n"] = "Arrival/Departure",
			["no_timetable_i18n"] = "No Timetable",
			["all_i18n"] = "All",
			["add_i18n"] = "Add",
			["none_i18n"] = "None",
			["tooltip_i18n"] = (
     		    "You can add timetable constraints to each station.\n" ..
        		"When a train arrives at the station it will try to \n" ..
        		"keep the constraints. The following constraints are awailabe: \n" ..
        		"  - Arrival/Departure: Set multiple Arr/Dep times and the train \n"..
        		"                                      chooses the closes arrival time\n" ..
        		"  - Unbunch: Set a time and vehicles will only depart the station in the given interval"
    			),
		},
		
		de = {
			["arr_i18n"] = "An",
			["arrival_i18n"] = "Ankunft",
			["dep_i18n"] = "Ab",
			["departure_i18n"] = "Departure",
			["unbunch_time_i18n"] = "Ungebündelte Zeit", --????;
			["unbunch_i18n"] = "Umstieg", --????
			["timetable_i18n"] = "Fahrplan",
			["timetables_i18n"] = "Fahrpläne",
			["line_i18n"] = "Linie",
			["lines_i18n"] = "Linien",
			["time_min_i18n"] = "Min",
			["time_sec_i18n"] = "Sek",
			["stations_i18n"] = "Stationen",
			["frequency_i18n"] = "Frequenz",
			["journey_time_i18n"] = "Fahrzeit",
			["arr_dep_i18n"] = "Ankunft/Abfahrt",
			["no_timetable_i18n"] = "Kein Fahrplan",
			["all_i18n"] = "Alle",
			["add_i18n"] = "Hinzufügen",
			["none_i18n"] = "Keine",
			["tooltip_i18n"] = (
     		    "Du kannst für jede Station Bedingungen setzen.\n" ..
        		"WEnn ein Zug an einer Station ankommt, versucht er die \n" ..
        		"Bedingungen einzuhalten. Folgende Bedinungen gibt es: \n" ..
        		"  - Ankunft/Abfahrt: Seitze merhere Ank/Abf Zeiten und der Zug \n"..
        		"                             wählt die naheste Ankunftszeit\n" ..
        		"  - Unbunch: Setze eine Zeit, so dass der Zug die Station nur zu einem bestimmten Intervall verlässt"
    			),
		}
	}
	end