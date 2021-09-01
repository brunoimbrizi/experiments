
(function() {
  var VerletConstraint, VerletPoint, init;

  requirejs(['sketch.min'], function(sketch) {
    return init();
  });

  init = function() {
    var sketch;
    return sketch = Sketch.create({
      points: [],
      constraints: [],
      fixedPoints: [],
      drag: null,
      ROWS: 15,
      COLS: 24,
      LENGTH: 15,
      setup: function() {
        var i, ix, iy, p, _i, _j, _k, _ref, _ref1, _ref2;
        ix = floor((sketch.width - this.COLS * this.LENGTH) * .5);
        iy = floor((sketch.height - this.ROWS * this.LENGTH) * .5);
        for (i = _i = 0, _ref = this.ROWS * this.COLS; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          p = this.createPoint(ix + (i % this.COLS) * this.LENGTH, iy + floor(i / this.COLS) * this.LENGTH);
          /*
          				if (floor(i / @COLS) == 0)
          					# fix 3 points
          					# if (i % (@COLS * .5) == 0 or i == @COLS - 1)
          					# fix 4 points
          					if (i % floor(@COLS * .34) == 0 or i == @COLS - 1)
          						p.setFixed(true)
          						@fixedPoints.push(p)
          */

        }
        for (i = _j = 0, _ref1 = this.points.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          if (i % this.COLS > 0) {
            this.createConstraint(this.points[i], this.points[i - 1], this.LENGTH);
          }
        }
        for (i = _k = 0, _ref2 = this.points.length; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; i = 0 <= _ref2 ? ++_k : --_k) {
          if (i >= this.COLS) {
            this.createConstraint(this.points[i], this.points[i - this.COLS], this.LENGTH);
          }
        }
        return this.setFixedPoints();
      },
      update: function() {
        var i, p, p0, pN, vx, vy, _i, _j, _len, _ref;
        _ref = this.points;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          vx = (p.x - p.ox) * .9;
          vy = (p.y - p.oy) + .4;
          p.ox = p.x - vx;
          p.oy = p.y - vy;
        }
        if (this.drag) {
          this.drag.x = sketch.mouse.x;
          this.drag.y = sketch.mouse.y;
        }
        this.updatePoints();
        for (i = _j = 0; _j < 3; i = ++_j) {
          this.updateConstraints();
        }
        if (!this.fixedPoints.length) {
          p0 = this.points[0];
          pN = this.points[this.points.length - 1];
          if (p0.y > sketch.height + 400 && pN.y > sketch.height + 400) {
            return this.reset();
          }
        }
      },
      draw: function() {
        sketch.fillStyle = '#ffffff';
        sketch.strokeStyle = '#999999';
        this.drawPoints();
        this.drawConstraints();
        return sketch.fill();
      },
      reset: function() {
        var i, ix, iy, p, _i, _len, _ref;
        ix = floor((sketch.width - this.COLS * this.LENGTH) * .5);
        iy = floor((sketch.height - this.ROWS * this.LENGTH) * .5);
        i = 0;
        _ref = this.points;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          p.x = ix + (i % this.COLS) * this.LENGTH;
          p.y = iy + floor(i / this.COLS) * this.LENGTH;
          p.setVx(0);
          p.setVy(0);
          i++;
        }
        return this.setFixedPoints();
      },
      setFixedPoints: function() {
        var i, p, _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = this.points.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          p = this.points[i];
          if (i === 0) {
            p.setFixed(true);
            _results.push(this.fixedPoints.push(p));
          } else if (i === floor(this.COLS * .5)) {
            p.y -= 30;
            p.setFixed(true);
            _results.push(this.fixedPoints.push(p));
          } else if (i === this.COLS - 1) {
            p.setFixed(true);
            _results.push(this.fixedPoints.push(p));
          } else {
            _results.push(void 0);
          }
          /*
          				else if (floor(i / @COLS) == @ROWS - 1 and i % @COLS == @COLS - 1)
          					p.setFixed(true)
          					p.x += 200
          					@fixedPoints.push(p)
          */

        }
        return _results;
      },
      mousedown: function() {
        var closest, dd, dx, dy, min, p, _i, _len, _ref;
        min = 100000000;
        closest = null;
        _ref = this.points;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          dx = p.x - sketch.mouse.x;
          dy = p.y - sketch.mouse.y;
          dd = sqrt(dx * dx + dy * dy);
          if (dd < min) {
            min = dd;
            closest = p;
          }
        }
        return this.drag = closest;
      },
      mouseup: function() {
        return this.drag = null;
      },
      keydown: function() {
        var i, _i, _ref;
        if (sketch.keys.F && this.drag) {
          this.drag.setFixed(true);
          this.fixedPoints.push(this.drag);
          this.drag = null;
        }
        if (sketch.keys.D && this.drag) {
          this.drag.setFixed(false);
          for (i = _i = 0, _ref = this.fixedPoints.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
            if (this.fixedPoints[i] === this.drag) {
              this.fixedPoints.splice(i, 1);
            }
          }
          return this.drag = null;
        }
      },
      createPoint: function(x, y) {
        var p;
        p = new VerletPoint(x, y);
        this.points.push(p);
        return p;
      },
      createConstraint: function(pA, pB, length) {
        var c;
        if (length == null) {
          length = -1;
        }
        c = new VerletConstraint(pA, pB, length);
        this.constraints.push(c);
        return c;
      },
      updatePoints: function() {
        var p, _i, _len, _ref, _results;
        _ref = this.points;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          _results.push(p.update());
        }
        return _results;
      },
      updateConstraints: function() {
        var c, _i, _len, _ref, _results;
        _ref = this.constraints;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          _results.push(c.update());
        }
        return _results;
      },
      drawPoints: function() {
        var i, p, _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = this.points.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          p = this.points[i];
          _results.push(p.draw(sketch));
        }
        return _results;
      },
      drawConstraints: function() {
        var c, i, _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = this.constraints.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          c = this.constraints[i];
          sketch.beginPath();
          c.draw(sketch);
          _results.push(sketch.stroke());
        }
        return _results;
      }
    });
  };

  VerletConstraint = (function() {

    VerletConstraint.prototype.pointA = null;

    VerletConstraint.prototype.pointB = null;

    VerletConstraint.prototype.length = null;

    function VerletConstraint(pointA, pointB, length) {
      var dx, dy;
      this.pointA = pointA;
      this.pointB = pointB;
      this.length = length != null ? length : -1;
      if (length === -1) {
        dx = pointA.x - pointB.x;
        dy = pointA.y - pointB.y;
        this.length = sqrt(dx * dx + dy * dy);
      }
    }

    VerletConstraint.prototype.update = function() {
      var dd, diff, dx, dy;
      dx = this.pointB.x - this.pointA.x;
      dy = this.pointB.y - this.pointA.y;
      dd = sqrt(dx * dx + dy * dy);
      diff = (this.length - dd) / (dd * (this.pointA.w + this.pointB.w));
      this.pointA.x -= this.pointA.w * dx * diff;
      this.pointA.y -= this.pointA.w * dy * diff;
      this.pointB.x += this.pointB.w * dx * diff;
      return this.pointB.y += this.pointB.w * dy * diff;
    };

    VerletConstraint.prototype.draw = function(ctx, color) {
      if (color == null) {
        color = '#ffffff';
      }
      ctx.moveTo(this.pointA.x, this.pointA.y);
      return ctx.lineTo(this.pointB.x, this.pointB.y);
    };

    return VerletConstraint;

  })();

  VerletPoint = (function() {

    VerletPoint.prototype.x = null;

    VerletPoint.prototype.y = null;

    VerletPoint.prototype.ox = null;

    VerletPoint.prototype.oy = null;

    VerletPoint.prototype.fixed = false;

    VerletPoint.prototype.mass = 1;

    VerletPoint.prototype.w = 1;

    function VerletPoint(x, y) {
      this.setPosition(x, y);
    }

    VerletPoint.prototype.setPosition = function(x, y) {
      this.x = this.ox = x;
      return this.y = this.oy = y;
    };

    VerletPoint.prototype.update = function() {
      var x, y;
      if (this.fixed) {
        return;
      }
      x = this.x;
      y = this.y;
      this.x += this.getVx();
      this.y += this.getVy();
      this.ox = x;
      return this.oy = y;
    };

    VerletPoint.prototype.draw = function(ctx, radius, color) {
      if (radius == null) {
        radius = 1;
      }
      if (color == null) {
        color = '#ffffff';
      }
      return ctx.arc(this.x, this.y, radius, 0, TWO_PI);
    };

    VerletPoint.prototype.getVx = function() {
      return this.x - this.ox;
    };

    VerletPoint.prototype.setVx = function(vx) {
      return this.ox = this.x - vx;
    };

    VerletPoint.prototype.getVy = function() {
      return this.y - this.oy;
    };

    VerletPoint.prototype.setVy = function(vy) {
      return this.oy = this.y - vy;
    };

    VerletPoint.prototype.setFixed = function(value) {
      this.fixed = value;
      if (value) {
        return this.w = 0.0000001;
      } else {
        return this.w = 1 / this.mass;
      }
    };

    return VerletPoint;

  })();

}).call(this);
