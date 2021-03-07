function data()

    return {
        en = {
            ["arr_i18n"] = "Arr: ",
            ["arrival_i18n"] = "Arrival",
            ["dep_i18n"] = "Dep: ",
            ["departure_i18n"] = "Departure",
            ["unbunch_time_i18n"] = "Unbunch Time",
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
                "keep the constraints. The following constraints are available: \n" ..
                "  - Arrival/Departure: Set multiple Arr/Dep times and the train \n" ..
                "                                      chooses the closest arrival time\n" ..
                "  - Unbunch: Set a time and vehicles will only depart the station in the given interval"
                ),
            ["mod_name_i18n"] = "Timetables",
            ["mod_description_i18n"] = "This mod adds timetables to the game",
        },

        de = {
            ["arr_i18n"] = "An: ",
            ["arrival_i18n"] = "Ankunft",
            ["dep_i18n"] = "Ab: ",
            ["departure_i18n"] = "Abfahrt",
            ["unbunch_time_i18n"] = "Taktzeit", -- ????;
            ["unbunch_i18n"] = "Takt", -- ????
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
            ["add_i18n"] = "+",
            ["none_i18n"] = "Keine",
            ["tooltip_i18n"] = (
                "Du kannst für jede Station Bedingungen setzen.\n" ..
                "Wenn ein Zug an einer Station ankommt, versucht er die \n" ..
                "Bedingungen einzuhalten. Folgende Bedingungen gibt es: \n" ..
                "  - Ankunft/Abfahrt: Setze mehrere Ank/Abf Zeiten und der Zug \n" ..
                "                     wählt die naheste Ankunftszeit\n" ..
                "  - Takt: Setze eine Zeit, so dass der Zug die Station nur zu einem bestimmten Intervall verlässt"
                ),
            ["mod_name_i18n"] = "Fahrpläne",
            ["mod_description_i18n"] = "Diese Mod fügt dem Spiel Fahrpläne hinzu",
        },

        ru = {
            ["arr_i18n"] = "Приб.: ",
            ["arrival_i18n"] = "Прибытие ",
            ["dep_i18n"] = "Отпр.: ",
            ["departure_i18n"] = "Отправ. ",
            ["unbunch_time_i18n"] = "Время интервала",
            ["unbunch_i18n"] = "Интервал",
            ["timetable_i18n"] = "Расписание",
            ["timetables_i18n"] = "Окно расписаний",
            ["line_i18n"] = "Линия",
            ["lines_i18n"] = "Линии",
            ["time_min_i18n"] = "мин.",
            ["time_sec_i18n"] = "сек.",
            ["stations_i18n"] = "Станции",
            ["frequency_i18n"] = "Частота",
            ["journey_time_i18n"] = "Время поездки",
            ["arr_dep_i18n"] = "Прибытие/Отправление",
            ["no_timetable_i18n"] = "Нет расписания",
            ["all_i18n"] = "Все",
            ["add_i18n"] = "Добавить",
            ["none_i18n"] = "Отсутствует",
            ["tooltip_i18n"] = (
                "Вы можете отрегулировать расписание для каждой станции.\n" ..
                "По прибытию на станцию, поезд будет стараться следовать расписанию.\n" ..
                "Следующие варианты регулировки доступны: \n" ..
                "  - Прибытие/Отправление: установите время прибытия и отправления и поезд выберет ближайшее\n" ..
                "    подходящее время отправления\n" ..
                "  - Интервал: настройте время и транспорт будет отправляться со станции согласно выбранному интервалу"
                ),
            ["mod_name_i18n"] = "Расписание",
            ["mod_description_i18n"] = "Этот мод добавляет в игру расписание.",
        },

        it = {
            ["arr_i18n"] = "Arr: ",
            ["arrival_i18n"] = "Arrivo",
            ["dep_i18n"] = "Part: ",
            ["departure_i18n"] = "Partenza",
            ["unbunch_time_i18n"] = "Tempo di distanziamento",
            ["unbunch_i18n"] = "Distanziamento",
            ["timetable_i18n"] = "Schede Orarie",
            ["timetables_i18n"] = "Schede Orarie",
            ["line_i18n"] = "Linea",
            ["lines_i18n"] = "Linee",
            ["time_min_i18n"] = "min",
            ["time_sec_i18n"] = "sec",
            ["stations_i18n"] = "Stazioni",
            ["frequency_i18n"] = "Frequenza",
            ["journey_time_i18n"] = "Tempo di viaggio",
            ["arr_dep_i18n"] = "Arrivo/Partenza",
            ["no_timetable_i18n"] = "Nessuna scheda orario",
            ["all_i18n"] = "Tutti",
            ["add_i18n"] = "Aggiungi",
            ["none_i18n"] = "Nessuno",
            ["tooltip_i18n"] = (
                "Puoi aggiungere una scheda orario per ogni stazione.\n" ..
                "Quando un treno arriva alla stazione, questo proverà \n" ..
                "a mantenere l'orario impostato. \n" ..
                "  - Arrivo/Partenza: imposta Arr/Part multipli per il treno \n" ..
                "                                      che sceglierà l'orario di arrivo piu vicino\n" ..
                "  - Distanziamento: imposta un tempo per cui il veicolo partirà dalla stazione all'intervallo orario scelto"
                ),
            ["mod_name_i18n"] = "Orari",
            ["mod_description_i18n"] = "Questa mod aggiunge le schede orarie al gioco.",
        },

--[[
        nl = {
            ["arr_i18n"] = "",
            ["arrival_i18n"] = "",
            ["dep_i18n"] = "",
            ["departure_i18n"] = "",
            ["unbunch_time_i18n"] = "",
            ["unbunch_i18n"] = "",
            ["timetable_i18n"] = "",
            ["timetables_i18n"] = "",
            ["line_i18n"] = "",
            ["lines_i18n"] = "",
            ["time_min_i18n"] = "",
            ["time_sec_i18n"] = "",
            ["stations_i18n"] = "",
            ["frequency_i18n"] = "",
            ["journey_time_i18n"] = "",
            ["arr_dep_i18n"] = "",
            ["no_timetable_i18n"] = "",
            ["all_i18n"] = "",
            ["add_i18n"] = "",
            ["none_i18n"] = "",
            ["tooltip_i18n"] = (
                 "\n" ..
                "\n" ..
                "\n" ..
                "\n"..
                "" ..
                ""
                ),
            },
--]]

--[[
        es = {
            ["arr_i18n"] = "",
            ["arrival_i18n"] = "",
            ["dep_i18n"] = "",
            ["departure_i18n"] = "",
            ["unbunch_time_i18n"] = "",
            ["unbunch_i18n"] = "",
            ["timetable_i18n"] = "",
            ["timetables_i18n"] = "",
            ["line_i18n"] = "",
            ["lines_i18n"] = "",
            ["time_min_i18n"] = "",
            ["time_sec_i18n"] = "",
            ["stations_i18n"] = "",
            ["frequency_i18n"] = "",
            ["journey_time_i18n"] = "",
            ["arr_dep_i18n"] = "",
            ["no_timetable_i18n"] = "",
            ["all_i18n"] = "",
            ["add_i18n"] = "",
            ["none_i18n"] = "",
            ["tooltip_i18n"] = (
                 "\n" ..
                "\n" ..
                "\n" ..
                "\n"..
                "" ..
                ""
                ),
            },
--]]

--[[
        fr = {
            ["arr_i18n"] = "",
            ["arrival_i18n"] = "",
            ["dep_i18n"] = "",
            ["departure_i18n"] = "",
            ["unbunch_time_i18n"] = "",
            ["unbunch_i18n"] = "",
            ["timetable_i18n"] = "",
            ["timetables_i18n"] = "",
            ["line_i18n"] = "",
            ["lines_i18n"] = "",
            ["time_min_i18n"] = "",
            ["time_sec_i18n"] = "",
            ["stations_i18n"] = "",
            ["frequency_i18n"] = "",
            ["journey_time_i18n"] = "",
            ["arr_dep_i18n"] = "",
            ["no_timetable_i18n"] = "",
            ["all_i18n"] = "",
            ["add_i18n"] = "",
            ["none_i18n"] = "",
            ["tooltip_i18n"] = (
                 "\n" ..
                "\n" ..
                "\n" ..
                "\n"..
                "" ..
                ""
                ),
            },
--]]

--[[
        pl = {
            ["arr_i18n"] = "",
            ["arrival_i18n"] = "",
            ["dep_i18n"] = "",
            ["departure_i18n"] = "",
            ["unbunch_time_i18n"] = "",
            ["unbunch_i18n"] = "",
            ["timetable_i18n"] = "",
            ["timetables_i18n"] = "",
            ["line_i18n"] = "",
            ["lines_i18n"] = "",
            ["time_min_i18n"] = "",
            ["time_sec_i18n"] = "",
            ["stations_i18n"] = "",
            ["frequency_i18n"] = "",
            ["journey_time_i18n"] = "",
            ["arr_dep_i18n"] = "",
            ["no_timetable_i18n"] = "",
            ["all_i18n"] = "",
            ["add_i18n"] = "",
            ["none_i18n"] = "",
            ["tooltip_i18n"] = (
                 "\n" ..
                "\n" ..
                "\n" ..
                "\n"..
                "" ..
                ""
                ),
            },
--]]

--[[
        ja = {
            ["arr_i18n"] = "",
            ["arrival_i18n"] = "",
            ["dep_i18n"] = "",
            ["departure_i18n"] = "",
            ["unbunch_time_i18n"] = "",
            ["unbunch_i18n"] = "",
            ["timetable_i18n"] = "",
            ["timetables_i18n"] = "",
            ["line_i18n"] = "",
            ["lines_i18n"] = "",
            ["time_min_i18n"] = "",
            ["time_sec_i18n"] = "",
            ["stations_i18n"] = "",
            ["frequency_i18n"] = "",
            ["journey_time_i18n"] = "",
            ["arr_dep_i18n"] = "",
            ["no_timetable_i18n"] = "",
            ["all_i18n"] = "",
            ["add_i18n"] = "",
            ["none_i18n"] = "",
            ["tooltip_i18n"] = (
                 "\n" ..
                "\n" ..
                "\n" ..
                "\n"..
                "" ..
                ""
                ),
            },
--]]

        zh_CN = {
            ["arr_i18n"] = "到: ",
            ["arrival_i18n"] = "到达",
            ["dep_i18n"] = "发: ",
            ["departure_i18n"] = "出发",
            ["unbunch_time_i18n"] = "发车间隔",
            ["unbunch_i18n"] = "间隔控制",
            ["timetable_i18n"] = "时刻表",
            ["timetables_i18n"] = "时刻表",
            ["line_i18n"] = "线路",
            ["lines_i18n"] = "线路",
            ["time_min_i18n"] = "分",
            ["time_sec_i18n"] = "秒",
            ["stations_i18n"] = "站",
            ["frequency_i18n"] = "频率",
            ["journey_time_i18n"] = "旅时",
            ["arr_dep_i18n"] = "到发时刻",
            ["no_timetable_i18n"] = "无时刻表",
            ["all_i18n"] = "全部",
            ["add_i18n"] = "添加",
            ["none_i18n"] = "无",
            ["tooltip_i18n"] = (
                "你可以对每个站点添加时刻表约束。\n" ..
                "列车到站后会尽量遵循约束条件。可用的约束模式包括：\n" ..
                " – 到发时刻：设定多组到发时刻，列车会选择最近的时刻\n" ..
                " - 间隔控制：设定时间长度，载具以给定间隔发车"
                ),
            ["mod_name_i18n"] = "时刻表",
            ["mod_description_i18n"] = "本模组为游戏添加时刻表系统",
        },

        zh_TW = {
            ["arr_i18n"] = "到: ", 
            ["arrival_i18n"] = "到達", 
            ["dep_i18n"] = "發: ", 
            ["departure_i18n"] = "出發", 
            ["unbunch_time_i18n"] = "發車間隔", 
            ["unbunch_i18n"] = "間隔控制", 
            ["timetable_i18n"] = "時刻表", 
            ["timetables_i18n"] = "時刻表", 
            ["line_i18n"] = "路線", 
            ["lines_i18n"] = "路線", 
            ["time_min_i18n"] = "分", 
            ["time_sec_i18n"] = "秒", 
            ["stations_i18n"] = "站", 
            ["frequency_i18n"] = "頻率", 
            ["journey_time_i18n"] = "旅時", 
            ["arr_dep_i18n"] = "到發時刻", 
            ["no_timetable_i18n"] = "無時刻表", 
            ["all_i18n"] = "全部", 
            ["add_i18n"] = "添加", 
            ["none_i18n"] = "無", 
            ["tooltip_i18n"] = (
                "你可以對各個站點添加時刻表約束。\n" ..
                "列車到站後會儘量遵循約束條件。可用的約束模式包括：\n" ..
                " – 到發時刻：設定多組到發時刻，列車會選擇最近的時刻\n" ..
                " - 間隔控制：設定時間長度，載具以給定間隔發車"
                ), 
            ["mod_name_i18n"] = "時刻表", 
            ["mod_description_i18n"] = "本模組爲遊戲添加時刻表系統",
        },

    }

end
