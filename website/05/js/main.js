((function(){var a,b;requirejs(["toxi/geom/Vec3D","sketch.min","dat.gui.min"],function(a,c){return window.Vec3D=a,b()}),b=function(){var b;return b=Sketch.create({boids:null,img:null,brightness:null,down:null,drawImg:!1,drawLines:!0,cohesion:!1,numBoids:0,NUM_BOIDS:100,container:document.getElementById("container"),setup:function(){this.numBoids=this.NUM_BOIDS,this.initBoids(),this.initImage(),this.initGUI();if(parent.app)return parent.app.updateBodyClass("black")},update:function(){var a,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u;this.img&&(k=(b.width-this.img.width)*.5,l=(b.height-this.img.height)*.5),g=this.numBoids-this.boids.length;if(g>0)for(j=p=0;0<=g?p<g:p>g;j=0<=g?++p:--p)this.addBoid();else if(g<0){g*=-1;for(j=q=0;0<=g?q<g:q>g;j=0<=g?++q:--q)this.boids.pop()}j=0,t=this.boids,u=[];for(r=0,s=t.length;r<s;r++){e=t[r],this.down&&e.acc.addSelf(e.seek(new Vec3D(b.mouse.x,b.mouse.y,0)).scaleSelf(.1)),e.acc.addSelf(e.separate(this.boids)),this.cohesion&&e.acc.addSelf(e.cohesion(this.boids).scaleSelf(.001)),j<this.numBoids*.5?e.acc.addSelf(e.seek(new Vec3D(b.width*.5,b.height*.4,0)).scaleSelf(.002)):e.acc.addSelf(e.seek(new Vec3D(b.width*.5,b.height*.6,0)).scaleSelf(.002)),e.update(),e.bounce(),j++;if(!this.img)continue;if(e.pos.x>k&&e.pos.x<k+this.img.width&&e.pos.y>l&&e.pos.y<l+this.img.height){f=this.getBrightness(e.pos.x-k,e.pos.y-l),e.drawLine=!1;if(f>200){e.drawLine=!0;continue}n=TWO_PI/4,o=atan2(e.vel.y,e.vel.x),m=20,u.push(function(){var b,g;g=[];for(a=b=1;b<4;a=++b){c=cos(o-a*n)*m,d=sin(o-a*n)*m,h=e.pos.x+c-k,i=e.pos.y+d-l;if(h<0||h>this.img.width||i<0||i>this.img.height)continue;f=this.getBrightness(h,i),f>200?g.push(e.acc.addSelf(e.seek(new Vec3D(e.pos.x+c,e.pos.y+d,0)).scaleSelf(.3))):g.push(void 0)}return g}.call(this))}else u.push(void 0)}return u},draw:function(){var a,c,d,e,f,g,h,i,j,k,l,m,n,o;this.img&&this.drawImg&&(e=(b.width-this.img.width)*.5,f=(b.height-this.img.height)*.5,b.drawImage(this.img,e,f)),m=this.boids;for(i=0,l=m.length;i<l;i++)a=m[i],a.draw();if(!this.drawLines)return;for(d=j=0,n=this.numBoids;0<=n?j<n:j>n;d=0<=n?++j:--j){a=this.boids[d];if(a.drawLine)for(g=k=d,o=this.numBoids;d<=o?k<o:k>o;g=d<=o?++k:--k){h=this.boids[g];if(a===h)continue;c=floor(a.pos.distanceTo(h.pos)),c<60&&(b.moveTo(a.pos.x,a.pos.y),b.lineTo(h.pos.x,h.pos.y))}}return b.strokeStyle="rgba(255, 0, 84, 0.3)",b.stroke()},mousedown:function(){return this.down=!0},mouseup:function(){return this.down=!1},keydown:function(a){var b;return b=String.fromCharCode(a.keyCode),this.img.width=this.img.width,this.img.ctx.font="380px Monda",this.img.ctx.fillStyle="#fff",this.img.ctx.fillText(b,(this.img.width-this.img.ctx.measureText(b).width)*.5,320),this.setBrightness()},initBoids:function(){var a,b,c,d;this.boids=[],d=[];for(a=b=0,c=this.NUM_BOIDS;0<=c?b<c:b>c;a=0<=c?++b:--b)d.push(this.addBoid());return d},addBoid:function(){var c,d,e,f,g,h,i,j;e=4,h=0,i=0;for(f=j=0;0<=e?j<e:j>e;f=0<=e?++j:--j)h+=random(b.width),i+=random(b.height);return h/=e,i/=e,g=new Vec3D(h,i,0),d="rgb("+floor(random(255))+", 0, 84)",c=new a(b,g,d),c.radius=random(2,6),this.boids.push(c)},initImage:function(){var a;return a=new Image,this.img=document.createElement("canvas"),this.img.width=380,this.img.height=340,this.img.ctx=this.img.getContext("2d"),this.img.ctx.font="380px Monda",this.img.ctx.fillStyle="#fff",this.img.ctx.fillText("5",(this.img.width-this.img.ctx.measureText("5").width)*.5,320),this.setBrightness()},initGUI:function(){var a;return a=new dat.GUI,a.add(this,"cohesion"),a.add(this,"drawLines").listen(),a.add(this,"numBoids").min(50).max(300).step(1)},setBrightness:function(){var a,b,c,d,e,f;a=this.img.ctx.getImageData(0,0,this.img.width,this.img.height).data,d=this.img.width*this.img.height,b=0,this.brightness=[],f=[];for(b=e=0;0<=d?e<d:e>d;b=0<=d?++e:--e)c=a[4*b],f.push(this.brightness.push(c));return f},getBrightness:function(a,b){return this.brightness[floor(b)*this.img.width+floor(a)]}})},a=function(){function a(a,b,c){this.ctx=a,this.pos=b,this.color=c,this.vel=new Vec3D(random(-1,1),random(-1,1),0),this.acc=new Vec3D,this.radius=random(4,10),this.maxSpeed=random(2,8),this.maxSteer=.1*this.maxSpeed,this.wanderTheta=0,this.pathLastSegment=-1,this.drawLine=!1,this.SEPARATION_RADIUS_SQ=this.SEPARATION_RADIUS*this.SEPARATION_RADIUS,this.ALIGNMENT_RADIUS_SQ=this.ALIGNMENT_RADIUS*this.ALIGNMENT_RADIUS,this.COHESION_RADIUS_SQ=this.COHESION_RADIUS*this.COHESION_RADIUS}return a.prototype.ctx=null,a.prototype.pos=null,a.prototype.vel=null,a.prototype.acc=null,a.prototype.radius=null,a.prototype.color=null,a.prototype.img=null,a.prototype.maxSpeed=null,a.prototype.maxSteer=null,a.prototype.wanderTheta=null,a.prototype.pathBrakeOnCurves=!1,a.prototype.pathTakeShortcuts=!1,a.prototype.pathLastTarget=null,a.prototype.pathLastSegment=null,a.prototype.drawLine=null,a.prototype.SEPARATION_RADIUS=30,a.prototype.ALIGNMENT_RADIUS=40,a.prototype.COHESION_RADIUS=40,a.prototype.SEPARATION_RADIUS_SQ=null,a.prototype.ALIGNMENT_RADIUS_SQ=null,a.prototype.COHESION_RADIUS_SQ=null,a.prototype.update=function(){return this.acc.limit(this.maxSteer),this.vel.addSelf(this.acc),this.vel.limit(this.maxSpeed),this.pos.addSelf(this.vel),this.acc.clear()},a.prototype.draw=function(){return this.ctx.translate(this.pos.x,this.pos.y),this.ctx.beginPath(),this.ctx.arc(0,0,this.radius*.8,0,TWO_PI),this.ctx.fillStyle=this.color,this.ctx.fill(),this.ctx.setTransform(1,0,0,1,0,0)},a.prototype.wrap=function(){this.pos.x>this.ctx.width?this.pos.x=0:this.pos.x<0&&(this.pos.x=this.ctx.width);if(this.pos.y>this.ctx.height)return this.pos.y=0;if(this.pos.y<0)return this.pos.y=this.ctx.height},a.prototype.bounce=function(){if(this.pos.x>this.ctx.width||this.pos.x<0)this.vel.x*=-1;if(this.pos.y>this.ctx.height||this.pos.y<0)return this.vel.y*=-1},a.prototype.seek=function(a){var b;return b=new Vec3D,b=a.sub(this.pos),b.limit(this.maxSteer),b},a.prototype.flee=function(a){var b;return Vec3D(b),b=this.pos.sub(a),b.limit(this.maxSteer),b},a.prototype.arrive=function(a){var b,c,d,e,f,g;return d=40,b=a.sub(this.pos),c=b.magnitude(),c>d?f=this.maxSpeed:f=this.maxSpeed*c/d,g=b,g.normalizeTo(f),e=g.sub(this.vel),e.scaleSelf(.5),e.limit(this.maxSteer),e},a.prototype.pursue=function(a){var b,c,d,e,f,g;return b=a.pos.sub(this.pos),c=b.magnitude(),f=this.vel.magnitude(),f<=c?e=1:e=c/f,d=a.vel.scale(e),g=a.pos.add(d),this.arrive(g)},a.prototype.evade=function(a){var b,c,d,e,f,g;return b=a.pos.sub(this.pos),c=b.magnitude(),f=this.vel.magnitude(),f<=c?e=1:e=c/f,d=a.vel.scale(e),g=a.pos.add(d),this.flee(g)},a.prototype.wander=function(){var a,b,c,d;return b=60,c=16,d=.25,this.wanderTheta+=random(-d,d),a=this.vel.copy().normalizeTo(b),a.addSelf(new Vec3D(cos(this.wanderTheta)*c,sin(this.wanderTheta)*c,0)),a.addSelf(this.pos),this.seek(a)},a.prototype.separate=function(a){var b,c,d,e,f,g,h;f=new Vec3D,c=0;for(g=0,h=a.length;g<h;g++){b=a[g];if(this===b)continue;d=this.pos.distanceTo(b.pos),d>0&&d<=this.SEPARATION_RADIUS&&(e=this.pos.sub(b.pos),e.normalizeTo(1/d),f.addSelf(e),c++)}return c>0&&f.scaleSelf(1/c),f},a.prototype.align=function(a){var b,c,d,e,f,g;e=new Vec3D,c=0;for(f=0,g=a.length;f<g;f++){b=a[f];if(this===b)continue;d=this.pos.distanceToSquared(b.pos),d>0&&d<=this.ALIGNMENT_RADIUS_SQ&&(e.addSelf(b.vel),c++)}return c>0&&e.scaleSelf(1/c),e},a.prototype.cohesion=function(a){var b,c,d,e,f,g;e=new Vec3D,c=0;for(f=0,g=a.length;f<g;f++){b=a[f];if(this===b)continue;d=this.pos.distanceToSquared(b.pos),d>0&&d<=this.COHESION_RADIUS_SQ&&(e.addSelf(b.pos),c++)}return c>0&&(e.scaleSelf(1/c),e.subSelf(this.pos)),e},a.prototype.followPath=function(a){var b,c,d,e,f,g,h,i;return e=20,d=this.pos.add(this.vel.scale(e)),f=1,g=a.getNormalPoint(d,this.pathLastTarget,this.pathLastSegment),c=a.direction,g?(c.normalizeTo(max(10,d.distanceTo(g))),g.addSelf(c),this.pathLastTarget=g,this.pathTakeShortcuts?this.pathLastSegment=-1:this.pathLastSegment=a.segment,d.distanceTo(g)<a.radius?new Vec3D:(this.pathBrakeOnCurves&&(h=d.sub(this.pos),i=g.sub(this.pos),b=h.angleBetween(i,!0),f=(PI-b)/PI,f=max(.8,f),this.vel.scaleSelf(f)),this.seek(g))):new Vec3D},a}()})).call(this)