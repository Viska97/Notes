Для работы приложения в оффлайн режиме необходимо нажать на кнопку "Оффлайн режим" на экране авторизации. Позднее можно будет перейти в онлайн, нажав на кнопку в navigation bar.

Реализована миграция (Model и Model 2, ModelMapping1to2.xcmappingmodel).

Для работы приложения в онлайн режиме с Github API необходимо зарегистрировать OAuth приложение на этой странице: https://github.com/settings/developers (нажать на кнопку New OAuth App). Пример данных для заполнения:
Application name: iOS Course Notes
Homepage URL: https://stepik.org/course/53561/syllabus
Authorization callback URL: ioscoursenotes://host
После регистрации приложения необходимо скопировать Client ID и Client Secret в соответствующие поля в AppDelegate.swift.

Редактирование заметки реализовано как в стандартных приложения iOS (например, контакты). При открытии существующей заметки после внесения изменений становится доступна кнопка Done, после нажатия на которую происходит сохранение заметки и возврат на экран со списком заметок. При нажатии на кнопку Cancel или выход с экрана другим способом изменения в заметке не сохраняются. При создании новой заметки необходимо как минимум ввести заголовок и содержимое, после чего кнопкой Done можно сохранить заметку и она добавится в список. При нажатии на кнопку Cancel или выход с экрана другим способом новая заметка не добавляется.

Аналогичное поведение реализовано для экрана выбора цвета: выбранный цвет сохраняется после нажатия на кнопку Done.

После нажатия на кнопку Done выполняется функция @objc func save() в NoteEditViewController.swift в которой происходит запуск операции SaveNoteOperation.

Загрузка списка заметок происходит в функции loadNotes() в NotesViewController.swift, где запускается операция LoadNotesOperation.
Удаление заметки проиходит в функции removeNote(with uid: String, at indexPath: IndexPath), где запускается операция RemoveNoteOperation.

Все операции находятся в папке Operations.

При первом запуске приложения (в случае отсутствия файла с фото заметками) добавляются предустановленные фото заметки. Изображения для предустановленных фото заметок находятся в папке DefaulImageNotes.

На экране с просмотром фото присуствует UIScrollView, в который программно добавляется максимум 3 UIImageView (текущая картинка, буфер справа, буфер слева), затем когда пользователь пролистывает влево/вправо, UIImageView переиспользуются с новыми изображениями. Таким образом эффективно используются ресурсы, если картинок будет очень много.

Все экраны приложения размещены в Main.storyboard.

Все ViewController и ViewCell для вкладки заметок лежат в /Modules/Notes.
Все ViewController и ViewCell для вкладки галереи лежат в /Modules/Gallery.

Кастомные UI компоненты расположены в /Components.

Элемент выбора цвета в виде квадратиков реализован с помощью отдельного компонента ColorSelectorView.swift, который внутри себя использует компонент ColorItemView.swift (отдельный квадрат с цветом, в котором также происходит рисование флажка). (/Components/ColorSelector)

Элемент выбора цвета из палитры реализован с помощью отдельного компонента ColorPickerView.swift и для него также требуются файлы ColorFieldView.swift (непосредственно сама палитра) и SelectedColorView.swift (элемент, отображающий текущий цвет). (/Components/ColorPicker)

Для элементов также требуется файл CGFloatExtension.swift в папке /Components/Shared. В нем содержится функция для преобразования градусов в радианы.