# Afterlag.js
Afterlag.js — plugin for tracking page load lags.

Ordinarily we are executing something just after page loads. However it is a period while page slows. If you start animation at this point, before loading of some blocks on page, animation will twitch and spoil the impression. 

Afterlag allows you to begin animation immediately when it can run smoothly and without lags. See [demo](http://serdmi.com/demo/afterlag/).

Afterlag is built in native Javascript. jQuery plugin also exists. Plugin works out of the box and doesn't require additional configuration. However sophisticated soul will dig settings to configure Afterlag for itself.

## Быстрый старт
Выберите, какой плагин вы будете использовать: нативный или джэйквери. Затем добавьте файл с плагином на свой сайт.
```html
<script src="https://cdn.rawgit.com/iserdmi/afterlag-js/1.0.5/dist/afterlag.min.js"></script>
```
```js
// Нативный яваскрипт
afterlag = new Afterlag();
afterlag.do(function() {
  console.log('Лаги прошли, пора начинать!');
});
afterlag.do(function() {
  console.log('Анонимные функции, поднимайтесь!');
});
```
При подключении файла с джэйквери плагином, не нужно подключать файл с нативным плагином.
```html
<script src="https://cdn.rawgit.com/iserdmi/afterlag-js/1.0.5/dist/jquery.afterlag.min.js"></script>
```
```js
// Джэйквери плагин
$.afterlag(function() {
  console.log('Лаги прошли, пора начинать!');
});
$.afterlag(function() {
  console.log('Анонимные функции, поднимайтесь!');
});
```

## Принцип работы
При создании нового объекта `new Afterlag()` запускается интервал, который каждые 50 миллисекунд проверяет, сколько реально времени прошло с момента его последнего запуска. Если прошло 50 миллисекунд — как ожидалось — значит, лаги кончились. Чтобы убедиться наверняка, ждём, пока время сойдётся 10 раз подряд. Все перечисленные выше значения можно изменить в настройках.

После того как лаги пройдут, будут вызваны все функции переданные через `afterlag.do()`. Если функция будет передана в `afterlag.do()` уже после того, как кончатся лаги, функция будет вызвана немедленно.

При вызове `$.afterlag()` автоматически будет создан новый объект, если прежде уже был вызван `$.afterlag()`, вместо нового объекта возьмётся старый. Функция, переданная в `$.afterlag()`, будет вызвана после окончания лагов.

## Использование нативного плагина
```js
// Создание нового объекта
afterlag = new Afterlag([options])
```
Объект содержит в себе API афтерлага.

```js
// Добавление колбэка
afterlag.do(function(info) {})
```
Переданная функция будет вызвана по завершении лагов. Если лаги уже кончились, функция будет вызвана сразу же. Внутри переданной функции переменная `this` будет содержать в себе API афтерлага. Переменная `info` является объектом и несёт в себе информацию об объекте `afterlag` в момент вызова переданной функции:  
* **`info.status`**  
`"success"`, если лаги действительно кончились. `"timeout"`, если лаги не кончились, но превышено время ожидания окончания лагов.  

* **`info.time_passed`**  
Количество миллисекунд, прошедшее с момента создания объектов до окончания лагов.

* **`info.ready`**  
Если лаги кончились, то `true` , иначе `false`.  

* **`info.options`**  
Настройки, переданные объекту при его создании.

```js
// Добавление колбэка с указанием this
afterlag.do(object, function(info) {})
```
`object` будет доступен внутри переданной функции как `this`.

## Использование джэйквери плагина
```js
// Создание нового объекта
afterlag = $.afterlag([options])
```
Создание нового объекта, таким образом, равносильно вызову `new Afterlag([options])` при использовании нативного плагина. С полученным объектом можно делать всё, что описано в разделе «использование нативного плагина». По окончании лагов на `$(document)` будет вызвано событие `"afterlag"`.

```js
// Создание нового колбэка
$.afterlag(function(info) {})
```
Если афтерлаг вызывается впервые, будет создан новый объект, иначе будет взят последний созданный объект. Функция возвращает используемый объект. В остальном работает также как и `afterlag.do()`. Внутри переданной функции переменная `this` будет содержать в себе API афтерлага.

```js
// Создание колбэка и нового объекта
$.afterlag(true, function(info) {});

// Создание колбэка и нового объекта с передачей настроек
$.afterlag(options, function(info) {});
```
Если вам необходимо заново проверить есть ли лаги на странице, вы можете таким образом создать новый объект и передать в него колбэк.

```js
$.afterlag(string);
$.afterlag(true, string);
$.afterlag(options, string);
```
Если вместо функции передать строку `string`, то по завершении лагов на `$(document)` будет вызвано событие, переданное в `string`. Событие `"afterlag"` также будет вызвано.

```js
$(selector).afterlag();
$(selector).afterlag(function(info) {});
$(selector).afterlag(true, function(info) {});
$(selector).afterlag(options, function(info) {});
$(selector).afterlag(string);
$(selector).afterlag(true, string);
$(selector).afterlag(options, string);
```
Вся разница заключается в том, что внутри переданных функций `this` будет содержать в себе `$(selector)`, а все события вместо того, чтобы вызываться на `$(document)` будут вызываться на `$(selector)`.

## API
```js
afterlag = new Afterlag()
```
* **`afterlag.options`**  
Настройки переданные объекту при его создании.

* **`afterlag.ready`**  
Если лаги кончились, то `true` , иначе `false`.

* **`afterlag.status`**  
`"processing"`, если лаги еще не кончились. `"success"`, если лаги действительно кончились. `"timeout"`, если лаги не кончились, но превышено время ожидания окончания лагов.

* **`afterlag.time_passed`**  
Количество миллисекунд, прошедшее с момента создания объектов до окончания лагов.

* **`afterlag.do()`**  
Метод для добавления колбэков.

# Настройки
```js
// Ниже перечислены настройки, установленные по умолчанию
afterlag = new Afterlag({
  delay: 200,
  frequency: 50,
  iterations: 10,
  duration: null,
  scatter: 5,
  timeout: null,
  need_lags: false
})
```
* **`delay`** по умолчанию `200`  
В первое мгновение не всегда могут быть лаги. Но они появятся чуть позже. Значение `delay` определяет, какое количество миллисекунд после создания объекта не стоит доверять информации о том, что лагов нет.

* **`frequency`** по умолчанию `50`  
В какие промежутки времени нужно проверять есть лаги или нет.

* **`iterations`** по умолчанию `10`  
Сколько раз подряд должно получиться так, что время, прошедшее с последней проверки действительно равно значению `frequency`.

* **`duration`**  
Вместо того чтобы указывать `iterations` , можно обозначить продолжительность. Таким образом, значение `iterations` будет вычислено по формуле: `Math.ceil(duration / frequency)`.

* **`scatter`** по умолчанию `5`  
Допустимая погрешность при сверке прошедшего времени со временем указанным в `frequency`.

* **`timeout`**  
Время, после которого следует вызвать все функции, переданные в колбэк, не дожидаясь окончания лагов.

* **`need_lags`** по умолчанию `false`  
При значении `false` афтерлаг сработает либо, если лаги закончатся, либо, если они даже не начнутся. Значение `true` разрешает афтерлагу сработать только после окончания лагов, то есть если лагов не было, афтелаг не сработает. Устанавливая значение `true` не забудьте также установить значение для `timeout`, в противно случае, если лагов не будет, афтерлаг так и не сработает.

## How to grab it?
Grab via bower:  
`$ bower install afterlag-js`

Grab via npm:  
`$ npm install afterlag-js`

Latest version CDN link (change 1.0.5 to older version if needed):
```
https://cdn.rawgit.com/iserdmi/afterlag-js/1.0.5/dist/afterlag.min.js
https://cdn.rawgit.com/iserdmi/afterlag-js/1.0.5/dist/jquery.afterlag.min.js
```

At the worst try direct download.
