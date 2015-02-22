#= include afterlag.coffee

do ($=jQuery) ->
  last_afterlag = null

  $.afterlag = (options={}) ->
    last_afterlag = new Afterlag(options)
    last_afterlag

  $.fn.afterlag = (options, callback) ->
    if not options?
      options = {}
      afterlag = if last_afterlag? then last_afterlag else $.afterlag()
    else if not callback?
      if typeof options == 'function'
        callback = options
        options = {}
        afterlag = if last_afterlag? then last_afterlag else $.afterlag()
      else if typeof options == 'string'
        callback = (info) -> $(@).trigger options, [info]
        afterlag = if last_afterlag? then last_afterlag else $.afterlag()
    else
      if options == true
        afterlag = $.afterlag()
      else if options instanceof Afterlag
        afterlag = options
      else
        afterlag = $.afterlag(options)

    this.each ->
      $element = $(@)
      $element.data 'afterlag', afterlag
      self = @
      afterlag.do (info) ->
        callback.call(self, info) if callback?
        $element.trigger 'afterlag', [info]