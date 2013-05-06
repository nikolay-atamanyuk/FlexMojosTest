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

## Оптимизация
Проект не отличается обилием кода, но тем не менее весит в дебажной версии 853 б, в релизной 613. Проверим, чего можно
достичь с использованием оптимизации от flexmojos. Судя по всему оптимизация проходит в несколько этапов (я нашел в classes
4 файла, думаю, это и есть этапы оптимизации). После оптимизации для дебага получилось 391б, даже меньше релизной.
Оптимизатор так же умеет сжимать картинки ресурсов, за это отвечает параметр **quality** конфигурации от 0 до 1. Скорее всего
это аналог качества jpeg.

**Заметка** К сожалению, так и не удалось перейти на последние версии плагина (net.flexmojos.oss), для 5 версии
не работает юнит тестирование, а для 6 не наден компилятор в репозитории (правда есть [тулза](https://git-wip-us.apache.org/repos/asf/flex-utilities.git),
котороя вроде как позволяет мавенизировать любой flex-sdk ). Но даже с данным фукнционалом уже очень не плохо.

## Работа с fla-ресурсами.
Разрешение зависимостей, это один из очень больших плюсов maven, когда они доступны в публичных репозиториях и проблема,
когда нет. При разработке (особенно игр) много ресурсов хранять в свиках, получаемых из fla-проектов. Деплоить каждый раз
особого желания нет. А если свиков много, то вообще было бы удобно преобразовывать их пакетно. Что же можно найти здесь?
А вот здесь найти особо и не чего, к моему большому сожалению. Хотя Adobe и перешел на новый формат fla, который на самом
деле зипованный xfl, но консольной утилиты компиляции этого добра в swc/swf до сих пор нет (и возможно не будет). Поиск
дал несколько не сильно активных проектов, которые на текущий момент не могут быть даже рассмотрены в качестве альтернатив.
Итак, без FlashIDE скомпилировать ресурсы нельзя. Это расстраивает. Возможности которые есть:
- jsfl - с его помощью можно отправить fla на публикацию во FlashIDE. Можно к этому добавить скрипт для размещения в 
maven-репозитории, тогда это не нарушит идеологии maven. Правда, получаем не переносимую конфигурацию скрипта, поскольку
она завязана на абсолютные пути. Также, каждому работающему с проетом нужен FlashIDE. Не самое удачное решение, но хоть 
что-то. При активной работе с дизайнером, возможно проще сделать общий репозиторий и дать дизайнеру скрипт публикации свика,
хотя, конечно, это не совсем работа дизайнра.
- запуск компиляции fla через Ant или любым другим способом (например FlashDevelop). Но все эти способы, по факту, нарушают
идеалогию работы maven. Т.е. без дополнительных телодвижений, работать с дизайнером не получится :(.
Да, заодно про fla и контроль версий. Хоть теперь это и не бинарный формат, но мержить его все равно проблематично, потому как 
каждое сохранение вызывает довольно масштабные дифы, которые далеко не всегда мержатся в автоматическом режиме. Так что, тут
выбор каждого. Если количество работающих с fla одновременно 1, то можно попробовать съекономить на контроле версий и использовать
xfl. Правда не думаю, что выгода будет сильно большая.

## FlexPDM
Закончить хотелось бы плагином для определения качества кода. Нашел его случайно, когда искал возможность компиляции
fla-файлов. FlexPDM - это opensource от Adobe, который базируется на аналогичном java плагине. Документация оставляет
желать лучшего, вики не дописана и разбросана по проекту. Но найти страницу с использованием оказалось возможным. Также
находил отзывы и примеры применения в реальных проектах. Как водится, взял последнюю версию (1.2) плагина из адобовского репозитория
mvn site

    [INFO] ------------------------------------------------------------------------
    [ERROR] Failed to execute goal org.apache.maven.plugins:maven-site-plugin:3.0:site (default-site) on project FlexMojosTest: Execution default-site of goal org.apache.maven.plugins:maven-site-plugin:3.0:site failed: An API incompatibility was encountered while executing org.apache.maven.plugins:maven-site-plugin:3.0:site: java.lang.AbstractMethodError: com.adobe.ac.pmd.maven.FlexPmdReportMojo.canGenerateReport()Z

Вот такая неприятность. Небольшой поиск показал, что этот плагин в последней версии не работоспособен. Пробуем откатиться
на несколько версий назад. В целом это логично и объяснение есть [здесь](http://sourceforge.net/adobe/flexpmd/tickets/2/).
Еще немного порывшись в гугле, нашел репопозиторий Alex Manarpies, в котором тоже есть версия 1.2 плагина. Зачищаю локальный,
меняю реп - mvn site

    [ERROR] Failed to execute goal org.apache.maven.plugins:maven-site-plugin:3.0:site (default-site) on project FlexMojosTest: failed to get report for com.adobe.ac:flex-pmd-maven-plugin: Plugin com.adobe.ac:flex-pmd-maven-plugin:1.2 or one of its dependencies could not be resolved: Failed to read artifact descriptor for com.adobe.ac:flex-pmd-maven-plugin:jar:1.2: Could not transfer artifact com.adobe.ac:flex-pmd-maven-plugin:pom:1.2 from/to flexpmd.opensource.adobe (http://code.google.com/p/flex-maven-repo/source/browse/): Checksum validation failed, expected <!DOCTYPE but is d3ea07a9bcf449ba69929ed4b6c01bdf7b1b9b6d -> [Help 1]

Скачивание не удалось.
Последняя попытка работы со снапшотом плагина для версии 1.3 также не удалась.

    [ERROR] Failed to execute goal org.apache.maven.plugins:maven-site-plugin:3.0:site (default-site) on project FlexMojosTest: failed to get report for com.adobe.ac:flex-pmd-maven-plugin: Plugin com.adobe.ac:flex-pmd-maven-plugin:1.3-SNAPSHOT or one of its dependencies could not be resolved: Failed to read artifact descriptor for com.adobe.ac:flex-pmd-maven-plugin:jar:1.3-SNAPSHOT: Failure to find com.adobe.ac:flex-pmd:pom:1.3-SNAPSHOT in http://repository.sonatype.org/content/groups/flexgroup was cached in the local repository, resolution will not be reattempted until the update interval of flex-mojos-plugin-repository has elapsed or updates are forced -> [Help 1]

Однако, радует, что какая-то работа видимо ведется. Или велась.
Однако, кроме мавена, этот проект работает:
[Любителям flashdevelop](http://www.swfgeek.net/2009/09/18/using-flex-pmd-in-flashdevelop-3/)
[Jenkins+Ant - пример сборки](http://vapes.na.by/blog/index.php?entry=C%EE%E1%E8%F0%E0%E5%EC-Flex-%EF%F0%EE%E5%EA%F2-%F1-%EF%EE%EC%EE%F9%FC%FE-ANT)

## Вместо заключения
Собитать flex проекты мавеном можно, особенно если это проекты модульные и команда большая. Очень желательно иметь
свой репозиторий, с которым будет работать команда. Если проект гетерогенный, особенно с java бэк-ендом, то сборка будет
еще лучше. Но для небольших распределенных команд, проектов игростроя, где много работы дизайнера, настройка проекта
не настолько проста, как бы хотелось. Проблема кроется в одной из сильных частей maven - разрешение зависимостей. Репозиториев,
точнее артифактов в них, пока не много и они не согласованы. Maven пока еще не очень популярен в среде flex/flash (особенно)
разработчиков. А ведь жаль, чертовски удобная штука.

## Ресурсы.
### FlexMojos.
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

- [Документация по версии 4.0](http://repository.sonatype.org/content/sites/flexmojos-site/4.0-SNAPSHOT/project-info.html)
- [Параметы конфигурации для версии 4.0](http://repository.sonatype.org/content/sites/flexmojos-site/4.0-SNAPSHOT/configurator-mojo.html)

- [Appach flex wiki - maven plugin](https://cwiki.apache.org/confluence/display/FLEX/Maven+Plugin)

### FLA/XFL
- [XFL и контроль версий. Проблемы.](http://forums.adobe.com/message/4037392)
- [Ant tasks для сборки проекта с использованием Flash CS](http://code.google.com/p/flashanttasks/) 2009 год
- [Ant task для работы с ресурсами, без их компиляции](https://bitbucket.org/andkrup/a3tasks) 2012 год

- [Mike Chambers flashcommand - фактически генератор jsfl-скрипта](http://code.google.com/p/flashcommand/source/browse/trunk/osx/src/flashcommand)

### FlexPDM
- [Adobe cookbook](http://cookbooks.adobe.com/post_Invoke_FlexPMD_with_Maven_on_build_Flex_projects-16066.html)
- [Wiki - how to invoke FlexPDM](http://sourceforge.net/adobe/flexpmd/wiki/How%20to%20invoke%20FlexPMD/)
- [FlexPDM maven plugin broken](http://forums.adobe.com/thread/907124)

- [Alex Manarpies repository](http://code.google.com/p/flex-maven-repo/)