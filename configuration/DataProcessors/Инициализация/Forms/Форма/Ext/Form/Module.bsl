﻿
&НаКлиенте
Процедура СоздатьТовары(Команда)
	СоздатьТоварыНаСервере(КоличествоТоваров);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура СоздатьТоварыНаСервере(КоличествоТоваров)
	Для Сч = 1 По КоличествоТоваров Цикл
		Номенклатура = Справочники.Номенклатура.СоздатьЭлемент();
		Номенклатура.Наименование = СтрШаблон("Товар %1", Сч);
		Номенклатура.Записать();
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура Цены(Команда)
	ЦеныНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЦеныНаСервере()
	
	Гена = Новый ГенераторСлучайныхЧисел();
	ДатаУстановкиЦен = Период.ДатаНачала;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Номенклатура.Ссылка КАК Номенклатура,
		|	ВЫРАЗИТЬ(0 КАК ЧИСЛО(15, 2)) КАК Цена,
		|	&Период КАК Период
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура";
	Запрос.УстановитьПараметр("Период", ДатаУстановкиЦен);
	
	ТабНоменклатуры = Запрос.Выполнить().Выгрузить();
	
	Для каждого стрТабНоменклатуры Из ТабНоменклатуры Цикл
		стрТабНоменклатуры.Цена = Гена.СлучайноеЧисло(100,4000);
	КонецЦикла;
	
	УстановкаЦен = РегистрыСведений.ЦеныНоменклатуры.СоздатьНаборЗаписей();
	УстановкаЦен.Загрузить(ТабНоменклатуры);
	УстановкаЦен.Отбор.Период.Установить(ДатаУстановкиЦен);
	УстановкаЦен.Записать();
	
КонецПроцедуры

&НаКлиенте
Процедура Переоценки(Команда)
	ПереоценкиНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПереоценкиНаСервере()
	
	ДатаНач = Период.ДатаНачала;
	ДатаКон = Период.ДатаОкончания;
	ШагПериода = (ДатаКон - ДатаНач)/(КоличествоПереоценок + 1);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЦеныНоменклатурыСрезПоследних.Период КАК Период,
		|	ЦеныНоменклатурыСрезПоследних.Номенклатура КАК Номенклатура,
		|	ЦеныНоменклатурыСрезПоследних.Цена КАК Цена
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних КАК ЦеныНоменклатурыСрезПоследних
		|
		|УПОРЯДОЧИТЬ ПО
		|	Номенклатура";
	
	ТабНоменклатуры = Запрос.Выполнить().Выгрузить();
	
	Гена = Новый ГенераторСлучайныхЧисел();
	
	Для Сч = 1 По КоличествоПереоценок Цикл
		
		ДатаУстановкиЦен = НачалоДня(ДатаНач + Сч*ШагПериода);
		
		НаборЗаписей = РегистрыСведений.ЦеныНоменклатуры.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Период.Установить(ДатаУстановкиЦен);
		
		УжеИспользовано = Новый Соответствие;
		
		Для Сч2 = 1 По Гена.СлучайноеЧисло(КоличествоПозицийВПереоценкеМин, КоличествоПозицийВПереоценкеМакс) Цикл
			
			НомерСтроки = Гена.СлучайноеЧисло(0, КоличествоТоваров - 1);
			Если УжеИспользовано[ТабНоменклатуры[НомерСтроки].Номенклатура] = Неопределено Тогда
				УстановкаЦен = НаборЗаписей.Добавить();
				УстановкаЦен.Период = ДатаУстановкиЦен;
				УстановкаЦен.Номенклатура = ТабНоменклатуры[НомерСтроки].Номенклатура;
				ТабНоменклатуры[НомерСтроки].Цена = ТабНоменклатуры[НомерСтроки].Цена*0.95 + Гена.СлучайноеЧисло(0, ТабНоменклатуры[НомерСтроки].Цена * 0.1);
				УстановкаЦен.Цена = ТабНоменклатуры[НомерСтроки].Цена;
				УжеИспользовано.Вставить(ТабНоменклатуры[НомерСтроки].Номенклатура, Истина);
			КонецЕсли;
			
		КонецЦикла;
		
		НаборЗаписей.Записать();
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьКонтрагентов(Команда)
	СоздатьКонтрагентовНаСервере();
КонецПроцедуры

&НаСервере
Процедура СоздатьКонтрагентовНаСервере()
	Для Сч = 1 По КоличествоКонтрагентов Цикл
		Номенклатура = Справочники.Контрагенты.СоздатьЭлемент();
		Номенклатура.Наименование = СтрШаблон("Контрагент %1", Сч);
		Номенклатура.Записать();
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура Продажи(Команда)
	ПродажиНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПродажиНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Контрагенты.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Контрагенты КАК Контрагенты";
	
	МассивКонтрагентов = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЦеныНоменклатурыСрезПоследних.Цена КАК Цена,
		|	ЦеныНоменклатурыСрезПоследних.Номенклатура КАК Номенклатура
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(&Период, ) КАК ЦеныНоменклатурыСрезПоследних";

	
	ДатаПродажи = Период.ДатаНачала;
	
	Гена = Новый ГенераторСлучайныхЧисел();
	
	Пока ДатаПродажи <= Период.ДатаОкончания Цикл
		
		Запрос.УстановитьПараметр("Период", ДатаПродажи);
		ТаблицаЦен = Запрос.Выполнить().Выгрузить();
		ТаблицаЦен_ВГраница = ТаблицаЦен.Количество()-1;
		
		КоличествоПродажВДень = Гена.СлучайноеЧисло(КоличествоПродажВДеньМин, КоличествоПродажВДеньМакс);
		
		Для Сч = 1 По КоличествоПродажВДень Цикл
			
			Продажа = Документы.ПродажаТовара.СоздатьДокумент();
			Продажа.Контрагент = МассивКонтрагентов[Гена.СлучайноеЧисло(0,МассивКонтрагентов.ВГраница())];
			
			КоличествоПозицийПродажВДень = Гена.СлучайноеЧисло(КоличествоПозицийВДокументеПродажиМин, КоличествоПозицийВДокументеПродажиМакс);
			
			Для Инд = 1 По КоличествоПродажВДень Цикл
				НовСтрокаПродажи = Продажа.Товары.Добавить();
				НовСтрокаПродажи.Количество = Гена.СлучайноеЧисло(1,1000);
				СтрокаВТаблицеЦен = ТаблицаЦен[Гена.СлучайноеЧисло(0,ТаблицаЦен_ВГраница)];
				НовСтрокаПродажи.Номенклатура = СтрокаВТаблицеЦен.Номенклатура;
				НовСтрокаПродажи.Цена = СтрокаВТаблицеЦен.Цена * (100-Гена.СлучайноеЧисло(0,12))/100;
				НовСтрокаПродажи.Сумма = НовСтрокаПродажи.Цена * НовСтрокаПродажи.Количество;
			КонецЦикла;
			
			Продажа.Дата = ДатаПродажи;
			
			Продажа.Записать();
			
		КонецЦикла;
		
		ДатаПродажи = КонецДня(ДатаПродажи) + 1;
		
	КонецЦикла;
	
	//Запрос = Новый Запрос;
	//Запрос.Текст = 
	//	"ВЫБРАТЬ
	//	|	Номенклатура.Ссылка КАК Ссылка
	//	|ИЗ
	//	|	Справочник.Номенклатура КАК Номенклатура";
	//
	//ТабНоменклатуры = Запрос.Выполнить().Выгрузить();
	//
	//Пока ДатаПродажи < Дата(2019,9,1) Цикл
	//	Если не ДеньНедели(ДатаПродажи) = 6 Тогда
	//		Для Сч = 1 По ГенСлЧ.СлучайноеЧисло(420,550) Цикл
	//			Продажа = Документы.Продажа.СоздатьДокумент();
	//			Продажа.Дата = ДатаПродажи + ГенСлЧ.СлучайноеЧисло(0, КонецДня(ДатаПродажи) - ДатаПродажи);
	//			Продажа.Номенклатура = ТабНоменклатуры[ГенСлЧ.СлучайноеЧисло(0,999)].Ссылка;
	//			Продажа.Количество = ГенСлЧ.СлучайноеЧисло(1,1050);
	//			Продажа.Записать();
	//		КонецЦикла;
	//	КонецЕсли;
	//	ДатаПродажи = КонецДня(ДатаПродажи) + 1;
	//КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьЦены(Команда)
	УдалитьЦеныНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УдалитьЦеныНаСервере()
	НаборЗаписей = РегистрыСведений.ЦеныНоменклатуры.СоздатьНаборЗаписей();
	НаборЗаписей.Записать();
КонецПроцедуры

&НаКлиенте
Процедура УдалитьПродажи(Команда)
	УдалитьПродажиНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УдалитьПродажиНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПродажаТовара.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.ПродажаТовара КАК ПродажаТовара";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ДокОбъект = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
		ДокОбъект.Удалить();
	КонецЦикла;

	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьКонтрагентов(Команда)
	УдалитьКонтрагентовНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УдалитьКонтрагентовНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Контрагенты.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Контрагенты КАК Контрагенты";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		СпрОбъект = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
		СпрОбъект.Удалить();
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура УдалитьНоменклатуру(Команда)
	УдалитьНоменклатуруНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура УдалитьНоменклатуруНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Номенклатура.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		СпрОбъект = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
		СпрОбъект.Удалить();
	КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	КоличествоТоваров = 1000;
	Период.Вариант = ВариантСтандартногоПериода.ПроизвольныйПериод;
	Период.ДатаНачала = '20191001';
	Период.ДатаОкончания = '20191231235959';
	КоличествоПереоценок = 12;
	КоличествоПозицийВПереоценкеМин = 200;
	КоличествоПозицийВПереоценкеМакс = 600;
	КоличествоКонтрагентов = 500;
	КоличествоПродажВДеньМин = 50;
	КоличествоПродажВДеньМакс = 300;
	КоличествоПозицийВДокументеПродажиМин = 1;
	КоличествоПозицийВДокументеПродажиМакс = 900;
КонецПроцедуры
