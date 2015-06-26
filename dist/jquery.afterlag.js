/* Afterlag.js 2.0.2 — Plugin for tracking page load lags. Author: Sergey Dmitriev (http://serdmi.com). Licensed MIT. */
(function() {
  var Afterlag, AfterlagHelper;

  AfterlagHelper = (function() {
    function AfterlagHelper() {}

    AfterlagHelper.merge_options = function(first_object, second_object) {
      var el, key, result_object;
      result_object = {};
      for (key in first_object) {
        el = first_object[key];
        result_object[key] = el;
      }
      for (key in second_object) {
        el = second_object[key];
        result_object[key] = el;
      }
      return result_object;
    };

    return AfterlagHelper;

  })();

  Afterlag = (function() {
    Afterlag.defaults = {
      delay: 200,
      frequency: 50,
      iterations: 10,
      duration: null,
      scatter: 5,
      min_delta: null,
      max_delta: null,
      timeout: null,
      need_lags: false
    };

    function Afterlag(options) {
      var self;
      if (options == null) {
        options = {};
      }
      this._set_options(options);
      this._callbacks = [];
      self = this;
      this.ready = false;
      this._lags_was = false;
      this.status = 'processing';
      if (this.options.timeout > 0) {
        this._timeout_process = setTimeout(function() {
          return self._finish('timeout');
        }, this.options.timeout);
      }
      this._success_iterations = 0;
      this._preprocess = setTimeout(function() {
        self._time_started = new Date().getTime();
        self._last_checked = self._time_started;
        return self._process = setInterval(function() {
          var delta, now;
          now = new Date().getTime();
          delta = now - self._last_checked - self.options.frequency;
          if ((self.options.min_delta < delta && delta < self.options.max_delta)) {
            if (!self.options.need_lags || self._lags_was) {
              self._success_iterations++;
              if (self._success_iterations >= self.options.iterations) {
                self._finish('success');
              }
            }
          } else {
            self._success_iterations = 0;
            self._lags_was = true;
          }
          return self._last_checked = now;
        }, self.options.frequency);
      }, this.options.delay);
    }

    Afterlag.prototype._set_options = function(options) {
      this.options = AfterlagHelper.merge_options(this.constructor.defaults, options);
      if (this.options.duration != null) {
        this.options.iterations = Math.ceil(this.options.duration / this.options.frequency);
      }
      if (this.options.min_delta == null) {
        this.options.min_delta = -this.options.scatter;
      }
      if (this.options.max_delta == null) {
        return this.options.max_delta = this.options.scatter;
      }
    };

    Afterlag.prototype.info = function() {
      var now, time_passed;
      if (this.time_passed != null) {
        time_passed = this.time_passed;
      } else {
        now = new Date().getTime();
        time_passed = now - this._time_started;
      }
      return {
        status: this.status,
        time_passed: time_passed,
        ready: this.ready,
        options: this.options
      };
    };

    Afterlag.prototype._finish = function(status) {
      var callback, i, len, now, ref, results;
      if (this._preprocess != null) {
        clearTimeout(this._preprocess);
      }
      if (this._process != null) {
        clearInterval(this._process);
      }
      if (this._timeout_process != null) {
        clearTimeout(this._timeout_process);
      }
      this.ready = true;
      this.status = status;
      now = new Date().getTime();
      this.time_passed = now - this._time_started;
      ref = this._callbacks;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        callback = ref[i];
        results.push(callback.fn.call(callback.self, this.info()));
      }
      return results;
    };

    Afterlag.prototype.run = function(self, fn) {
      var ref;
      if (fn == null) {
        ref = [self, this], fn = ref[0], self = ref[1];
      }
      if (this.ready) {
        fn.call(self, this.info());
      } else {
        this._callbacks.push({
          fn: fn,
          self: self
        });
      }
      return this;
    };

    return Afterlag;

  })();

  window.Afterlag = Afterlag;

  (function($) {
    var last_afterlag, new_faterlag, normalize_data;
    last_afterlag = null;
    new_faterlag = function(options) {
      if (options == null) {
        options = {};
      }
      last_afterlag = new Afterlag(options);
      return last_afterlag;
    };
    normalize_data = function(options, callback) {
      var afterlag, trigger;
      trigger = null;
      if (options == null) {
        afterlag = last_afterlag != null ? last_afterlag : new_faterlag();
      } else if (callback == null) {
        if (typeof options === 'function') {
          callback = options;
          afterlag = last_afterlag != null ? last_afterlag : new_faterlag();
        } else if (typeof options === 'string') {
          trigger = options;
          callback = null;
        }
        afterlag = last_afterlag != null ? last_afterlag : new_faterlag();
      } else {
        if (options === true) {
          afterlag = new_faterlag();
        } else if (options instanceof Afterlag) {
          afterlag = options;
        } else {
          afterlag = new_faterlag(options);
        }
        if (typeof callback === 'string') {
          trigger = callback;
          callback = null;
        }
      }
      return {
        afterlag: afterlag,
        callback: callback,
        trigger: trigger
      };
    };
    $.afterlag = function(options, callback) {
      var data;
      data = normalize_data(options, callback);
      data.afterlag.run(function(info) {
        if (data.callback != null) {
          data.callback.call(data.afterlag, info);
        }
        $(document).trigger('afterlag', [info]);
        if (data.trigger != null) {
          return $(document).trigger(data.trigger, [info]);
        }
      });
      return data.afterlag;
    };
    return $.fn.afterlag = function(options, callback) {
      var data;
      data = normalize_data(options, callback);
      return this.each(function() {
        var $element, self;
        $element = $(this);
        $element.data('afterlag', data.afterlag);
        self = this;
        return data.afterlag.run(function(info) {
          if (data.callback != null) {
            data.callback.call(self, info);
          }
          $element.trigger('afterlag', [info]);
          if (data.trigger != null) {
            return $element.trigger(data.trigger, [info]);
          }
        });
      });
    };
  })(jQuery);

}).call(this);
