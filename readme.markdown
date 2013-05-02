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
По большому счету, большой разницы в сообщениях об ошибках нет, снова не найдены зависимости для плагина.

## Попытка номер три.
Пробую еще вариант, описанный в рекомендация от IntelliJ IDEA. Есть последняя версия плагина, которая доступна в репозитории.
Как ни странно, но это нехитрое действие приносит свои плоды и компиляция проходит успешно! Это первая удачная попытка
без особых плясок с бубном.
Делая нехитрое преобразование через свойста пробую перейти на последний флех-фраймворк, который есть в репозитории.
При переходе на другую версию flex, необходимо так же перевести на нее и плагин, который используется.
В целом попытка удалась, спускаемся по жизненному циклу дальше - запускаем тесты и пакуем результат.

## Ресурсы.
- [Самая старая версия из найденных. Последнее обновление - февраль 2009](http://code.google.com/p/flex-mojos/)
- [Версия до 4.0 еще org.sonatype.flexmojos. Последнее обновление - май 2011](https://docs.sonatype.org/display/FLEXMOJOS/Home)
- [Версия до 6.0.0. Самая полная документация. Последнее обновление - ноябрь 2012](https://docs.sonatype.org/display/FLEXMOJOS/Home)

- [Первый архив вопросов-ответов](http://www.mail-archive.com/flex-mojos@googlegroups.com/)
- [Второй архив вопросов-ответов](http://osdir.com/ml/flex-mojos)

- [Первая статья от Adobe по flexmojos v.4.0-RC2](http://www.adobe.com/devnet/flex/articles/flex-maven-flexmojos-pt1.html)
- [Вторая статья от Adobe по flexmojos v.4.0-RC2](http://www.adobe.com/devnet/flex/articles/flex-maven-flexmojos-pt2.html)
- [Третья статья от Adobe по flexmojos v.4.0-RC2](http://www.adobe.com/devnet/flex/articles/flex-maven-flexmojos-pt3.html)

- [Справка от IntelliJ IDEA по работе с flexmojos v.4.2-beta](http://wiki.jetbrains.net/intellij/Working_with_Flexmojos_projects_in_IntelliJ_IDEA)

