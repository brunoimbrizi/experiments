((function(){var a,b,c,d,e,f={}.hasOwnProperty,g=function(a,b){function d(){this.constructor=a}for(var c in b)f.call(b,c)&&(a[c]=b[c]);return d.prototype=b.prototype,a.prototype=new d,a.__super__=b.prototype,a};e=function(){var a;return a=Sketch.create({boids:null,path:null,drags:null,down:!1,drawPath:!0,drawAnchors:!0,brakeOnCurves:!1,takeShortcuts:!1,numBoids:0,clearPath:null,NUM_BOIDS:30,COLOURS:["#6dcff6","#0054a6","#0072bc","#448ccb"],container:document.getElementById("container"),setup:function(){return this.drags=[],this.numBoids=this.NUM_BOIDS,window.sketch=a,this.initBoids(),this.initPath(),this.initGUI()},update:function(){var b,c,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s;if(this.brakeOnCurves!==this.boids[0].pathBrakeOnCurves){p=this.boids;for(h=0,l=p.length;h<l;h++)b=p[h],b.pathBrakeOnCurves=!b.pathBrakeOnCurves}if(this.takeShortcuts!==this.boids[0].pathTakeShortcuts){q=this.boids;for(i=0,m=q.length;i<m;i++)b=q[i],b.pathTakeShortcuts=!b.pathTakeShortcuts}e=this.numBoids-this.boids.length;if(e>0)for(f=j=0;0<=e?j<e:j>e;f=0<=e?++j:--j)g=new Vec3D(a.width*.5+random(50),a.height*.5+random(-50,50),random(-50,50)),c=random(this.COLOURS),this.boids.push(new d(a,g,c));else if(e<0){e*=-1;for(f=k=0;0<=e?k<e:k>e;f=0<=e?++k:--k)this.boids.pop()}f=0,r=this.boids,s=[];for(o=0,n=r.length;o<n;o++)b=r[o],b.acc.addSelf(b.separate(this.boids).scaleSelf(1)),b.acc.addSelf(b.followPath(this.path)),b.update(),b.wrap(),s.push(f++);return s},draw:function(){var b,c,d,e,f,g,h,i,j;a.globalCompositeOperation="lighter",h=this.boids;for(d=0,f=h.length;d<f;d++)b=h[d],b.draw();this.drawPath&&this.path.render();if(!this.drawAnchors)return;i=this.drags,j=[];for(e=0,g=i.length;e<g;e++)c=i[e],j.push(c.render());return j},mousedown:function(){var c,d,e,f,g,h,i,j,k;this.down=!0,g=!1,k=this.drags;for(i=0,j=k.length;i<j;i++){d=k[i],e=a.mouse.x-d.pos.x,f=a.mouse.y-d.pos.y,c=e*e+f*f;if(c>b.HIT_RADIUS_SQ)continue;a.keys.D?(h=this.drags.indexOf(d),this.drags.splice(h,1),this.path.removePoint(h)):d.mousedown(),g=!0;break}if(!g)return d=new b(a,new Vec3D(a.mouse.x,a.mouse.y,0)),this.drags.push(d),this.path.addPoint(d.pos)},mousemove:function(){var c,d,e,f,g,h,i,j;i=this.drags,j=[];for(g=0,h=i.length;g<h;g++)d=i[g],e=a.mouse.x-d.pos.x,f=a.mouse.y-d.pos.y,c=e*e+f*f,c<b.HIT_RADIUS_SQ?d.mouseover():d.over&&d.mouseout(),d.down?j.push(d.mousemove()):j.push(void 0);return j},mouseup:function(){var a,b,c,d,e;this.down=!1,d=this.drags,e=[];for(b=0,c=d.length;b<c;b++)a=d[b],a.down?e.push(a.mouseup()):e.push(void 0);return e},keydown:function(){a.keys.P&&(this.drawPath=!this.drawPath),a.keys.A&&(this.drawAnchors=!this.drawAnchors),a.keys.B&&(this.brakeOnCurves=!this.brakeOnCurves);if(a.keys.S)return this.takeShortcuts=!this.takeShortcuts},initBoids:function(){var b,c,e,f,g,h;this.boids=[],h=[];for(c=f=0,g=this.NUM_BOIDS;0<=g?f<g:f>g;c=0<=g?++f:--f)e=new Vec3D(a.width*.5+random(50),a.height*.5+random(-50,50),random(-50,50)),b="rgb(20,"+floor(random(50,255))+", "+floor(random(10,50))+")",h.push(this.boids[c]=new d(a,e,b));return h},initPath:function(){return this.path=new c(a)},initGUI:function(){var a;return this.clearPath=function(){var a;while(this.drags.length)this.drags.pop();a=[];while(this.path.points.length)a.push(this.path.removePoint(0));return a},a=new dat.GUI,a.add(this,"drawPath").listen(),a.add(this,"drawAnchors").listen(),a.add(this,"brakeOnCurves").listen(),a.add(this,"takeShortcuts").listen(),a.add(this,"numBoids").min(1).max(60).step(1),a.add(this,"clearPath")}})},e(),a=function(){function a(a,b,c){this.ctx=a,this.pos=b,this.color=c,this.vel=new Vec3D(random(-1,1),random(-1,1),0),this.acc=new Vec3D,this.radius=random(4,10),this.maxSpeed=random(2,6),this.maxSteer=.1*this.maxSpeed,this.pathLastSegment=-1,this.wanderTheta=0,this.SEPARATION_RADIUS_SQ=this.SEPARATION_RADIUS*this.SEPARATION_RADIUS,this.ALIGNMENT_RADIUS_SQ=this.ALIGNMENT_RADIUS*this.ALIGNMENT_RADIUS,this.COHESION_RADIUS_SQ=this.COHESION_RADIUS*this.COHESION_RADIUS}return a.prototype.ctx=null,a.prototype.pos=null,a.prototype.vel=null,a.prototype.acc=null,a.prototype.radius=null,a.prototype.color=null,a.prototype.img=null,a.prototype.maxSpeed=null,a.prototype.maxSteer=null,a.prototype.wanderTheta=null,a.prototype.pathBrakeOnCurves=!1,a.prototype.pathTakeShortcuts=!1,a.prototype.pathLastTarget=null,a.prototype.pathLastSegment=null,a.prototype.SEPARATION_RADIUS=30,a.prototype.ALIGNMENT_RADIUS=40,a.prototype.COHESION_RADIUS=60,a.prototype.SEPARATION_RADIUS_SQ=null,a.prototype.ALIGNMENT_RADIUS_SQ=null,a.prototype.COHESION_RADIUS_SQ=null,a.prototype.update=function(){return this.acc.limit(this.maxSteer),this.vel.addSelf(this.acc),this.vel.limit(this.maxSpeed),this.pos.addSelf(this.vel),this.acc.clear()},a.prototype.draw=function(){return this.ctx.translate(this.pos.x,this.pos.y),this.ctx.beginPath(),this.ctx.arc(0,0,this.radius*.8,0,TWO_PI),this.ctx.fillStyle=this.color,this.ctx.fill(),this.ctx.setTransform(1,0,0,1,0,0)},a.prototype.wrap=function(){this.pos.x>this.ctx.width?this.pos.x=0:this.pos.x<0&&(this.pos.x=this.ctx.width);if(this.pos.y>this.ctx.height)return this.pos.y=0;if(this.pos.y<0)return this.pos.y=this.ctx.height},a.prototype.bounce=function(){if(this.pos.x>this.ctx.width||this.pos.x<0)this.vel.x*=-1;if(this.pos.y>this.ctx.height||this.pos.y<0)return this.vel.y*=-1},a.prototype.seek=function(a){var b;return b=new Vec3D,b=a.sub(this.pos),b.limit(this.maxSteer),b},a.prototype.flee=function(a){var b;return Vec3D(b),b=this.pos.sub(a),b.limit(this.maxSteer),b},a.prototype.arrive=function(a){var b,c,d,e,f,g;return d=40,b=a.sub(this.pos),c=b.magnitude(),c>d?f=this.maxSpeed:f=this.maxSpeed*c/d,g=b,g.normalizeTo(f),e=g.sub(this.vel),e.scaleSelf(.5),e.limit(this.maxSteer),e},a.prototype.pursue=function(a){var b,c,d,e,f,g;return b=a.pos.sub(this.pos),c=b.magnitude(),f=this.vel.magnitude(),f<=c?e=1:e=c/f,d=a.vel.scale(e),g=a.pos.add(d),this.arrive(g)},a.prototype.evade=function(a){var b,c,d,e,f,g;return b=a.pos.sub(this.pos),c=b.magnitude(),f=this.vel.magnitude(),f<=c?e=1:e=c/f,d=a.vel.scale(e),g=a.pos.add(d),this.flee(g)},a.prototype.wander=function(){var a,b,c,d;return b=60,c=16,d=.25,this.wanderTheta+=random(-d,d),a=this.vel.copy().normalizeTo(b),a.addSelf(new Vec3D(cos(this.wanderTheta)*c,sin(this.wanderTheta)*c,0)),a.addSelf(this.pos),this.seek(a)},a.prototype.separate=function(a){var b,c,d,e,f,g,h;f=new Vec3D,c=0;for(g=0,h=a.length;g<h;g++){b=a[g];if(this===b)continue;d=this.pos.distanceTo(b.pos),d>0&&d<=this.SEPARATION_RADIUS&&(e=this.pos.sub(b.pos),e.normalizeTo(1/d),f.addSelf(e),c++)}return c>0&&f.scaleSelf(1/c),f},a.prototype.align=function(a){var b,c,d,e,f,g;e=new Vec3D,c=0;for(f=0,g=a.length;f<g;f++){b=a[f];if(this===b)continue;d=this.pos.distanceToSquared(b.pos),d>0&&d<=this.ALIGNMENT_RADIUS_SQ&&(e.addSelf(b.vel),c++)}return c>0&&e.scaleSelf(1/c),e},a.prototype.cohesion=function(a){var b,c,d,e,f,g,h;b=new Vec3D,d=0;for(g=0,h=a.length;g<h;g++){c=a[g];if(this===c)continue;e=this.pos.distanceToSquared(c.pos),e>0&&e<=this.COHESION_RADIUS_SQ&&(b.addSelf(c.pos),d++)}return d>0&&b.scaleSelf(1/d),f=b.sub(this.pos),f},a.prototype.followPath=function(a){var b,c,d,e,f,g,h,i;return e=20,d=this.pos.add(this.vel.scale(e)),f=1,g=a.getNormalPoint(d,this.pathLastTarget,this.pathLastSegment),c=a.direction,g?(c.normalizeTo(max(10,d.distanceTo(g))),g.addSelf(c),this.pathLastTarget=g,this.pathTakeShortcuts?this.pathLastSegment=-1:this.pathLastSegment=a.segment,d.distanceTo(g)<a.radius?new Vec3D:(this.pathBrakeOnCurves&&(h=d.sub(this.pos),i=g.sub(this.pos),b=h.angleBetween(i,!0),f=(PI-b)/PI,f=max(.8,f),this.vel.scaleSelf(f)),this.seek(g))):new Vec3D},a}(),b=function(){function a(a,b){this.ctx=a,this.pos=b,this.radius=this.RADIUS+1,this.alpha=1,this.lineWidth=3}return a.prototype.ctx=null,a.prototype.pos=null,a.prototype.radius=null,a.prototype.lineWidth=null,a.prototype.alpha=null,a.prototype.down=!1,a.prototype.over=!1,a.prototype.RADIUS=5,a.HIT_RADIUS_SQ=81,a.prototype.render=function(){return this.ctx.beginPath(),this.ctx.strokeStyle="rgba(255, 255, 255, "+this.alpha+")",this.ctx.lineWidth=this.lineWidth,this.ctx.arc(this.pos.x,this.pos.y,this.radius,0,TWO_PI),this.ctx.stroke(),this.ctx.closePath()},a.prototype.mousedown=function(){return this.down=!0},a.prototype.mousemove=function(){return this.pos.x=this.ctx.mouse.x,this.pos.y=this.ctx.mouse.y},a.prototype.mouseup=function(){return this.down=!1},a.prototype.mouseover=function(){return this.over=!0,this.radius=this.RADIUS+1,this.alpha=1,this.lineWidth=3},a.prototype.mouseout=function(){return this.over=!1,this.radius=this.RADIUS,this.alpha=.6,this.lineWidth=2},a}(),c=function(){function a(a){this.ctx=a,this.points=[],this.direction=new Vec3D}return a.prototype.ctx=null,a.prototype.points=null,a.prototype.radius=20,a.prototype.direction=null,a.prototype.segment=null,a.prototype.addPoint=function(a){return this.points.push(a)},a.prototype.removePoint=function(a){return this.points.splice(a,1)},a.prototype.getNormalPoint=function(a,b,c){var d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u;b==null&&(b=null),c==null&&(c=-1),i=1e6,h=1e6,r=null;if(!this.points.length)return r;q=0,j=this.points.length-1,c>-1&&c<this.points.length-1&&(q=c,j=min(c+2,this.points.length-1));for(k=u=q;q<=j?u<j:u>j;k=q<=j?++u:--u){n=this.points[k],o=this.points[k+1],s=a.sub(n),t=o.sub(n),t.normalize(),t.scaleSelf(s.dot(t)),p=n.add(t),d=p.distanceTo(n),e=p.distanceTo(o),m=o.sub(n),l=m.magnitude(),d>l?p=o.copy():e>l&&(p=n.copy());if(d>l&&k<j-1)continue;g=a.distanceTo(p),b?f=b.distanceTo(p):f=0,g<i&&f<=h&&(i=g,h=f,r=p,this.direction=m,this.segment=k>=this.points.length-2&&d>l?-1:k)}return r},a.prototype.render=function(){var a,b,c,d,e,f,g,h,i,j,k,l;this.ctx.strokeStyle="rgba(100, 100, 100, 0.3)",this.ctx.lineWidth=1;if(!this.points.length)return;l=[];for(f=j=0,k=this.points.length-1;0<=k?j<k:j>k;f=0<=k?++j:--j)i=this.points[f],e=this.points[f+1],g=e.sub(i),h=new Vec3D(g.y,-g.x,0),h.normalizeTo(this.radius),a=i.add(h),b=e.add(h),c=e.sub(h),d=i.sub(h),this.ctx.beginPath(),this.ctx.moveTo(a.x,a.y),this.ctx.lineTo(b.x,b.y),this.ctx.lineTo(c.x,c.y),this.ctx.lineTo(d.x,d.y),this.ctx.lineTo(a.x,a.y),this.ctx.stroke(),l.push(this.ctx.closePath());return l},a}(),d=function(a){function b(a,c,d){b.__super__.constructor.call(this,a,c,d),this.DISTANCE_SQ=this.DISTANCE*this.DISTANCE,this.particles=[],this.initParticles()}return g(b,a),b.prototype.particles=null,b.prototype.NUM_PARTICLES=10,b.prototype.DISTANCE=20,b.prototype.DISTANCE_SQ=null,b.prototype.DAMP=.9,b.prototype.update=function(){var a,c,d,e,f,g,h,i,j,k,l,m,n,o,p;b.__super__.update.call(this),l=this.particles[0],l.x=this.pos.x,l.y=this.pos.y,n=this.NUM_PARTICLES-1,g=0,p=[];for(h=o=n;n<=g?o<=g:o>=g;h=n<=g?++o:--o)l=this.particles[h],i=this.particles[h+1],m=this.particles[h-1],h===0?m=l:h===this.NUM_PARTICLES-1&&(i=l),l.vx*=this.DAMP,l.vy*=this.DAMP,l.x+=l.vx,l.y+=l.vy,j=l.x,k=l.y,e=l.x-m.x,f=l.y-m.y,d=e*e+f*f,d>this.DISTANCE_SQ?(a=atan2(f,e),l.x=m.x+this.DISTANCE*cos(a),l.y=m.y+this.DISTANCE*sin(a),c=.1,l.vx+=(l.x-j)*c,p.push(l.vy+=(l.y-k)*c)):p.push(void 0);return p},b.prototype.draw=function(){var a,b,c,d,e,f,g,h;this.ctx.beginPath(),this.ctx.arc(this.pos.x,this.pos.y,this.radius*.5,0,TWO_PI),this.ctx.fillStyle=this.color,this.ctx.fill(),this.ctx.beginPath();for(a=g=0,h=this.NUM_PARTICLES;0<=h?g<h:g>h;a=0<=h?++g:--g)e=this.particles[a],d=this.particles[a+1],f=this.particles[a-1],a===0?f=e:a===this.NUM_PARTICLES-1&&(d=e),b=e.x+(d.x-e.x)*.5,c=e.y+(d.y-e.y)*.5,this.ctx.quadraticCurveTo(e.x,e.y,b,c);return this.ctx.strokeStyle=this.color,this.ctx.lineWidth=1,this.ctx.stroke()},b.prototype.initParticles=function(){var a,b,c,d,e;e=[];for(a=c=0,d=this.NUM_PARTICLES;0<=d?c<d:c>d;a=0<=d?++c:--c)b={x:this.pos.x,y:this.pos.y,vx:0,vy:0,angle:0,thickness:0,mx:0,my:0,nx:0,ny:0},e.push(this.particles.push(b));return e},b.prototype.wrap=function(){var a,b,c,d,e,f,g,h,i;b=this.particles[this.particles.length-1],c=0,d=0,a=this.DISTANCE*2,e=!1,this.pos.x>this.ctx.width&&b.x>this.ctx.width?(this.pos.x=0,c=-a,e=!0):this.pos.x<0&&b.x<0&&(this.pos.x=this.ctx.width,c=a,e=!0),this.pos.y>this.ctx.height&&b.y>this.ctx.height?(this.pos.y=0,d=-a,e=!0):this.pos.y<0&&b.y<0&&(this.pos.y=this.ctx.height,d=a,e=!0);if(e){h=this.particles,i=[];for(f=0,g=h.length;f<g;f++)b=h[f],b.x=this.pos.x+c,i.push(b.y=this.pos.y+d);return i}},b}(a)})).call(this)