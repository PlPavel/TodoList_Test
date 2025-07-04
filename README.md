# TodoList_Test

Использовал Figma для разработки интерфейсов, верстал по макетам, обеспечивая точное соответствие дизайну и высокое качество UX/UI.  

Реализовано:
- Отображение списка задач на главном экране.  
- Задача содержит название, описание, дату создания и статус (выполнена/не выполнена).  
- Добавления новой задачи.  
- Возможность редактирования существующей задачи.  
- Возможность удаления задачи.  
- Возможность поиска по задачам.
- Архитектура VIPER для всех экранов.
- Unit-тесты для основных элементов.
- Расположение задач в таблице в порядке их создания (новая задача находится сверху)

При первом запуске приложение загружает список задач из указанного json api.  
Обработка создания, загрузки, редактирования, удаления и поиска задач выполняется в фоновом потоке с использованием GCD.  
В приложении интегрирована CoreData, в которой сохраняются данные о задачах и корректно восстанавливаются при повторной загрузке.   

В приложении реализованы Unit-тесты, которые проверяют корректность работы Presenter из архитектуры VIPER главного экрана. Тесты гарантируют, что весь функционал данного файла работает правильно.

