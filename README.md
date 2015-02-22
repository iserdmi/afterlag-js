# Afterlag.js
Afterlag.js позволяет отслеживать событие прекращения лагов при загрузке страницы.

Обычно мы запускаем что-то в момент загрузки страницы. Однако, еще какое-то время страница «тормозит». Если в этот момент запустить, например, анимацию появления каких-то блоков на сайте, анимация будет дёргаться и испортит всё впечатление. С помощью Afterlag.js можно запустить эту анимацию в тот момент, когда она сможет воспроизвестиь гладко и без лагов.

Afterlag.js реализована на нативном JavaScript. Также есть плагин для jQuery. Плагин отлично работает из коробки и не требует дополнительных настроек. Изощренный разработчик может покапатьяся в настройках и настроить Afterlag.js под себя.

## Быстрый старт
Выберите какой плагин вы будете использовать, нативный или jQuery. Затем добавьте его на свою HTML страницу.
```
<script src="aftelag.js" type="text/javascript"></script>
```
```
// Нативный JavaScript
afterlag = new Afterlag();
afterlag.do(function() {
  console.log('Лаги прошли, пора начинать!');
});
afterlag.do(function() {
  console.log('Анонимные функции, поднимайтесь!');
});
```
При подключении файла с jQuery плагином, не нужно подключать файл с нативным плагином.
```
<script src="jquery.aftelag.js" type="text/javascript"></script>
```
```
// jQuery плагин
$.afterlag(function() {
  console.log('Лаги прошли, пора начинать!');
});
$.afterlag(function() {
  console.log('Анонимные функции, поднимайтесь!');
});
```

## Принцип работы
При создании нового объекта `new Afterlag()` запускается интервал, который каждые 30 милесекунд проверяет сколько реально времени прошло с момента его последнего запуска. Если прошло как ожидалось 30 миллесекунд, значит лаги кончились. Чтобы убедиться наверняка, ждём пока время сойдётся 3 раза подряд. Все перечисленные выше значения можно изменить в настройках.

После того как лаги пройдут, будут вызваны все функции переданные через `afterlag.do()`. Если функция будет передана в `afterlag.do()` уже после того, как ончатся лаги, функция будет вызвана немедленно.

При вызове `$.afterlag()` автоматически будет создан новый объект, если прежде уже был вызван `$.afterlag()`, вместо нового объекта возьмётся старый. Функция переданная в `$.afterlag()` будет вызвана после окончания лагов.

## Использование нативного палгина
```
// Создание нового объекта
afterlag = new Afterlag([options])
```
Объект содержит в себе API Afterlag.js.

```
// Добавление колбэка
afterlag.do(function(info) {})
```
Переданная функция будет вызвана по завершению лагов. Если лаги уже кончились, функция будет вызвана сразу же. Внутри переданной функции перменная `this` будет содержать в себе API Afterlag.js. Переменная `info` является объектом и несёт в себе информацию об объекте `afterlag` в момент вызова переданной функции:  
* **`info.status`**  
`"success"`, если лаги действительно кончились. `"timeout"`, если лаги не кончились, но первышено время ожидания окончания лагов.  

* **`info.time_passed`**  
Количество милесекунд прошедшие с момента создания объектов до окончания лагов.

* **`info.ready`**  
Если лаги кончились, то `true` , иначе `false`.  

* **`info.options`**  
Настройки переданные объекту при его создании.

```
// Добавление колбэка с указанием this
afterlag.do(object, function(info) {})
```
`object` будет доступен внутри переданной функции как `this`.

## Использование jQuery палгина
```
// Создание нового объекта
afterlag = $.afterlag([options])
```
Создание нового объекта таким образом равносильно вызову `new Afterlag([options])` при использовании нативного плагина. С полученным объектом можно делать всё, что описано в разделе «использование нативного палгина». По оконачанию лагов на $(document) будет вызвано событие `"afterlag"`.

```
// Создание нового колбэка
$.afterlag(function(info) {})
```
Если Afterlag.js вызывается впервые будет создан новый объект, иначе будет взят последний созданный объект. Фнукция возвращает используемый объект. В остальном работает также как и `afterlag.do()`. Внутри переданной функции перменная `this` будет содержать в себе API Afterlag.js.

```
// Создание колбэка и нового объекта
$.afterlag(true, function(info) {})

// Создание колбэка и нового объекта с передачей настроек
$.afterlag(options, function(info) {})
```
Если вам необходимо заново проверить есть ли лаги на странице, вы можете таким образом создать новый объект и передать в него колбэк.

```
$.afterlag(string)
$.afterlag(true, string)
$.afterlag(options, string)
```
Если вместо функции передать строку `string`, то по завершению лагов на `$(document)` будет вызвано событие переданное в `string`. Событие `"afterlag"` также будет вызвано.

```
$(selector).afterlag()
$(selector).afterlag(function(info) {})
$(selector).afterlag(true, function(info) {})
$(selector).afterlag(options, function(info) {})
$(selector).afterlag(string)
$(selector).afterlag(true, string)
$(selector).afterlag(options, string)
```
Вся разница заключается в том, что внутри переданных функций `this` будет содержать в себе `$(selector)`, а все события вместо того, чтобы вызываться на `$(document)` будут вызываться на `$(selector)`.

## API
```
afterlag = new Afterlag()
```
* **`afterlag.options`**  
Настройки переданные объекту при его создании.

* **`afterlag.ready`**  
Если лаги кончились, то `true` , иначе `false`.

* **`afterlag.status`**  
`"processing"`, если лаги еще не кончились. `"success"`, если лаги действительно кончились. `"timeout"`, если лаги Не кончились, но первышено время ожидания окончания лагов.

* **`afterlag.time_passed`**  
Количество милесекунд прошедшие с момента создания объектов до окончания лагов.

* **`afterlag.do()`**  
Метод для добавления колбэков.

# Настройки
```
// Ниже перечислены настройки установленные по умолчанию
afterlag = new Afterlag({
  delay: 100
  frequency: 30
  iterations: 3
  duration: null
  scatter: 5
  timeout: null
})
```
* **`delay`** по умолчанию 100  
В первое мгновение не всегда могут быть лаги. Но они появятся чуть позже. Значение `delay` определяет, какое количество милесекунд после создания объекта не стоит доверять информации о том, что лагов нет.

* **`frequency`** по умолчанию 30  
В какие промежутки времени нужно проверять есть лаги или нет.

* **`iterations`**: по умолчанию 3  
Сколько раз подряд должно получиться так, что время прошедшее с последней проверки дейсвительно равно значению `frequency`.

* **`duration`**  
Вместо того, чтобы указывать `iterations` , можно обозначить продолжительность. Таким образом значение `iterations` будет вычислено по формуле: `Math.ceil(duration / frequency)`.

* **`scatter`**: по умолчанию 5  
Допустимая погрешность при сверении прошедшего времени со временм указанным в `frequency`.

* **`timeout`**  
Время после которого следует вызвать все функции переданные в колбэк, не дожидаясь окончания лагов.
