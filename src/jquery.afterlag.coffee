#= include afterlag.coffee

do ($=jQuery) ->
  last_afterlag = null

  new_faterlag = (options={}) ->
    last_afterlag = new Afterlag(options)
    last_afterlag

  normalize_data = (options, callback) ->
    trigger = null
    if not options?
      afterlag = if last_afterlag? then last_afterlag else new_faterlag()
    else if not callback?
      if typeof options == 'function'
        callback = options
        afterlag = if last_afterlag? then last_afterlag else new_faterlag()
      else if typeof options == 'string'
        trigger = options
        callback = null        
      afterlag = if last_afterlag? then last_afterlag else new_faterlag()
    else
      if options == true
        afterlag = new_faterlag()
      else if options instanceof Afterlag
        afterlag = options
      else
        afterlag = new_faterlag(options)
      if typeof callback == 'string'
        trigger = callback
        callback = null        
    afterlag: afterlag
    callback: callback
    trigger: trigger

  $.afterlag = (options, callback) ->
    data = normalize_data(options, callback)
    data.afterlag.do (info) ->
      data.callback.call(data.afterlag, info) if data.callback?
      $(document).trigger 'afterlag', [info]
      if data.trigger?
        $(document).trigger data.trigger, [info]
    data.afterlag

  $.fn.afterlag = (options, callback) ->
    data = normalize_data(options, callback)
    this.each ->
      $element = $(@)
      $element.data 'afterlag', data.afterlag
      self = @
      data.afterlag.do (info) ->
        data.callback.call(self, info) if data.callback?
        $element.trigger 'afterlag', [info]
        if data.trigger?
          $element.trigger data.trigger, [info]