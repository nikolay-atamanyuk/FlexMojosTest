# Описание проекта.
Попытка автоматизировать сборку flash/flex проектов с использованием maven,
при помощи плагина flexmojos.

## Попытка номер раз: net.flexmojos.oss v.6.0.0
IDEA оказывается знает архетип для net.flexmojos.oss v.6.0.0. Стандартная maven-генерация - clean compile - Fail.
Получаем 4 ошибки:
[ERROR]   The project FlexMojosTest:FlexMojosTest:1.0-SNAPSHOT (D:\Projets\FlexMojosTest\pom.xml) has 4 errors
[ERROR]     Unresolveable build extension: Plugin net.flexmojos.oss:flexmojos-maven-plugin:6.0.0 or one of its dependencies could not be resolved: Failed to collect dependencies for net.flexmojos.oss:flexmojos-maven-plugin:jar:6.0.0 (): Failed to read artifact descriptor for net.flexmojos.oss:flexmojos-maven-plugin:jar:6.0.0: Failure to find com.adobe.flex:framework:pom:4.6.0.23201 in http://repository.sonatype.org/content/groups/flexgroup was cached in the local repository, resolution will not be reattempted until the update interval of flex-mojos-plugin-repository has elapsed or updates are forced -> [Help 2]
[ERROR]     Unknown packaging: swf @ line 28, column 16
[ERROR]     Non-resolvable import POM: Failure to find com.adobe.flex:framework:pom:4.6.0.23201 in http://repository.sonatype.org/content/groups/flexgroup was cached in the local repository, resolution will not be reattempted until the update interval of flex-mojos-repository has elapsed or updates are forced @ line 67, column 25 -> [Help 3]
[ERROR]     'dependencies.dependency.version' for com.adobe.flex.framework:flex-framework:pom is missing. @ line 49, column 21
[ERROR]
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR]
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/ProjectBuildingException
[ERROR] [Help 2] http://cwiki.apache.org/confluence/display/MAVEN/PluginResolutionException
[ERROR] [Help 3] http://cwiki.apache.org/confluence/display/MAVEN/UnresolvableModelException
Которые вкратце сообщают о невозможности разрешить зависимости плагина, flex-фраймворка и всего, что с ним связано.
Проверка репозиториев показывает, что в самом деле, фреймворка с подобными координатами нет.
Неудача. Генерация через командную строку привела к аналогичному результату.

## Попытка номер два.
Пробую создать аналогичный проект но на основе описания от Adobe. Там используется более ранняя версия
плагина org.sonatype.flexmojos v.4.0-RC2.
mvn clean compile - Fail
По большому счету, большой разницы в сообщениях об ошибках нет, снова не найдены зависимости для плагина.

## Попытка номер три.
Пробую еще вариант, описанный в рекомендация от IntelliJ IDEA. Есть последняя версия плагина, которая доступна в репозитории.
Как ни странно, но это нехитрое действие приносит свои плоды и компиляция проходит успешно! Это первая удачная попытка
без особых плясок с бубном.
Делая нехитрое преобразование через свойста пробую перейти на последний флех-фраймворк, который есть в репозитории.
При переходе на другую версию flex, необходимо так же перевести на нее и плагин, который используется. Подробнее о переходе
можно узнать [здесь](https://flexmojos.atlassian.net/wiki/display/FLEXMOJOS/Specify+the+Flash+Player+Target+Version).
В общих чертах: крайне не рекомендуется смешивать несколько версий sdk в зависимостях, поэтому надо внимательно следить,
чего именно подключается, а чего еще надо отключить.
В целом попытка удалась, спускаемся по жизненному циклу дальше - запускаем тесты и пакуем результат.

## Запуск юнит-тестов.
mvn clean test - Fail.
Первый запуск тестов провалился. Исходя из лога, не найден дебажный флеш-плейер. Приятно, что тут же в логе
есть куда обратиться по этому вопросу. По [ссылке из лога](https://docs.sonatype.org/display/FLEXMOJOS/Running+unit+tests),
кстати, это не самый последний вариант документации, узнаем, что надо явно указать путь к дебажному плейеру.
Способов два, это добавить путь в системеную переменную PATH, или воспользоваться тайным свойством, который подхватит
плагин. Мне ближе второе. Пробуем, добавляем переменную с абсолютным путем к дебажному плейеру и получаем ошибку:

[ERROR] Failed to execute goal org.sonatype.flexmojos:flexmojos-maven-plugin:4.2-beta:test-run (default-test-run) on project FlexMojosTest: Invalid state: the flashplayer is closed, but the sockets still running...

Это явно прогресс, но не самый лучший его вариант...
При этом это ошибка именно плагина, потому как запуск этого теста через IDEA проходит успешно, что не может не радовать,
поскольку никаких дополнительных настроек сделано не было. Точно не уверен, что именно повлияло на процесс, но переход
на flexunit4 и написание "настоящего" теста полностью спасло ситуацию. Тест запустился и выполнился без лишних ошибок в логе!
Итак минимальная цель достигнута: mvn clean package работает!

## Переход на "чистый" as3 проект.
В последнее время я не часто делаю именно flex-проекты, все чаще это as3 проекты без исмользования mxml. Продолжаем
приспосабливать проект под эти нужды. Для начала сменим названия, чтобы не было сомнений и заменим стартовый класс с
mxml > as3. В конфигурации плагина имеет смысл указать новый стартовый файл, потому как по умолчанию используется Main.mxml,
а после его замены на Main.as потеряются возможности автозапуска флехи после сборки и типового дебага через IDEA, а это
не очень приятно. Обращаю внимание, что необходимо специфицировать только название файла.

## Ресурсы.
- [Самая старая версия из найденных. Последнее обновление - февраль 2009](http://code.google.com/p/flex-mojos/)
- [Версия до 4.0 еще org.sonatype.flexmojos. Последнее обновление - май 2011](https://docs.sonatype.org/display/FLEXMOJOS/Home)
- [Версия до 6.0.0. Самая полная документация. Последнее обновление - ноябрь 2012](https://flexmojos.atlassian.net/wiki/display/FLEXMOJOS/Home)
По большому счету, в последней ссылке я нашел практически копии всех предыдущих варинантов документации, так что
в первых двух смысла не много, но найти их значительно легче, чем последнюю.

- [Первый архив вопросов-ответов](http://www.mail-archive.com/flex-mojos@googlegroups.com/)
- [Второй архив вопросов-ответов](http://osdir.com/ml/flex-mojos)

- [Первая статья от Adobe по flexmojos v.4.0-RC2](http://www.adobe.com/devnet/flex/articles/flex-maven-flexmojos-pt1.html)
- [Вторая статья от Adobe по flexmojos v.4.0-RC2](http://www.adobe.com/devnet/flex/articles/flex-maven-flexmojos-pt2.html)
- [Третья статья от Adobe по flexmojos v.4.0-RC2](http://www.adobe.com/devnet/flex/articles/flex-maven-flexmojos-pt3.html)

- [Справка от IntelliJ IDEA по работе с flexmojos v.4.2-beta](http://wiki.jetbrains.net/intellij/Working_with_Flexmojos_projects_in_IntelliJ_IDEA)

