
(function() {
  var Pendulum, Point2D, Preset, Trigger, init;

  init = function() {
    var sketch;
    return sketch = Sketch.create({
      down: false,
      pendulums: null,
      triggers: null,
      presets: null,
      currentPreset: null,
      frameCount: null,
      freq: null,
      preset: null,
      volume: null,
      restart: null,
      audioContext: null,
      gain: null,
      NUM_PENDULUMS: 24,
      OFFSET: 45,
      container: document.getElementById('container'),
      setup: function() {
        this.frameCount = 0;
        this.volume = 1;
        this.freq = 7 / 60;
        this.initAudio();
        this.initPresets();
        this.initTriggers();
        this.initPendulums();
        return this.initGUI();
      },
      update: function() {
        var p, t, time, _i, _j, _len, _len1, _ref, _ref1;
        time = this.frameCount += 1 / 60;
        _ref = this.pendulums;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          p.freq = this.freq;
          p.update(time);
          p.pos.x = floor((sketch.width - (this.NUM_PENDULUMS - 1) * this.OFFSET) * .5) + p.index * this.OFFSET;
          p.pos.y += sketch.height * .5;
        }
        _ref1 = this.triggers;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          t = _ref1[_j];
          t.update();
          t.pos.x = floor((sketch.width - (this.NUM_PENDULUMS - 1) * this.OFFSET) * .5) + t.index * this.OFFSET;
          t.pos.y = sketch.height * .5;
        }
        return this.gain.gain.value = this.volume;
      },
      draw: function() {
        var alpha, dy, gray, i, j, o, p, t, _i, _j, _k, _l, _len, _len1, _ref, _ref1, _ref2, _results;
        sketch.lineWidth = 1;
        sketch.moveTo(0, sketch.height * .5);
        sketch.lineTo(sketch.width, sketch.height * .5);
        sketch.strokeStyle = 'rgb(40, 40, 40)';
        sketch.stroke();
        _ref = this.triggers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          t = _ref[_i];
          t.draw();
        }
        sketch.globalCompositeOperation = 'lighter';
        sketch.lineWidth = 1;
        for (i = _j = 0, _ref1 = this.NUM_PENDULUMS; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          p = this.pendulums[i];
          gray = 80;
          for (j = _k = 0; _k < 5; j = ++_k) {
            if (i > j) {
              o = this.pendulums[i - (j + 1)];
              if (o.direction === p.direction) {
                gray = 120;
              }
              dy = min(Math.abs(p.pos.y - o.pos.y), 100);
              alpha = 1 - dy / 100;
              sketch.beginPath();
              sketch.moveTo(p.pos.x, p.pos.y);
              sketch.lineTo(o.pos.x, o.pos.y);
              sketch.strokeStyle = 'rgba(' + gray + ', ' + gray + ', ' + gray + ', ' + alpha + ')';
              sketch.stroke();
            }
          }
        }
        /*
        			for i in [0...@NUM_PENDULUMS]
        				p = @pendulums[i]
        				t = @triggers[i]
        				sketch.moveTo(p.pos.x, p.pos.y)
        				sketch.lineTo(t.pos.x, t.pos.y)
        			sketch.strokeStyle = 'rgba(50, 200, 220, 0.2)'
        			sketch.stroke()
        */

        _ref2 = this.pendulums;
        _results = [];
        for (_l = 0, _len1 = _ref2.length; _l < _len1; _l++) {
          p = _ref2[_l];
          _results.push(p.draw());
        }
        return _results;
      },
      mousedown: function() {
        var dd, dx, dy, t, _i, _len, _ref, _results;
        this.down = true;
        _ref = this.triggers;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          t = _ref[_i];
          dx = sketch.mouse.x - t.pos.x;
          dy = sketch.mouse.y - t.pos.y;
          dd = dx * dx + dy * dy;
          if (dd > Trigger.HIT_RADIUS_SQ) {
            continue;
          }
          _results.push(t.mousedown());
        }
        return _results;
      },
      mouseup: function() {
        return this.down = false;
      },
      mousemove: function() {
        var dd, dx, dy, t, _i, _len, _ref, _results;
        if (!this.triggers) {
          return;
        }
        _ref = this.triggers;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          t = _ref[_i];
          dx = sketch.mouse.x - t.pos.x;
          dy = sketch.mouse.y - t.pos.y;
          dd = dx * dx + dy * dy;
          if (dd < Trigger.HIT_RADIUS_SQ) {
            _results.push(t.mouseover());
          } else if (t.over) {
            _results.push(t.mouseout());
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      },
      initAudio: function() {
        if (typeof webkitAudioContext !== "function") {
          return;
        }
        this.audioContext = new AudioContext();
        this.gain = this.audioContext.createGain();
        return this.gain.connect(this.audioContext.destination);
      },
      initPresets: function() {
        var param, urlPreset;
        this.presets = [];
        this.presets.push(new Preset('preset 1', this.presets.length, 7 / 60, [2, 1, 1, 1, 2, 1, 3, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 3, 1, 2, 1, 1, 1]));
        this.presets.push(new Preset('preset 2', this.presets.length, 13 / 60, [0, 0, 2, 0, 5, 3, 3, 3, 2, 2, 0, 2, 0, 0, 2, 0, 0, 0, 3, 3, 0, 0, 0, 0]));
        this.currentPreset = this.presets[0];
        param = this.getParam('p');
        if (param) {
          urlPreset = this.decodePreset(param);
        }
        if (urlPreset) {
          this.presets.push(urlPreset);
          this.currentPreset = urlPreset;
          return this.preset = urlPreset.index;
        }
      },
      initTriggers: function() {
        var i, pitch, pos, t, type, _i, _ref, _results;
        this.triggers = [];
        _results = [];
        for (i = _i = 0, _ref = this.NUM_PENDULUMS; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          pos = new Point2D(i * this.OFFSET, 0);
          type = this.currentPreset.types[i];
          if (i > this.NUM_PENDULUMS * .5) {
            pitch = pow((i - this.NUM_PENDULUMS) / 12, 2) + 1;
          } else {
            pitch = pow(i / 12, 2) + 1;
          }
          t = new Trigger(sketch, this.audioContext, this.gain, i, pos, type, pitch);
          _results.push(this.triggers.push(t));
        }
        return _results;
      },
      initPendulums: function() {
        var i, p, pos, trigger, _i, _ref, _results;
        this.pendulums = [];
        this.freq = this.currentPreset.freq;
        _results = [];
        for (i = _i = 0, _ref = this.NUM_PENDULUMS; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          pos = new Point2D(i * this.OFFSET, 0);
          trigger = this.triggers[i];
          p = new Pendulum(sketch, i, pos, this.freq, 1 * i, trigger);
          _results.push(this.pendulums.push(p));
        }
        return _results;
      },
      initGUI: function() {
        var gui, p, presetNames, _i, _len, _ref,
          _this = this;
        this.restart = function() {
          this.frameCount = 0;
          return this.update();
        };
        this.save = function() {
          var c, hasURL, _i, _len, _ref;
          hasURL = false;
          this.url = 'http://www.brunoimbrizi.com/experiments/#/06?p=' + this.encodePreset();
          _ref = this.gui.__controllers;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            c = _ref[_i];
            if (c.property === 'url') {
              c.setValue(this.url);
              c.updateDisplay();
              hasURL = true;
              break;
            }
          }
          if (!hasURL) {
            c = this.gui.add(this, 'url');
          }
          c.domElement.firstChild.focus();
          return c.domElement.firstChild.select();
        };
        presetNames = {};
        _ref = this.presets;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          presetNames[p.name] = p.index;
        }
        gui = new dat.GUI();
        gui.add(this, 'preset', presetNames).onChange(function(value) {
          var i, t, _j, _ref1, _results;
          _this.currentPreset = _this.presets[value];
          _this.freq = _this.currentPreset.freq;
          _results = [];
          for (i = _j = 0, _ref1 = _this.NUM_PENDULUMS; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
            t = _this.triggers[i];
            _results.push(t.loadSound(_this.currentPreset.types[i]));
          }
          return _results;
        }).name('presets');
        gui.add(this, 'freq').min(1 / 60).max(1.0).step(1 / 60).listen();
        gui.add(this, 'volume').min(0).max(1.0);
        gui.add(this, 'restart');
        gui.add(this, 'save').name('save');
        return this.gui = gui;
      },
      getParam: function(name) {
        var regex, regexS, results;
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        regexS = "[\\?&]" + name + "=([^&#]*)";
        regex = new RegExp(regexS);
        results = regex.exec(window.location.search);
        if (!results) {
          return '';
        }
        return decodeURIComponent(results[1].replace(/\+/g, " "));
      },
      encodePreset: function() {
        var str, t, _i, _len, _ref;
        str = '';
        str += this.freq + ',';
        _ref = this.triggers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          t = _ref[_i];
          str += t.type + ',';
        }
        str = str.substr(0, str.length - 1);
        return str;
      },
      decodePreset: function(str) {
        var freq, i, index, t, types, _i, _ref;
        index = str.indexOf(',');
        freq = parseFloat(str.substring(0, index));
        freq = max(freq, 0.0);
        freq = min(freq, 1.0);
        types = str.substring(index + 1).split(',');
        for (i = _i = 0, _ref = this.NUM_PENDULUMS; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (types[i]) {
            t = floor(types[i]);
            t = max(t, 0);
            t = min(t, 5);
            types[i] = t;
          } else {
            types[i] = 0;
          }
        }
        return new Preset('from url', this.presets.length, freq, types);
      }
    });
  };

  init();

  Pendulum = (function() {

    Pendulum.prototype.ctx = null;

    Pendulum.prototype.trigger = null;

    Pendulum.prototype.index = null;

    Pendulum.prototype.pos = null;

    Pendulum.prototype.oldY = null;

    Pendulum.prototype.radius = null;

    Pendulum.prototype.color = null;

    Pendulum.prototype.delay = null;

    Pendulum.prototype.freq = null;

    Pendulum.prototype.oldFreq = null;

    Pendulum.prototype.direction = null;

    Pendulum.prototype.AMPLITUDE = 100;

    function Pendulum(ctx, index, pos, freq, delay, trigger) {
      this.ctx = ctx;
      this.index = index;
      this.pos = pos;
      this.freq = freq;
      this.delay = delay;
      this.trigger = trigger;
      this.color = 'rgb(200, 200, 200)';
      this.radius = 4.0;
    }

    Pendulum.prototype.update = function(time) {
      if (time < this.delay) {
        return;
      }
      this.pos.y = sin(this.freq * (time - this.delay) * TWO_PI) * this.AMPLITUDE;
      this.direction = this.pos.y > this.oldY;
      if (this.freq === this.oldFreq && this.oldY * this.pos.y < 0) {
        this.trigger.fire();
      }
      this.oldY = this.pos.y;
      return this.oldFreq = this.freq;
    };

    Pendulum.prototype.draw = function() {
      this.ctx.translate(this.pos.x, this.pos.y);
      this.ctx.beginPath();
      this.ctx.arc(0, 0, this.radius, 0, TWO_PI);
      this.ctx.fillStyle = this.color;
      this.ctx.fill();
      this.ctx.closePath();
      return this.ctx.setTransform(1, 0, 0, 1, 0, 0);
    };

    return Pendulum;

  })();

  Point2D = (function() {

    Point2D.prototype.x = null;

    Point2D.prototype.y = null;

    function Point2D(x, y) {
      this.x = x;
      this.y = y;
    }

    Point2D.prototype.distanceTo = function(p) {
      var dx, dy;
      dx = this.x - p.x;
      dy = this.y - p.y;
      return sqrt(dx * dx + dy * dy);
    };

    return Point2D;

  })();

  Preset = (function() {

    Preset.prototype.freq = null;

    Preset.prototype.types = null;

    Preset.prototype.index = null;

    Preset.prototype.name = null;

    function Preset(name, index, freq, types) {
      this.name = name;
      this.index = index;
      this.freq = freq;
      this.types = types;
    }

    return Preset;

  })();

  Trigger = (function() {

    Trigger.prototype.ctxCanvas = null;

    Trigger.prototype.ctxAudio = null;

    Trigger.prototype.index = null;

    Trigger.prototype.type = null;

    Trigger.prototype.pos = null;

    Trigger.prototype.radius = null;

    Trigger.prototype.color = null;

    Trigger.prototype.fired = null;

    Trigger.prototype.blast = null;

    Trigger.prototype.hover = null;

    Trigger.prototype.buffer = null;

    Trigger.prototype.sound = null;

    Trigger.prototype.pitch = null;

    Trigger.prototype.gain = null;

    Trigger.prototype.wetGain = null;

    Trigger.prototype.flange = null;

    Trigger.prototype.over = null;

    Trigger.TYPE_OFF = 0;

    Trigger.TYPE_SHAKER = 1;

    Trigger.TYPE_HIHAT = 2;

    Trigger.TYPE_KICK = 3;

    Trigger.TYPE_BLOCK = 4;

    Trigger.TYPE_CLAP = 5;

    Trigger.prototype.SOUND_SHAKER = 'shaker';

    Trigger.prototype.SOUND_HIHAT = 'hihat';

    Trigger.prototype.SOUND_KICK = 'kick';

    Trigger.prototype.SOUND_BLOCK = 'block';

    Trigger.prototype.SOUND_CLAP = 'clap';

    Trigger.HIT_RADIUS_SQ = 100;

    function Trigger(ctxCanvas, ctxAudio, gain, index, pos, type, pitch) {
      this.ctxCanvas = ctxCanvas;
      this.ctxAudio = ctxAudio;
      this.gain = gain;
      this.index = index;
      this.pos = pos;
      this.type = type;
      this.pitch = pitch;
      this.radius = 2;
      this.color = 'rgb(40, 40, 40)';
      this.fired = false;
      this.blast = {
        radius: 3,
        alpha: 1,
        lineWidth: 1,
        color: null
      };
      this.hover = {
        radius: 0
      };
      this.loadSound(this.type);
    }

    Trigger.prototype.update = function() {};

    Trigger.prototype.draw = function() {
      this.ctxCanvas.translate(this.pos.x, this.pos.y);
      this.ctxCanvas.beginPath();
      this.ctxCanvas.arc(0, 0, this.hover.radius, 0, TWO_PI);
      this.ctxCanvas.fillStyle = 'rgba(' + this.blast.color + ', 0.8)';
      this.ctxCanvas.fill();
      this.ctxCanvas.closePath();
      this.ctxCanvas.beginPath();
      this.ctxCanvas.arc(0, 0, this.blast.radius, 0, TWO_PI);
      this.ctxCanvas.lineWidth = this.blast.lineWidth;
      this.ctxCanvas.strokeStyle = 'rgba(' + this.blast.color + ',' + this.blast.alpha + ')';
      this.ctxCanvas.stroke();
      this.ctxCanvas.closePath();
      this.ctxCanvas.beginPath();
      this.ctxCanvas.arc(0, 0, this.radius, 0, TWO_PI);
      this.ctxCanvas.fillStyle = this.color;
      this.ctxCanvas.fill();
      this.ctxCanvas.closePath();
      return this.ctxCanvas.setTransform(1, 0, 0, 1, 0, 0);
    };

    Trigger.prototype.mousedown = function() {
      if (this.type < 5) {
        return this.loadSound(this.type + 1);
      } else {
        return this.loadSound(0);
      }
    };

    Trigger.prototype.mouseover = function() {
      if (this.over) {
        return;
      }
      this.over = true;
      return TweenLite.to(this.hover, 0.2, {
        radius: 12,
        ease: Quart.easeOut
      });
    };

    Trigger.prototype.mouseout = function() {
      if (!this.over) {
        return;
      }
      this.over = false;
      return TweenLite.to(this.hover, 0.2, {
        radius: 0,
        ease: Quart.easeOut
      });
    };

    Trigger.prototype.fire = function() {
      var _this = this;
      if (!this.type) {
        return;
      }
      this.fired = true;
      this.blast.radius = 4;
      this.blast.alpha = 0.8;
      TweenLite.to(this.blast, 0.1, {
        radius: 15,
        alpha: 1,
        lineWidth: 15,
        ease: Linear.easeOut,
        onComplete: function() {
          return TweenLite.to(_this.blast, 0.5, {
            radius: 3,
            lineWidth: 1,
            ease: Quart.easeOut
          });
        }
      });
      return this.playSound();
    };

    Trigger.prototype.loadSound = function(type) {
      var request, url,
        _this = this;
      this.type = type;
      switch (this.type) {
        case Trigger.TYPE_OFF:
          this.sound = null;
          this.blast.color = '50, 50, 50';
          break;
        case Trigger.TYPE_SHAKER:
          this.sound = this.SOUND_SHAKER;
          this.blast.color = '50, 200, 220';
          break;
        case Trigger.TYPE_HIHAT:
          this.sound = this.SOUND_HIHAT;
          this.blast.color = '25, 100, 140';
          break;
        case Trigger.TYPE_KICK:
          this.sound = this.SOUND_KICK;
          this.blast.color = '140, 25, 55';
          break;
        case Trigger.TYPE_BLOCK:
          this.sound = this.SOUND_BLOCK;
          this.blast.color = '165, 165, 50';
          break;
        case Trigger.TYPE_CLAP:
          this.sound = this.SOUND_CLAP;
          this.blast.color = '80, 155, 45';
      }
      if (!this.ctxAudio) {
        return;
      }
      if (!this.sound) {
        return;
      }
      url = 'sounds/' + this.sound + '.ogg';
      request = new XMLHttpRequest();
      request.open('GET', url, true);
      request.responseType = 'arraybuffer';
      request.onload = function() {
        return _this.ctxAudio.decodeAudioData(request.response, function(buffer) {
          return _this.buffer = buffer;
        });
      };
      return request.send();
      /*
      		# create mix gain nodes
      		audioContext = @ctxAudio
      		outputMix = audioContext.createGainNode()
      		dryGain = audioContext.createGainNode()
      		wetGain = audioContext.createGainNode()
      		effectInput = audioContext.createGainNode()
      		# audioInput.connect(dryGain)
      		# audioInput.connect(effectInput)
      		dryGain.connect(outputMix)
      		wetGain.connect(outputMix)
      		outputMix.connect( audioContext.destination)
      
      		@wetGain = wetGain
      		@flange = @initFlange()
      		@flange.connect(@ctxAudio.destination)
      */

    };

    Trigger.prototype.playSound = function() {
      var source;
      if (!this.ctxAudio) {
        return;
      }
      if (!this.buffer) {
        return;
      }
      source = this.ctxAudio.createBufferSource();
      source.buffer = this.buffer;
      source.connect(this.gain);
      source.playbackRate.value = this.pitch;
      return source.start(0);
    };

    /*
    	initFlange: ->
    		delayNode = @ctxAudio.createDelayNode()
    		delayNode.delayTime.value = 0.005
    		fldelay = delayNode
    
    		inputNode = @ctxAudio.createGainNode()
    		feedback = @ctxAudio.createGainNode()
    		osc = @ctxAudio.createOscillator()
    		gain = @ctxAudio.createGainNode()
    		gain.gain.value = 0.002
    		fldepth = gain
    
    		feedback.gain.value = 0.5
    		flfb = feedback
    
    		osc.type = osc.SINE
    		osc.frequency.value = 0.25
    		flspeed = osc
    
    		osc.connect(gain)
    		gain.connect(delayNode.delayTime)
    
    		inputNode.connect( @wetGain )
    		inputNode.connect( delayNode )
    		delayNode.connect( @wetGain )
    		delayNode.connect( feedback )
    		feedback.connect( inputNode )
    
    		osc.noteOn(0)
    
    		return inputNode
    */


    return Trigger;

  })();

}).call(this);
