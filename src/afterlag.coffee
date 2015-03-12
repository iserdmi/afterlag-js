class AfterlagHelper
  @merge_options: (first_object, second_object) ->
    result_object = {}
    for key, el of first_object
      result_object[key] = el
    for key, el of second_object
      result_object[key] = el
    result_object

class Afterlag
  @defaults:
    delay: 200
    frequency: 50
    iterations: 10
    duration: null
    scatter: 5
    min_delta: null
    max_delta: null    
    timeout: null
    need_lags: false

  constructor: (options={}) ->
    @_set_options options
    @_callbacks = []
    self = @
    @ready = false
    @_lags_was = false
    @status = 'processing'
    if @options.timeout > 0
      @_timeout_process = setTimeout ->
        self._finish 'timeout'
      , @options.timeout
    @_success_iterations = 0
    @_preprocess = setTimeout ->
      self._time_started = new Date().getTime()
      self._last_checked = self._time_started
      self._process = setInterval ->
        now = new Date().getTime()
        delta = now - self._last_checked - self.options.frequency
        if self.options.min_delta < delta < self.options.max_delta
          if not self.options.need_lags or self._lags_was
            self._success_iterations++
            if self._success_iterations >= self.options.iterations
              self._finish 'success'
        else
          self._success_iterations = 0
          self._lags_was = true
        self._last_checked = now
      , self.options.frequency
    , @options.delay

  _set_options: (options) ->
    @options = AfterlagHelper.merge_options(@constructor.defaults, options)
    if @options.duration?
      @options.iterations = Math.ceil(@options.duration / @options.frequency)
    if not @options.min_delta?
      @options.min_delta = - @options.scatter
    if not @options.max_delta?
      @options.max_delta = @options.scatter

  info: ->
    if @time_passed?
      time_passed = @time_passed
    else
      now = new Date().getTime()
      time_passed = now - @_time_started
    status: @status
    time_passed: time_passed
    ready: @ready
    options: @options

  _finish: (status) ->
    clearTimeout(@_preprocess) if @_preprocess?
    clearInterval(@_process) if @_process?
    clearTimeout(@_timeout_process) if @_timeout_process?
    @ready = true
    @status = status
    now = new Date().getTime()
    @time_passed = now - @_time_started
    for callback in @_callbacks
      callback.fn.call(callback.self, @info())

  do: (self, fn) ->
    if not fn?
      [fn, self] = [self, @]
    if @ready
      fn.call(self, @info())
    else
      @_callbacks.push
        fn: fn
        self: self
    @

window.Afterlag = Afterlag