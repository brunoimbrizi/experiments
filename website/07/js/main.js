(function() {
  var AppData, AppThree, AppUI, AppUtils, AppView, GUIData, LabelView, LineCollection, LineModel, LineView, MathUtils, PlatformModel, ScheduleCollection, ScheduleModel, StationCollection, StationModel, StringUtils, TrainCollection, TrainModel, TrainView,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  AppData = (function() {

    function AppData() {}

    AppData.IS_LOCAL = false;

    AppData.GET_LINES = 'json/lines.json';

    AppData.GET_STATIONS = 'json/stations.json';

    AppData.GET_PREDICTION_SUMMARY = 'xml/$code.xml';

    AppData.MAP_SIZE = 500000;

    AppData.TRAIN_SPEED = 10;

    return AppData;

  })();

  GUIData = (function() {

    function GUIData() {}

    GUIData.prototype.Bakerloo = false;

    GUIData.prototype.Central = true;

    GUIData.prototype.Circle = false;

    GUIData.prototype.District = false;

    GUIData.prototype.Hammersmith = false;

    GUIData.prototype.Jubilee = false;

    GUIData.prototype.Metropolitan = false;

    GUIData.prototype.Northern = false;

    GUIData.prototype.Piccadilly = false;

    GUIData.prototype.Victoria = false;

    GUIData.prototype.Waterloo = false;

    GUIData.prototype.speed = 10;

    GUIData.prototype.separate = false;

    GUIData.prototype.restart = null;

    GUIData.prototype.mute = false;

    return GUIData;

  })();

  AppUtils = (function() {

    function AppUtils() {}

    AppUtils.getSeconds = function(str) {
      var a, s;
      if (str.indexOf(':') < 0) {
        return 0;
      }
      a = str.split(':');
      if (a.length === 3) {
        s = (+a[0]) * 60 * 60 + (+a[1]) * 60 + (+a[2]);
      } else if (a.length === 2) {
        s = (+a[0]) * 60 + (+a[1]);
      } else {
        s = +a[0];
      }
      return s;
    };

    AppUtils.mercatorEncode = function(lng, lat, mapSize) {
      var maph, mapw, x, y;
      if (mapSize == null) {
        mapSize = 0;
      }
      lng = +lng;
      lat = lat * Math.PI / 180;
      if (!mapSize) {
        mapSize = AppData.MAP_SIZE;
      }
      mapw = maph = mapSize;
      x = (mapw * (180 + lng) / 360) % mapw;
      y = Math.log(Math.tan((lat * .5) + (Math.PI * .25)));
      y = (maph * .5) - (mapw * y / (2 * Math.PI));
      /*
      		# from https://gist.github.com/997450
      		x = (lng - lonOrigin) / (2 * Math.PI)
      		# while (x < 0) then x++
      		y = 1 - (Math.log(Math.tan(Math.PI/4 + lat/2)) * 0.31830988618 + 1)/2
      */

      return [x, y];
    };

    AppUtils.getTrainLocationValue = function(location) {
      var value;
      value = 0;
      if (location.indexOf('Between') === 0) {
        value = 0.5;
      }
      return value;
    };

    AppUtils.getTrainLastStation = function(location) {
      var pattern, result, station, stationName;
      pattern = /Between\s(.+)\sand\s/;
      result = pattern.exec(location);
      if (result) {
        stationName = result[1];
      }
      if (!stationName) {
        pattern = /(At|Approaching|Left|)\s(.+)/;
        result = pattern.exec(location);
        if (result) {
          stationName = result[2];
        }
      }
      if (!stationName) {
        return null;
      }
      station = app.stations.findWhere({
        name: stationName
      });
      if (station) {
        return station.get('code');
      } else {
        return console.log('AppUtils.getTrainLastStation : stationName ' + stationName + ' not found.');
      }
    };

    return AppUtils;

  })();

  MathUtils = (function() {

    function MathUtils() {}

    MathUtils.map = function(num, min1, max1, min2, max2, round, constrainMin, constrainMax) {
      var num1, num2;
      if (round == null) {
        round = false;
      }
      if (constrainMin == null) {
        constrainMin = true;
      }
      if (constrainMax == null) {
        constrainMax = true;
      }
      if (constrainMin && num < min1) {
        return min2;
      }
      if (constrainMax && num > max1) {
        return max2;
      }
      num1 = (num - min1) / (max1 - min1);
      num2 = (num1 * (max2 - min2)) + min2;
      if (round) {
        return Math.round(num2);
      }
      return num2;
    };

    MathUtils.hexToRgb = function(hex) {
      var b, g, r, result, rgb;
      result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
      if (!result) {
        return null;
      }
      r = parseInt(result[1], 16);
      g = parseInt(result[2], 16);
      b = parseInt(result[3], 16);
      rgb = r + ', ' + g + ', ' + b;
      return {
        r: r,
        g: g,
        b: b,
        rgb: rgb
      };
    };

    MathUtils.rgbToHex = function(r, g, b) {
      return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
    };

    return MathUtils;

  })();

  StringUtils = (function() {

    function StringUtils() {}

    StringUtils.addLeadingZero = function(num, zeros) {
      var i, string, _i;
      if (zeros == null) {
        zeros = 1;
      }
      string = String(num);
      for (i = _i = 0; 0 <= zeros ? _i < zeros : _i > zeros; i = 0 <= zeros ? ++_i : --_i) {
        if (num < Math.pow(10, i + 1) && num > -1) {
          string = '0' + string;
        }
      }
      return string;
    };

    return StringUtils;

  })();

  LineModel = (function(_super) {

    __extends(LineModel, _super);

    function LineModel() {
      return LineModel.__super__.constructor.apply(this, arguments);
    }

    LineModel.prototype.defaults = {
      code: null,
      name: null,
      color: null,
      branches: null,
      trains: null,
      date: null
    };

    LineModel.prototype.idAttribute = 'code';

    LineModel.prototype.gettingPrediction = null;

    LineModel.prototype.getPredictionSummary = function() {
      var _this = this;
      this.gettingPrediction = true;
      this.url = AppData.GET_PREDICTION_SUMMARY.replace('$code', this.get('code'));
      return this.fetch({
        dataType: 'xml',
        success: function(model, reponse) {
          console.log('LineModel.getPredictionSummary success');
          return _this.trigger('loaded', _this.get('code'));
        },
        error: function(model, reponse) {
          return console.log('LineModel.getPredictionSummary error');
        }
      });
    };

    LineModel.prototype.parse = function(data) {
      var parsed, toRemove,
        _this = this;
      if (!this.gettingPrediction) {
        return data;
      }
      parsed = {};
      parsed.trains = new TrainCollection();
      $(data).children().children().each(function(index, item) {
        var date, sCode, sN, time, timeStamp;
        if (item.nodeName === 'Time') {
          timeStamp = $(item).attr('TimeStamp');
          time = timeStamp.substr(timeStamp.indexOf(' ') + 1);
          date = new Date();
          date.setHours(time.substr(0, 2));
          date.setMinutes(time.substr(3, 2));
          date.setSeconds(time.substr(6, 2));
          parsed.date = date;
        }
        if (item.nodeName === 'S') {
          sCode = $(item).attr('Code');
          sN = $(item).attr('N');
          return $(item).children().each(function(p_index, p) {
            var pN;
            pN = $(p).attr('N');
            return $(p).children().each(function(t_index, t) {
              var $t, schedule, scheduleCollection, station, tC, tD, tDE, tL, tS, tT, train;
              $t = $(t);
              tS = $t.attr('S');
              tT = $t.attr('T');
              tD = $t.attr('D');
              tC = $t.attr('C');
              tL = $t.attr('L');
              tDE = $t.attr('DE');
              if (tT !== '0') {
                train = parsed.trains.get(tS);
                if (!train) {
                  train = new TrainModel();
                  train.set('id', tS);
                  train.set('trip', tT);
                  train.set('location', tL);
                  train.set('destination', tDE);
                  train.set('direction', pN);
                  train.set('schedule', new ScheduleCollection());
                  parsed.trains.push(train);
                }
                scheduleCollection = train.get('schedule');
                station = app.stations.get(sCode);
                if (station) {
                  if (!scheduleCollection.get(sCode)) {
                    schedule = new ScheduleModel();
                    schedule.set('station', sCode);
                    schedule.set('time', AppUtils.getSeconds(tC));
                    return scheduleCollection.push(schedule);
                  }
                }
              }
            });
          });
        }
      });
      toRemove = [];
      parsed.trains.each(function(train) {
        var scheduleCollection;
        scheduleCollection = train.get('schedule');
        if (scheduleCollection.length <= 1) {
          toRemove.push(train);
        }
        return scheduleCollection.sort();
      });
      parsed.trains.remove(toRemove);
      return parsed;
    };

    return LineModel;

  })(Backbone.Model);

  PlatformModel = (function(_super) {

    __extends(PlatformModel, _super);

    function PlatformModel() {
      return PlatformModel.__super__.constructor.apply(this, arguments);
    }

    PlatformModel.prototype.defaults = {
      name: null,
      number: null,
      direction: null,
      lines: null,
      station: null,
      location: null
    };

    return PlatformModel;

  })(Backbone.Model);

  ScheduleModel = (function(_super) {

    __extends(ScheduleModel, _super);

    function ScheduleModel() {
      return ScheduleModel.__super__.constructor.apply(this, arguments);
    }

    ScheduleModel.prototype.defaults = {
      station: null,
      time: null
    };

    ScheduleModel.prototype.idAttribute = 'station';

    return ScheduleModel;

  })(Backbone.Model);

  StationModel = (function(_super) {

    __extends(StationModel, _super);

    function StationModel() {
      return StationModel.__super__.constructor.apply(this, arguments);
    }

    StationModel.prototype.defaults = {
      code: null,
      name: null,
      number: null,
      lines: null,
      platforms: null,
      location: null,
      position: null
    };

    StationModel.prototype.idAttribute = 'code';

    return StationModel;

  })(Backbone.Model);

  TrainModel = (function(_super) {

    __extends(TrainModel, _super);

    function TrainModel() {
      return TrainModel.__super__.constructor.apply(this, arguments);
    }

    TrainModel.prototype.defaults = {
      id: null,
      trip: null,
      destination: null,
      location: null,
      direction: null,
      schedule: null
    };

    return TrainModel;

  })(Backbone.Model);

  LineCollection = (function(_super) {

    __extends(LineCollection, _super);

    function LineCollection() {
      return LineCollection.__super__.constructor.apply(this, arguments);
    }

    LineCollection.prototype.model = LineModel;

    return LineCollection;

  })(Backbone.Collection);

  ScheduleCollection = (function(_super) {

    __extends(ScheduleCollection, _super);

    function ScheduleCollection() {
      return ScheduleCollection.__super__.constructor.apply(this, arguments);
    }

    ScheduleCollection.prototype.model = ScheduleModel;

    ScheduleCollection.prototype.comparator = function(schedule) {
      return schedule.get('time');
    };

    return ScheduleCollection;

  })(Backbone.Collection);

  StationCollection = (function(_super) {

    __extends(StationCollection, _super);

    function StationCollection() {
      return StationCollection.__super__.constructor.apply(this, arguments);
    }

    StationCollection.prototype.model = StationModel;

    return StationCollection;

  })(Backbone.Collection);

  TrainCollection = (function(_super) {

    __extends(TrainCollection, _super);

    function TrainCollection() {
      return TrainCollection.__super__.constructor.apply(this, arguments);
    }

    TrainCollection.prototype.model = TrainModel;

    return TrainCollection;

  })(Backbone.Collection);

  AppThree = (function() {

    AppThree.prototype.view = null;

    AppThree.prototype.camera = null;

    AppThree.prototype.scene = null;

    AppThree.prototype.renderer = null;

    AppThree.prototype.projector = null;

    AppThree.prototype.controls = null;

    AppThree.prototype.container = null;

    AppThree.prototype.mouse = null;

    AppThree.prototype.interactiveObjects = null;

    AppThree.prototype.selectedMatrix = null;

    AppThree.prototype.selectedOffset = null;

    AppThree.prototype.intersected = null;

    AppThree.prototype.lines = null;

    function AppThree() {
      this.view = app.view;
      this.mouse = {
        x: 0,
        y: 0
      };
      this.hw = this.view.sketch.width * .5;
      this.hh = this.view.sketch.height * .5;
      this.initThree();
      this.initLines();
      this.initInteractiveObjects();
    }

    AppThree.prototype.initThree = function() {
      var ambientLight, light;
      this.scene = new THREE.Scene();
      this.scene.fog = new THREE.Fog(0x232323, 1, 2000);
      light = new THREE.DirectionalLight(0x666666);
      light.position.set(0, 2, 1);
      this.scene.add(light);
      ambientLight = new THREE.AmbientLight(0x111111);
      this.scene.add(ambientLight);
      this.renderer = new THREE.WebGLRenderer({
        canvas: this.view.sketch.canvas
      });
      this.renderer.setSize(this.view.sketch.width, this.view.sketch.height);
      this.projector = new THREE.Projector();
      this.camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.01, 2000);
      this.camera.position = new THREE.Vector3(0, 0, 600);
      this.controls = new THREE.TrackballControls(this.camera, this.renderer.domElement);
      this.controls.target.set(0, 0, 0);
      this.controls.rotateSpeed = 1.0;
      this.controls.zoomSpeed = 0.8;
      this.controls.panSpeed = 0.8;
      this.controls.noZoom = false;
      this.controls.noPan = false;
      this.controls.staticMoving = false;
      this.controls.dynamicDampingFactor = 0.15;
      this.controls.maxDistance = 3000;
      this.container = new THREE.Object3D();
      return this.scene.add(this.container);
    };

    AppThree.prototype.initLines = function() {
      var line, lineModel, _i, _len, _ref, _results;
      this.lines = [];
      _ref = app.lines.models;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        lineModel = _ref[_i];
        line = new LineView(new THREE.Object3D(), lineModel, this.lines.length);
        this.container.add(line.container);
        _results.push(this.lines.push(line));
      }
      return _results;
    };

    AppThree.prototype.initInteractiveObjects = function() {
      var line, station, _i, _len, _ref, _results;
      this.interactiveObjects = [];
      _ref = this.lines;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        _results.push((function() {
          var _j, _len1, _ref1, _results1;
          _ref1 = line.stations;
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            station = _ref1[_j];
            _results1.push(this.interactiveObjects.push(station));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    AppThree.prototype.update = function() {
      var matrix, offset, vec;
      if (!this.renderer) {
        return;
      }
      this.controls.update();
      if (this.selectedMatrix) {
        matrix = this.selectedMatrix;
        if (this.selectedOffset) {
          matrix = new THREE.Matrix4().copy(this.selectedMatrix);
          matrix.elements[14] += this.selectedOffset;
        }
        vec = this.projector.projectVector(new THREE.Vector3().getPositionFromMatrix(matrix), this.camera);
        vec.x = (vec.x * this.hw) + this.hw;
        vec.y = -(vec.y * this.hh) + this.hh;
        offset = -5;
        this.view.ui.label.pos.x = floor(vec.x);
        return this.view.ui.label.pos.y = floor(vec.y) + offset;
      }
    };

    AppThree.prototype.draw = function() {
      if (!this.renderer) {
        return;
      }
      return this.renderer.render(this.scene, this.camera);
    };

    AppThree.prototype.resize = function() {
      if (!this.renderer) {
        return;
      }
      this.camera.aspect = this.view.sketch.width / this.view.sketch.height;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(this.view.sketch.width, this.view.sketch.height);
      this.hw = this.view.sketch.width * .5;
      return this.hh = this.view.sketch.height * .5;
    };

    AppThree.prototype.mousedown = function(e) {
      var intersect, intersects, raycaster, selected, vec, _i, _len;
      e.preventDefault();
      this.controls.enabled = true;
      vec = new THREE.Vector3(this.mouse.x, this.mouse.y, 0.5);
      this.projector.unprojectVector(vec, this.camera);
      raycaster = new THREE.Raycaster(this.camera.position, vec.sub(this.camera.position).normalize());
      intersects = raycaster.intersectObjects(this.interactiveObjects);
      if (intersects.length > 0) {
        for (_i = 0, _len = intersects.length; _i < _len; _i++) {
          intersect = intersects[_i];
          selected = intersect.object;
          if (this.lines[selected.lineIndex].enabled) {
            break;
          }
        }
        if (!this.lines[selected.lineIndex].enabled) {
          return;
        }
        this.controls.enabled = false;
        return this.view.ui.toggleLabel(selected);
      }
    };

    AppThree.prototype.mousemove = function(e) {
      this.mouse.x = (e.clientX / window.innerWidth) * 2 - 1;
      return this.mouse.y = -(e.clientY / window.innerHeight) * 2 + 1;
    };

    AppThree.prototype.mouseup = function(e) {
      e.preventDefault();
      return this.controls.enabled = true;
    };

    return AppThree;

  })();

  AppUI = (function() {

    AppUI.prototype.view = null;

    AppUI.prototype.guiData = null;

    AppUI.prototype.labelCanvas = null;

    AppUI.prototype.label = null;

    AppUI.prototype.clock = null;

    AppUI.prototype.clockCount = null;

    AppUI.prototype.clockTimeout = null;

    function AppUI() {
      this.onMuteChange = __bind(this.onMuteChange, this);

      this.onSeparateChange = __bind(this.onSeparateChange, this);

      this.onRestartClick = __bind(this.onRestartClick, this);

      this.updateClock = __bind(this.updateClock, this);
      this.view = app.view;
      this.initGUI();
      this.initLabel();
    }

    AppUI.prototype.initLabel = function() {
      var ctx;
      this.labelCanvas = document.getElementById('canvasLabel');
      this.labelCanvas.width = this.view.sketch.width;
      this.labelCanvas.height = this.view.sketch.height;
      ctx = this.labelCanvas.getContext('2d');
      return this.label = new LabelView(ctx);
    };

    AppUI.prototype.initClock = function() {
      if (this.clock) {
        return;
      }
      this.clock = document.getElementById('clock');
      this.clockCount = 0;
      return this.updateClock();
    };

    AppUI.prototype.initGUI = function() {
      var controller, f1, f2, f4, gui, that, _i, _len, _ref;
      gui = new dat.GUI();
      this.guiData = new GUIData();
      f1 = gui.addFolder('Lines');
      f1.open();
      f1.add(this.guiData, 'Bakerloo');
      f1.add(this.guiData, 'Central');
      f1.add(this.guiData, 'District');
      f1.add(this.guiData, 'Hammersmith');
      f1.add(this.guiData, 'Jubilee');
      f1.add(this.guiData, 'Metropolitan');
      f1.add(this.guiData, 'Northern');
      f1.add(this.guiData, 'Piccadilly');
      f1.add(this.guiData, 'Victoria');
      that = this;
      _ref = f1.__controllers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        controller = _ref[_i];
        controller.onChange(function() {
          return that.onLineChange(this);
        });
        this.onLineChange(controller);
      }
      f2 = gui.addFolder('Trains');
      this.guiData.restart = this.onRestartClick;
      f2.add(this.guiData, 'speed', 1, 50).onFinishChange(function() {
        return that.onSpeedChange();
      });
      f2.add(this.guiData, 'restart');
      /*
      		# controls
      		f3 = gui.addFolder('Controls')
      		f3.open()
      		f3.add(@guiData, 'separate').onFinishChange(-> that.onSeparateChange())
      */

      f4 = gui.addFolder('Sound');
      return f4.add(this.guiData, 'mute').onChange(function() {
        return that.onMuteChange();
      });
    };

    AppUI.prototype.updateClock = function() {
      var date;
      date = new Date(this.view.lines[0].model.get('date').getTime());
      date.setMinutes(date.getMinutes() + this.clockCount);
      this.clock.innerHTML = StringUtils.addLeadingZero(date.getHours()) + ':' + StringUtils.addLeadingZero(date.getMinutes());
      this.clockCount++;
      clearTimeout(this.clockTimeout);
      if (this.clockCount > 30) {
        return;
      }
      return this.clockTimeout = setTimeout(this.updateClock, 60000 / this.guiData.speed);
    };

    AppUI.prototype.toggleLabel = function(selected) {
      this.view.three.selectedMatrix = new THREE.Matrix4().copy(selected.matrixWorld);
      this.view.three.selectedOffset = 0;
      if (this.label.showed && this.label.label === selected.name.toUpperCase() && this.label.lineIndex === selected.lineIndex) {
        return this.label.hide(false);
      } else {
        return this.label.show(selected.code, selected.name, 'rgb(' + selected.color + ')', selected.lineIndex);
      }
    };

    AppUI.prototype.update = function() {};

    AppUI.prototype.draw = function() {
      this.label.ctx.clearRect(0, 0, this.view.sketch.width, this.view.sketch.height);
      return this.label.draw();
    };

    AppUI.prototype.resize = function() {
      this.labelCanvas.width = this.view.sketch.width;
      return this.labelCanvas.height = this.view.sketch.height;
    };

    AppUI.prototype.keyup = function(e) {
      var branch, branchIndex, line, nextCode, nextSprite, stationIndex;
      if (!this.label.showed) {
        return;
      }
      if (e.keyCode !== 39 && e.keyCode !== 37) {
        return;
      }
      line = this.view.lines[this.label.lineIndex];
      branchIndex = line.getFirstBranchIndex(this.label.code);
      stationIndex = line.getStationIndexInBranch(this.label.code, branchIndex);
      branch = line.branches[branchIndex];
      if (e.keyCode === 39) {
        if (stationIndex < branch.length - 1) {
          nextCode = branch[stationIndex + 1];
          nextSprite = line.getSprite(nextCode);
          return this.toggleLabel(nextSprite);
        }
      } else if (e.keyCode === 37) {
        if (stationIndex > 0) {
          nextCode = branch[stationIndex - 1];
          nextSprite = line.getSprite(nextCode);
          return this.toggleLabel(nextSprite);
        }
      }
    };

    AppUI.prototype.onLineChange = function(controller) {
      var enabled, line, _i, _len, _ref;
      _ref = this.view.lines;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (line.model.get('code') === controller.property.substring(0, 1)) {
          break;
        }
      }
      enabled = controller.object[controller.property];
      if (enabled && !line.enabled) {
        line.enable();
      } else if (!enabled && line.enabled) {
        line.disable();
      }
      if (this.label && this.label.lineIndex !== null) {
        if (!this.view.lines[this.label.lineIndex].enabled) {
          return this.label.hide();
        }
      }
    };

    AppUI.prototype.onSpeedChange = function() {
      var line, timeline, _i, _j, _len, _len1, _ref, _ref1;
      _ref = this.view.lines;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (line && line.timelines) {
          _ref1 = line.timelines;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            timeline = _ref1[_j];
            timeline.timeScale(this.guiData.speed);
          }
        }
      }
      this.clockCount--;
      return this.updateClock();
    };

    AppUI.prototype.onRestartClick = function() {
      var line, timeline, _i, _j, _len, _len1, _ref, _ref1;
      _ref = this.view.lines;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (line && line.timelines) {
          _ref1 = line.timelines;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            timeline = _ref1[_j];
            timeline.restart();
          }
        }
      }
      this.clockCount = 0;
      return this.updateClock();
    };

    AppUI.prototype.onSeparateChange = function() {
      var iniOffset, line, _i, _j, _len, _len1, _ref, _ref1, _results, _results1,
        _this = this;
      iniOffset = 0;
      if (this.guiData.separate) {
        _ref = this.view.lines;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          line = _ref[_i];
          if (this.selectedOffset && this.label.showed && this.label.lineIndex === line.index) {
            iniOffset = -this.selectedOffset;
          }
          _results.push(TweenLite.to(line.container.position, 1, {
            z: 200 - 50 * line.index,
            ease: Quart.easeInOut,
            onUpdateParams: [line],
            onUpdate: function(line) {
              if (_this.label.showed && _this.label.lineIndex === line.index) {
                return _this.selectedOffset = line.container.position.z - iniOffset;
              }
            }
          }));
        }
        return _results;
      } else {
        _ref1 = this.view.lines;
        _results1 = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          line = _ref1[_j];
          if (!this.selectedOffset && this.label.showed && this.label.lineIndex === line.index) {
            iniOffset = line.container.position.z;
          }
          _results1.push(TweenLite.to(line.container.position, 1, {
            z: 0,
            ease: Quart.easeInOut,
            onUpdateParams: [line],
            onUpdate: function(line) {
              if (_this.label && _this.label.lineIndex === line.index) {
                return _this.selectedOffset = line.container.position.z - iniOffset;
              }
            }
          }));
        }
        return _results1;
      }
    };

    AppUI.prototype.onMuteChange = function() {
      return this.view.audio.muted = this.guiData.mute;
    };

    return AppUI;

  })();

  AppView = (function(_super) {

    __extends(AppView, _super);

    function AppView() {
      this.show = __bind(this.show, this);

      this.initAudio = __bind(this.initAudio, this);

      this.initUI = __bind(this.initUI, this);

      this.initThree = __bind(this.initThree, this);
      return AppView.__super__.constructor.apply(this, arguments);
    }

    AppView.prototype.sketch = null;

    AppView.prototype.three = null;

    AppView.prototype.ui = null;

    AppView.prototype.showed = null;

    AppView.prototype.lines = null;

    AppView.prototype.audio = null;

    AppView.prototype.el = '#container';

    AppView.prototype.init = function() {
      this.initSketch();
      this.initThree();
      this.initUI();
      return this.initAudio();
    };

    AppView.prototype.initSketch = function() {
      var _this = this;
      return this.sketch = Sketch.create({
        container: document.getElementById('container'),
        type: Sketch.WEB_GL,
        setup: function() {},
        update: function() {
          _this.three.update();
          return _this.ui.update();
        },
        draw: function() {
          _this.three.draw();
          return _this.ui.draw();
        },
        resize: function() {
          if (!_this.three) {
            return;
          }
          _this.three.resize();
          return _this.ui.resize();
        },
        mousedown: function(e) {
          if (!_this.showed) {
            TweenLite.killTweensOf(_this.three.camera.position);
            TweenLite.killTweensOf(_this.three.camera.up);
            _this.showed = true;
          }
          return _this.three.mousedown(e);
        },
        mousemove: function(e) {
          return _this.three.mousemove(e);
        },
        mouseup: function(e) {
          return _this.three.mouseup(e);
        },
        keyup: function(e) {
          return _this.ui.keyup(e);
        }
      });
    };

    AppView.prototype.initThree = function() {
      this.three = new AppThree();
      return this.lines = this.three.lines;
    };

    AppView.prototype.initUI = function() {
      return this.ui = new AppUI();
    };

    AppView.prototype.initAudio = function() {
      return this.audio = document.getElementById('audio');
    };

    AppView.prototype.show = function(delay) {
      var obj,
        _this = this;
      if (delay == null) {
        delay = 0;
      }
      TweenLite.to(this.three.camera.position, 2, {
        x: -57,
        y: -82,
        z: 12,
        delay: delay,
        ease: Expo.easeInOut,
        onComplete: function() {
          return _this.showed = true;
        }
      });
      TweenLite.to(this.three.camera.up, 2, {
        x: 0.18,
        y: 0.00,
        z: 0.98,
        delay: delay,
        ease: Quart.easeInOut
      });
      this.audio.muted = false;
      this.audio.volume = 0;
      obj = {
        volume: 0
      };
      return TweenLite.to(this.audio, 3, {
        volume: 0.4,
        delay: delay + 2,
        ease: Linear.easeNone
      });
    };

    return AppView;

  })(Backbone.View);

  LabelView = (function() {

    LabelView.prototype.ctx = null;

    LabelView.prototype.code = null;

    LabelView.prototype.label = null;

    LabelView.prototype.badge = null;

    LabelView.prototype.lineIndex = null;

    LabelView.prototype.color = null;

    LabelView.prototype.box = null;

    LabelView.prototype.arw = null;

    LabelView.prototype.img = null;

    LabelView.prototype.txt = null;

    LabelView.prototype.pos = null;

    LabelView.prototype.showed = false;

    LabelView.prototype.BOX_HEIGHT = 34;

    LabelView.prototype.ARW_WIDTH = 20;

    LabelView.prototype.ARW_HEIGHT = 10;

    LabelView.prototype.IMG_WIDTH = 20;

    LabelView.prototype.IMG_HEIGHT = 18;

    function LabelView(ctx) {
      var _this = this;
      this.ctx = ctx;
      this.box = {
        x: 0,
        y: 0,
        w: 0,
        h: 0
      };
      this.arw = {
        x: 0,
        y: 0,
        w: 0,
        h: 0
      };
      this.txt = {
        x: 0,
        y: 0,
        w: 0,
        h: 0
      };
      this.img = {
        x: 0,
        y: 0,
        w: 0,
        h: 0
      };
      this.pos = {
        x: 100,
        y: 100
      };
      this.badge = new Image();
      this.badge.onload = function() {
        return _this.img.w = _this.badge.width;
      };
      this.badge.src = 'img/badges.png';
      this.arw.w = this.ARW_WIDTH;
      this.arw.h = this.ARW_HEIGHT;
      this.color = '#666';
    }

    LabelView.prototype.draw = function() {
      var arwX, arwY, boxX, boxY, imgX, imgY, txtX, txtY;
      if (!this.showed) {
        return;
      }
      boxX = this.box.x + this.pos.x;
      boxY = this.box.y + this.pos.y;
      arwX = this.arw.x + this.pos.x;
      arwY = this.arw.y + this.pos.y;
      imgX = this.img.x + this.pos.x;
      imgY = this.img.y + this.pos.y;
      txtX = this.txt.x + this.pos.x;
      txtY = this.txt.y + this.pos.y;
      this.ctx.beginPath();
      this.ctx.moveTo(boxX, boxY);
      this.ctx.lineTo(boxX, boxY + this.box.h);
      this.ctx.lineTo(arwX, boxY + this.box.h);
      this.ctx.lineTo(arwX + this.arw.w * .5, arwY + this.arw.h);
      this.ctx.lineTo(arwX + this.arw.w, boxY + this.box.h);
      this.ctx.lineTo(boxX + this.box.w, boxY + this.box.h);
      this.ctx.lineTo(boxX + this.box.w, boxY);
      this.ctx.lineTo(boxX, boxY);
      this.ctx.strokeStyle = this.color;
      this.ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
      this.ctx.stroke();
      this.ctx.fill();
      this.ctx.closePath();
      this.ctx.globalCompositeOperation = 'source-atop';
      this.ctx.drawImage(this.badge, 0, this.IMG_HEIGHT * this.lineIndex, this.IMG_WIDTH, this.IMG_HEIGHT, imgX, imgY, this.IMG_WIDTH, this.IMG_HEIGHT);
      this.ctx.fillStyle = this.color;
      this.ctx.font = '12px Monda';
      this.ctx.fillText(this.label, txtX, txtY);
      return this.ctx.globalCompositeOperation = 'source-over';
    };

    LabelView.prototype.show = function(code, label, color, lineIndex) {
      var arwH, arwW, boxH, boxW, boxX, boxY,
        _this = this;
      this.code = code;
      this.label = label;
      this.color = color;
      this.lineIndex = lineIndex;
      this.showed = true;
      this.label = this.label.toUpperCase();
      this.ctx.font = '12px Monda';
      this.txt.w = this.ctx.measureText(this.label).width;
      this.box.x = this.box.y = 0;
      this.box.w = this.box.h = 0;
      boxW = this.txt.w + 60;
      boxH = this.BOX_HEIGHT;
      boxX = this.box.x - (boxW * .5);
      boxY = this.box.y - boxH - this.ARW_HEIGHT * 2;
      TweenLite.to(this.box, 0.4, {
        x: boxX,
        w: boxW
      });
      TweenLite.to(this.box, 0.4, {
        y: boxY,
        h: boxH,
        ease: Quart.easeInOut,
        onUpdate: function() {
          return _this.arw.y = _this.box.y + _this.box.h;
        }
      });
      arwW = this.ARW_WIDTH;
      arwH = this.ARW_HEIGHT;
      this.arw.x = this.box.x - (arwW * .5);
      this.arw.y = this.box.y - this.box.h;
      this.arw.h = 0;
      TweenLite.to(this.arw, 0.3, {
        h: arwH,
        ease: Quart.easeOut,
        delay: 0.2
      });
      this.img.x = boxX + 14;
      this.img.y = this.box.y + 50;
      TweenLite.to(this.img, 0.4, {
        y: boxY + 8,
        ease: Expo.easeOut,
        delay: 0.2
      });
      this.txt.x = this.img.x + this.img.w + 9;
      this.txt.y = this.box.y + 100;
      return TweenLite.to(this.txt, 0.4, {
        y: boxY + 21,
        ease: Expo.easeOut,
        delay: 0.1
      });
    };

    LabelView.prototype.hide = function(immediate) {
      var boxH, boxW, boxX, boxY,
        _this = this;
      if (immediate == null) {
        immediate = true;
      }
      if (immediate) {
        this.showed = false;
        return;
      }
      boxW = this.box.w * .9;
      boxH = this.BOX_HEIGHT;
      boxX = this.box.x + ((this.box.w - boxW) * .5);
      boxY = this.box.y + 10;
      return TweenLite.to(this.box, 0.2, {
        x: boxX,
        w: boxW,
        y: boxY,
        h: 2,
        ease: Expo.easeIn,
        onUpdate: function() {
          _this.arw.y = _this.box.y + _this.box.h;
          return _this.arw.h -= 0.5;
        },
        onComplete: function() {
          return _this.showed = false;
        }
      });
    };

    return LabelView;

  })();

  LineView = (function() {

    LineView.prototype.container = null;

    LineView.prototype.branches = null;

    LineView.prototype.splines = null;

    LineView.prototype.splineCurves = null;

    LineView.prototype.splineTs = null;

    LineView.prototype.stations = null;

    LineView.prototype.trains = null;

    LineView.prototype.tubes = null;

    LineView.prototype.timelines = null;

    LineView.prototype.model = null;

    LineView.prototype.color = null;

    LineView.prototype.index = null;

    LineView.prototype.enabled = true;

    function LineView(container, model, index) {
      this.container = container;
      this.model = model;
      this.index = index;
      this.initStations();
      this.initTube();
      this.initSplineTs();
    }

    LineView.prototype.initStations = function() {
      var branch, code, cx, cy, depth, diff, key, offset, position, s, skip, sphereGeometry, sphereMaterial, spline, sprite, spriteMaterial, spriteTexture, st, stationCode, stationCodes, x, xy, y, z, _i, _len, _ref, _results;
      s = app.stations.get('KXX');
      xy = AppUtils.mercatorEncode(s.get('lon'), s.get('lat'));
      cx = xy[0];
      cy = xy[1];
      this.color = parseInt(this.model.get('color')) || 0xffffff;
      this.branches = this.model.get('branches');
      this.stations = [];
      this.splineCurves = [];
      this.splines = [];
      if (!this.branches) {
        return;
      }
      sphereGeometry = new THREE.SphereGeometry(1.5, 5, 5);
      sphereMaterial = new THREE.MeshBasicMaterial({
        color: this.color
      });
      spriteTexture = THREE.ImageUtils.loadTexture('img/flat.png');
      spriteMaterial = new THREE.SpriteMaterial({
        map: spriteTexture,
        useScreenCoordinates: false,
        color: this.color
      });
      stationCodes = [];
      _ref = this.branches;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        branch = _ref[_i];
        spline = [];
        this.splines.push(spline);
        _results.push((function() {
          var _j, _k, _len1, _len2, _results1;
          _results1 = [];
          for (_j = 0, _len1 = branch.length; _j < _len1; _j++) {
            stationCode = branch[_j];
            s = app.stations.get(stationCode);
            if (!s) {
              continue;
            }
            code = this.model.get('code');
            depth = s.get('depth');
            offset = 3;
            xy = AppUtils.mercatorEncode(s.get('lon'), s.get('lat'));
            x = xy[0] - cx;
            y = xy[1] - cy;
            z = depth[code];
            if (code === 'X') {
              if (!z) {
                z = depth['D'];
              }
              if (!z) {
                z = depth['H'];
              }
              if (!z) {
                z = depth['M'];
              }
            }
            for (key in depth) {
              if (key === code) {
                continue;
              }
              diff = z - depth[key];
              if (Math.abs(diff) < offset) {
                if (diff > 0) {
                  z += offset - diff;
                } else {
                  z -= offset + diff;
                }
              }
            }
            depth[code] = z;
            position = new THREE.Vector3(x, -y, z - 100);
            s.set('position', position);
            spline.push(position);
            skip = false;
            for (_k = 0, _len2 = stationCodes.length; _k < _len2; _k++) {
              st = stationCodes[_k];
              if (stationCode === st) {
                skip = true;
                break;
              }
            }
            if (skip) {
              continue;
            }
            stationCodes.push(stationCode);
            sprite = new THREE.Sprite(spriteMaterial);
            sprite.position = position;
            sprite.scale.set(4, 4, 1.0);
            sprite.code = s.get('code');
            sprite.name = s.get('name');
            sprite.color = ((sphereMaterial.color.r * 255) | 0) + ', ' + ((sphereMaterial.color.g * 255) | 0) + ', ' + ((sphereMaterial.color.b * 255) | 0);
            if (this.model.get('code') === 'N') {
              sprite.color = '80, 80, 80';
            }
            sprite.lineIndex = this.index;
            this.stations.push(sprite);
            _results1.push(this.container.add(sprite));
            /*
            				# spheres
            				sphere = new THREE.Mesh(sphereGeometry, sphereMaterial)
            				sphere.position = position
            				sphere.code = s.get('code')
            				sphere.name = s.get('name')
            				# color string eg. '255, 0, 0'
            				sphere.color = ((sphereMaterial.color.r * 255) | 0) + ', ' + ((sphereMaterial.color.g * 255) | 0) + ', ' + ((sphereMaterial.color.b * 255) | 0)
            				if (@model.get('code') == 'N') then sphere.color = '80, 80, 80'
            				sphere.lineIndex = @index
            				@stations.push(sphere)
            				@container.add(sphere)
            */

          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    LineView.prototype.initTube = function() {
      var spline, splineCurve, tube, tubeGeometry, tubeMaterial, _i, _len, _ref, _results;
      this.tubes = [];
      _ref = this.splines;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        spline = _ref[_i];
        splineCurve = new THREE.SplineCurve3(spline);
        this.splineCurves.push(splineCurve);
        tubeGeometry = new THREE.TubeGeometry(splineCurve, spline.length * 8, 1.5, 4);
        tubeMaterial = new THREE.LineBasicMaterial({
          color: this.color,
          opacity: 0.5,
          transparent: true,
          linewidth: 1
        });
        if (this.model.get('code') === 'N') {
          tubeMaterial = new THREE.LineBasicMaterial({
            color: this.color,
            transparent: true,
            linewidth: 1
          });
        }
        this.reorderVertices(tubeGeometry);
        tube = new THREE.Line(tubeGeometry, tubeMaterial, THREE.LineStrip);
        this.container.add(tube);
        _results.push(this.tubes.push(tube));
      }
      return _results;
    };

    LineView.prototype.initSplineTs = function() {
      var branch, i, mapT, spline, station, _i, _ref, _results;
      this.splineTs = [];
      if (!this.branches) {
        return;
      }
      _results = [];
      for (i = _i = 0, _ref = this.branches.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        branch = this.branches[i];
        spline = this.splineCurves[i];
        mapT = {};
        this.splineTs[i] = mapT;
        _results.push((function() {
          var _j, _len, _results1;
          _results1 = [];
          for (_j = 0, _len = branch.length; _j < _len; _j++) {
            station = branch[_j];
            _results1.push(mapT[station] = this.getSplineT(spline, app.stations.get(station).get('position')));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    LineView.prototype.initTrains = function() {
      var train, trainCollection, _i, _len, _ref, _results,
        _this = this;
      this.trains = [];
      this.timelines = [];
      trainCollection = this.model.get('trains');
      trainCollection.each(function(model, index, list) {
        var scheduleCollection, timeline, train;
        train = new TrainView(_this.container, model, _this.color);
        _this.trains.push(train);
        timeline = new TimelineLite();
        timeline.timeScale(AppData.TRAIN_SPEED);
        _this.timelines.push(timeline);
        train.t = -1;
        scheduleCollection = model.get('schedule');
        scheduleCollection.each(function(model, index, list) {
          var branchIndex, curr, currStation, currT, location, next, nextStation, nextT, spline, value;
          curr = model;
          next = index < list.length - 1 ? list[index + 1] : model;
          currStation = curr.get('station');
          nextStation = next.get('station');
          branchIndex = _this.getBranchIndex(currStation, nextStation);
          if (branchIndex !== -1) {
            spline = _this.splineCurves[branchIndex];
            currT = _this.splineTs[branchIndex][currStation];
            nextT = _this.splineTs[branchIndex][nextStation];
            if (index === 0) {
              location = train.model.get('location');
              value = AppUtils.getTrainLocationValue(location);
              if (value) {
                currT += (nextT - currT) * value;
              }
            }
            timeline.to(train, 0.01, {
              t: currT,
              onUpdate: _this.onTrainUpdate,
              onUpdateParams: [train, spline]
            });
            return timeline.to(train, next.get('time') - timeline._totalDuration, {
              t: nextT,
              ease: Linear.easeNone,
              onUpdate: _this.onTrainUpdate,
              onUpdateParams: [train, spline]
            });
          }
        });
        if (!timeline._totalDuration) {
          train.hide();
          return _this.trains.pop();
        }
      });
      _ref = this.trains;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        train = _ref[_i];
        if (!this.enabled) {
          _results.push(train.hide());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    LineView.prototype.onTrainUpdate = function(train, spline) {
      var angle, axis, matrix, tangent, up;
      train.train.position = spline.getPoint(train.t);
      tangent = spline.getTangent(train.t).normalize();
      up = new THREE.Vector3(0, 1, 0);
      axis = new THREE.Vector3().crossVectors(up, tangent).normalize();
      angle = Math.acos(up.dot(tangent));
      matrix = new THREE.Matrix4();
      matrix.makeRotationAxis(axis, angle);
      return train.train.rotation.setEulerFromRotationMatrix(matrix);
    };

    LineView.prototype.getStationIndexInBranch = function(station, branchIndex) {
      var branch, i, s, _i, _ref;
      branch = this.branches[branchIndex];
      for (i = _i = 0, _ref = branch.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        s = branch[i];
        if (station === s) {
          return i;
        }
      }
      return -1;
    };

    LineView.prototype.getSplineT = function(s, p, a, b) {
      var c, da, db, mult, pa, pb;
      if (a == null) {
        a = 0;
      }
      if (b == null) {
        b = 1;
      }
      pa = s.getPoint(a);
      pb = s.getPoint(b);
      da = p.distanceToSquared(pa);
      db = p.distanceToSquared(pb);
      c = 0;
      while (Math.min(da, db) > 1) {
        mult = c > 5 ? .5 : .25;
        if (da > db) {
          a += (b - a) * mult;
        } else {
          b -= (b - a) * mult;
        }
        pa = s.getPoint(a);
        pb = s.getPoint(b);
        da = p.distanceToSquared(pa);
        db = p.distanceToSquared(pb);
        if (c > 15) {
          break;
        }
        c++;
      }
      if (da < db) {
        return a;
      } else {
        return b;
      }
    };

    LineView.prototype.getBranchIndex = function(curr, next) {
      var branch, branchCurr, branchNext, i, station, _i, _j, _len, _ref;
      branchCurr = -1;
      branchNext = -1;
      for (i = _i = 0, _ref = this.branches.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        branch = this.branches[i];
        for (_j = 0, _len = branch.length; _j < _len; _j++) {
          station = branch[_j];
          if (station === curr) {
            branchCurr = i;
          }
          if (station === next) {
            branchNext = i;
          }
          if (branchCurr > -1 && branchCurr === branchNext) {
            return branchCurr;
          }
        }
      }
      return -1;
    };

    LineView.prototype.getFirstBranchIndex = function(station) {
      var branch, i, s, _i, _j, _len, _ref;
      for (i = _i = 0, _ref = this.branches.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        branch = this.branches[i];
        for (_j = 0, _len = branch.length; _j < _len; _j++) {
          s = branch[_j];
          if (s === station) {
            return i;
          }
        }
      }
      return -1;
    };

    LineView.prototype.getSprite = function(station) {
      var sprite, _i, _len, _ref;
      _ref = this.stations;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        sprite = _ref[_i];
        if (sprite.code === station) {
          return sprite;
        }
      }
      return null;
    };

    LineView.prototype.reorderVertices = function(tubeGeometry) {
      var i, length, newVertices, s, segments, temp, vertices, _i, _j, _k, _ref;
      vertices = tubeGeometry.vertices;
      segments = tubeGeometry.radiusSegments;
      length = vertices.length;
      newVertices = [];
      for (s = _i = 0; 0 <= segments ? _i < segments : _i > segments; s = 0 <= segments ? ++_i : --_i) {
        temp = [];
        if (s % 2) {
          for (i = _j = _ref = length + s - segments; _ref <= 0 ? _j < 0 : _j > 0; i = _j += -segments) {
            temp.push(vertices[i]);
          }
        } else {
          for (i = _k = s; s <= length ? _k < length : _k > length; i = _k += segments) {
            temp.push(vertices[i]);
          }
        }
        newVertices = newVertices.concat(temp);
      }
      return tubeGeometry.vertices = newVertices;
    };

    LineView.prototype.enable = function() {
      var color, station, train, tube, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      this.enabled = true;
      color = new THREE.Color(this.color);
      _ref = this.tubes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tube = _ref[_i];
        tube.material.color = color;
        if (this.color === 256) {
          tube.material.opacity = 1;
        }
      }
      _ref1 = this.stations;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        station = _ref1[_j];
        station.material.color = color;
        station.material.opacity = 1;
      }
      if (!this.trains) {
        return null;
      }
      _ref2 = this.trains;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        train = _ref2[_k];
        train.show();
      }
      return null;
    };

    LineView.prototype.disable = function() {
      var color, station, train, tube, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      this.enabled = false;
      color = new THREE.Color(0x444444);
      _ref = this.tubes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tube = _ref[_i];
        tube.material.color = color;
        tube.material.opacity = 0.5;
      }
      _ref1 = this.stations;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        station = _ref1[_j];
        station.material.color = color;
        station.material.opacity = 0.3;
      }
      if (!this.trains) {
        return null;
      }
      _ref2 = this.trains;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        train = _ref2[_k];
        train.hide();
      }
      return null;
    };

    return LineView;

  })();

  TrainView = (function() {

    TrainView.prototype.container = null;

    TrainView.prototype.train = null;

    TrainView.prototype.model = null;

    TrainView.prototype.color = null;

    TrainView.prototype.t = null;

    function TrainView(container, model, color) {
      this.container = container;
      this.model = model;
      this.color = color;
      this.initTrain();
    }

    TrainView.prototype.initTrain = function() {
      var schedule, station, trainGeometry, trainMaterial;
      trainGeometry = new THREE.CubeGeometry(1, 3, 1);
      trainMaterial = new THREE.MeshBasicMaterial({
        color: this.color
      });
      schedule = this.model.get('schedule');
      station = schedule.at(0).get('station');
      this.train = new THREE.Mesh(trainGeometry, trainMaterial);
      return this.container.add(this.train);
    };

    TrainView.prototype.show = function() {
      return this.train.visible = true;
    };

    TrainView.prototype.hide = function() {
      return this.train.visible = false;
    };

    return TrainView;

  })();

  window.app = {
    view: null,
    lines: null,
    stations: null,
    init: function() {
      if (!Detector.webgl) {
        Detector.addGetWebGLMessage();
        return;
      }
      app.initLines();
      return app.initStations();
    },
    initLines: function() {
      var _this = this;
      app.lines = new LineCollection();
      app.lines.url = AppData.GET_LINES;
      return app.lines.fetch({
        success: function(collection, response) {
          console.log('app.lines.fetch success');
          return app.initWithData();
        },
        error: function(collection, response) {
          return console.log('app.lines.fetch error');
        }
      });
    },
    initStations: function() {
      var _this = this;
      app.stations = new StationCollection();
      app.stations.url = AppData.GET_STATIONS;
      return app.stations.fetch({
        success: function(collection, response) {
          console.log('app.stations.fetch success');
          return app.initWithData();
        },
        error: function(collection, response) {
          return console.log('app.stations.fetch error');
        }
      });
    },
    initWithData: function() {
      if (!app.lines.length) {
        return;
      }
      if (!app.stations.length) {
        return;
      }
      app.initPredictionSummary();
      return app.initView();
    },
    initPredictionSummary: function() {
      return app.lines.each(function(model, index, list) {
        if (model.get('code') !== 'X') {
          model.once('loaded', app.onPredictionSummaryLoaded);
          return model.getPredictionSummary();
        }
      });
    },
    initView: function() {
      app.view = new AppView();
      return app.view.init();
    },
    onPredictionSummaryLoaded: function(code) {
      var line, _i, _len, _ref;
      _ref = app.view.lines;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (line.model.get('code') === code) {
          line.initTrains();
        }
      }
      if (code === 'B') {
        app.view.ui.initClock();
      }
      if (code === 'C') {
        return app.view.show(1);
      }
    }
  };

  app.init();

}).call(this);
