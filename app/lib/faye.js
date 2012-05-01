var Faye=(typeof Faye==='object')?Faye:{};if(typeof window!=='undefined')window.Faye=Faye;Faye.extend=function(a,b,c){if(!b)return a;for(var d in b){if(!b.hasOwnProperty(d))continue;if(a.hasOwnProperty(d)&&c===false)continue;if(a[d]!==b[d])a[d]=b[d]}return a};Faye.extend(Faye,{VERSION:'0.8.1',BAYEUX_VERSION:'1.0',ID_LENGTH:128,JSONP_CALLBACK:'jsonpcallback',CONNECTION_TYPES:['long-polling','cross-origin-long-polling','callback-polling','websocket','eventsource','in-process'],MANDATORY_CONNECTION_TYPES:['long-polling','callback-polling','in-process'],ENV:(function(){return this})(),random:function(a){a=a||this.ID_LENGTH;if(a>32){var b=Math.ceil(a/32),c='';while(b--)c+=this.random(32);return c}var d=Math.pow(2,a)-1,f=d.toString(36).length,c=Math.floor(Math.random()*d).toString(36);while(c.length<f)c='0'+c;return c},clientIdFromMessages:function(a){var b=[].concat(a)[0];return b&&b.clientId},copyObject:function(a){var b,c,d;if(a instanceof Array){b=[];c=a.length;while(c--)b[c]=Faye.copyObject(a[c]);return b}else if(typeof a==='object'){b={};for(d in a)b[d]=Faye.copyObject(a[d]);return b}else{return a}},commonElement:function(a,b){for(var c=0,d=a.length;c<d;c++){if(this.indexOf(b,a[c])!==-1)return a[c]}return null},indexOf:function(a,b){if(a.indexOf)return a.indexOf(b);for(var c=0,d=a.length;c<d;c++){if(a[c]===b)return c}return-1},map:function(a,b,c){if(a.map)return a.map(b,c);var d=[];if(a instanceof Array){for(var f=0,g=a.length;f<g;f++){d.push(b.call(c||null,a[f],f))}}else{for(var j in a){if(!a.hasOwnProperty(j))continue;d.push(b.call(c||null,j,a[j]))}}return d},filter:function(a,b,c){var d=[];for(var f=0,g=a.length;f<g;f++){if(b.call(c||null,a[f],f))d.push(a[f])}return d},asyncEach:function(a,b,c,d){var f=a.length,g=-1,j=0,i=false;var h=function(){j-=1;g+=1;if(g===f)return c&&c.call(d);b(a[g],m)};var k=function(){if(i)return;i=true;while(j>0)h();i=false};var m=function(){j+=1;k()};m()},toJSON:function(a){if(this.stringify)return this.stringify(a,function(key,value){return(this[key]instanceof Array)?this[key]:value});return JSON.stringify(a)},timestamp:function(){var b=new Date(),c=b.getFullYear(),d=b.getMonth()+1,f=b.getDate(),g=b.getHours(),j=b.getMinutes(),i=b.getSeconds();var h=function(a){return a<10?'0'+a:String(a)};return h(c)+'-'+h(d)+'-'+h(f)+' '+h(g)+':'+h(j)+':'+h(i)}});Faye.Class=function(a,b){if(typeof a!=='function'){b=a;a=Object}var c=function(){if(!this.initialize)return this;return this.initialize.apply(this,arguments)||this};var d=function(){};d.prototype=a.prototype;c.prototype=new d();Faye.extend(c.prototype,b);return c};Faye.Namespace=Faye.Class({initialize:function(){this._d={}},exists:function(a){return this._d.hasOwnProperty(a)},generate:function(){var a=Faye.random();while(this._d.hasOwnProperty(a))a=Faye.random();return this._d[a]=a},release:function(a){delete this._d[a]}});Faye.Error=Faye.Class({initialize:function(a,b,c){this.code=a;this.params=Array.prototype.slice.call(b);this.message=c},toString:function(){return this.code+':'+this.params.join(',')+':'+this.message}});Faye.Error.parse=function(a){a=a||'';if(!Faye.Grammar.ERROR.test(a))return new this(null,[],a);var b=a.split(':'),c=parseInt(b[0]),d=b[1].split(','),a=b[2];return new this(c,d,a)};Faye.Error.versionMismatch=function(){return new this(300,arguments,"Version mismatch").toString()};Faye.Error.conntypeMismatch=function(){return new this(301,arguments,"Connection types not supported").toString()};Faye.Error.extMismatch=function(){return new this(302,arguments,"Extension mismatch").toString()};Faye.Error.badRequest=function(){return new this(400,arguments,"Bad request").toString()};Faye.Error.clientUnknown=function(){return new this(401,arguments,"Unknown client").toString()};Faye.Error.parameterMissing=function(){return new this(402,arguments,"Missing required parameter").toString()};Faye.Error.channelForbidden=function(){return new this(403,arguments,"Forbidden channel").toString()};Faye.Error.channelUnknown=function(){return new this(404,arguments,"Unknown channel").toString()};Faye.Error.channelInvalid=function(){return new this(405,arguments,"Invalid channel").toString()};Faye.Error.extUnknown=function(){return new this(406,arguments,"Unknown extension").toString()};Faye.Error.publishFailed=function(){return new this(407,arguments,"Failed to publish").toString()};Faye.Error.serverError=function(){return new this(500,arguments,"Internal server error").toString()};Faye.Deferrable={callback:function(a,b){if(!a)return;if(this._v==='succeeded')return a.apply(b,this._j);this._k=this._k||[];this._k.push([a,b])},timeout:function(a,b){var c=this;var d=Faye.ENV.setTimeout(function(){c.setDeferredStatus('failed',b)},a*1000);this._w=d},errback:function(a,b){if(!a)return;if(this._v==='failed')return a.apply(b,this._j);this._l=this._l||[];this._l.push([a,b])},setDeferredStatus:function(){if(this._w)Faye.ENV.clearTimeout(this._w);var a=Array.prototype.slice.call(arguments),b=a.shift(),c;this._v=b;this._j=a;if(b==='succeeded')c=this._k;else if(b==='failed')c=this._l;if(!c)return;var d;while(d=c.shift())d[0].apply(d[1],this._j)}};Faye.Publisher={countListeners:function(a){if(!this._3||!this._3[a])return 0;return this._3[a].length},bind:function(a,b,c){this._3=this._3||{};var d=this._3[a]=this._3[a]||[];d.push([b,c])},unbind:function(a,b,c){if(!this._3||!this._3[a])return;if(!b){delete this._3[a];return}var d=this._3[a],f=d.length;while(f--){if(b!==d[f][0])continue;if(c&&d[f][1]!==c)continue;d.splice(f,1)}},trigger:function(){var a=Array.prototype.slice.call(arguments),b=a.shift();if(!this._3||!this._3[b])return;var c=this._3[b].slice(),d;for(var f=0,g=c.length;f<g;f++){d=c[f];d[0].apply(d[1],a)}}};Faye.Timeouts={addTimeout:function(a,b,c,d){this._5=this._5||{};if(this._5.hasOwnProperty(a))return;var f=this;this._5[a]=Faye.ENV.setTimeout(function(){delete f._5[a];c.call(d)},1000*b)},removeTimeout:function(a){this._5=this._5||{};var b=this._5[a];if(!b)return;clearTimeout(b);delete this._5[a]}};Faye.Logging={LOG_LEVELS:{error:3,warn:2,info:1,debug:0},logLevel:'error',log:function(a,b){if(!Faye.logger)return;var c=Faye.Logging.LOG_LEVELS;if(c[Faye.Logging.logLevel]>c[b])return;var a=Array.prototype.slice.apply(a),d=' ['+b.toUpperCase()+'] [Faye',f=this.className,g=a.shift().replace(/\?/g,function(){try{return Faye.toJSON(a.shift())}catch(e){return'[Object]'}});for(var j in Faye){if(f)continue;if(typeof Faye[j]!=='function')continue;if(this instanceof Faye[j])f=j}if(f)d+='.'+f;d+='] ';Faye.logger(Faye.timestamp()+d+g)}};(function(){for(var c in Faye.Logging.LOG_LEVELS)(function(a,b){Faye.Logging[a]=function(){this.log(arguments,a)}})(c,Faye.Logging.LOG_LEVELS[c])})();Faye.Grammar={LOWALPHA:/^[a-z]$/,UPALPHA:/^[A-Z]$/,ALPHA:/^([a-z]|[A-Z])$/,DIGIT:/^[0-9]$/,ALPHANUM:/^(([a-z]|[A-Z])|[0-9])$/,MARK:/^(\-|\_|\!|\~|\(|\)|\$|\@)$/,STRING:/^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*$/,TOKEN:/^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+$/,INTEGER:/^([0-9])+$/,CHANNEL_SEGMENT:/^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+$/,CHANNEL_SEGMENTS:/^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+(\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+)*$/,CHANNEL_NAME:/^\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+(\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+)*$/,WILD_CARD:/^\*{1,2}$/,CHANNEL_PATTERN:/^(\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+)*\/\*{1,2}$/,VERSION_ELEMENT:/^(([a-z]|[A-Z])|[0-9])(((([a-z]|[A-Z])|[0-9])|\-|\_))*$/,VERSION:/^([0-9])+(\.(([a-z]|[A-Z])|[0-9])(((([a-z]|[A-Z])|[0-9])|\-|\_))*)*$/,CLIENT_ID:/^((([a-z]|[A-Z])|[0-9]))+$/,ID:/^((([a-z]|[A-Z])|[0-9]))+$/,ERROR_MESSAGE:/^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*$/,ERROR_ARGS:/^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*(,(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*)*$/,ERROR_CODE:/^[0-9][0-9][0-9]$/,ERROR:/^([0-9][0-9][0-9]:(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*(,(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*)*:(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*|[0-9][0-9][0-9]::(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*)$/};Faye.Extensible={addExtension:function(a){this._6=this._6||[];this._6.push(a);if(a.added)a.added(this)},removeExtension:function(a){if(!this._6)return;var b=this._6.length;while(b--){if(this._6[b]!==a)continue;this._6.splice(b,1);if(a.removed)a.removed(this)}},pipeThroughExtensions:function(c,d,f,g){this.debug('Passing through ? extensions: ?',c,d);if(!this._6)return f.call(g,d);var j=this._6.slice();var i=function(a){if(!a)return f.call(g,a);var b=j.shift();if(!b)return f.call(g,a);if(b[c])b[c](a,i);else i(a)};i(d)}};Faye.extend(Faye.Extensible,Faye.Logging);Faye.Channel=Faye.Class({initialize:function(a){this.id=this.name=a},push:function(a){this.trigger('message',a)},isUnused:function(){return this.countListeners('message')===0}});Faye.extend(Faye.Channel.prototype,Faye.Publisher);Faye.extend(Faye.Channel,{HANDSHAKE:'/meta/handshake',CONNECT:'/meta/connect',SUBSCRIBE:'/meta/subscribe',UNSUBSCRIBE:'/meta/unsubscribe',DISCONNECT:'/meta/disconnect',META:'meta',SERVICE:'service',expand:function(a){var b=this.parse(a),c=['/**',a];var d=b.slice();d[d.length-1]='*';c.push(this.unparse(d));for(var f=1,g=b.length;f<g;f++){d=b.slice(0,f);d.push('**');c.push(this.unparse(d))}return c},isValid:function(a){return Faye.Grammar.CHANNEL_NAME.test(a)||Faye.Grammar.CHANNEL_PATTERN.test(a)},parse:function(a){if(!this.isValid(a))return null;return a.split('/').slice(1)},unparse:function(a){return'/'+a.join('/')},isMeta:function(a){var b=this.parse(a);return b?(b[0]===this.META):null},isService:function(a){var b=this.parse(a);return b?(b[0]===this.SERVICE):null},isSubscribable:function(a){if(!this.isValid(a))return null;return!this.isMeta(a)&&!this.isService(a)},Set:Faye.Class({initialize:function(){this._2={}},getKeys:function(){var a=[];for(var b in this._2)a.push(b);return a},remove:function(a){delete this._2[a]},hasSubscription:function(a){return this._2.hasOwnProperty(a)},subscribe:function(a,b,c){if(!b)return;var d;for(var f=0,g=a.length;f<g;f++){d=a[f];var j=this._2[d]=this._2[d]||new Faye.Channel(d);j.bind('message',b,c)}},unsubscribe:function(a,b,c){var d=this._2[a];if(!d)return false;d.unbind('message',b,c);if(d.isUnused()){this.remove(a);return true}else{return false}},distributeMessage:function(a){var b=Faye.Channel.expand(a.channel);for(var c=0,d=b.length;c<d;c++){var f=this._2[b[c]];if(f)f.trigger('message',a.data)}}})});Faye.Publication=Faye.Class(Faye.Deferrable);Faye.Subscription=Faye.Class({initialize:function(a,b,c,d){this._7=a;this._2=b;this._m=c;this._n=d;this._x=false},cancel:function(){if(this._x)return;this._7.unsubscribe(this._2,this._m,this._n);this._x=true},unsubscribe:function(){this.cancel()}});Faye.extend(Faye.Subscription.prototype,Faye.Deferrable);Faye.Client=Faye.Class({UNCONNECTED:1,CONNECTING:2,CONNECTED:3,DISCONNECTED:4,HANDSHAKE:'handshake',RETRY:'retry',NONE:'none',CONNECTION_TIMEOUT:60.0,DEFAULT_RETRY:5.0,DEFAULT_ENDPOINT:'/bayeux',INTERVAL:0.0,initialize:function(a,b){this.info('New client created for ?',a);this.endpoint=a||this.DEFAULT_ENDPOINT;this._E=Faye.CookieJar&&new Faye.CookieJar();this._y={};this._o=b||{};this._p=[];this.retry=this._o.retry||this.DEFAULT_RETRY;this._z(Faye.MANDATORY_CONNECTION_TYPES);this._1=this.UNCONNECTED;this._2=new Faye.Channel.Set();this._e=0;this._q={};this._8={reconnect:this.RETRY,interval:1000*(this._o.interval||this.INTERVAL),timeout:1000*(this._o.timeout||this.CONNECTION_TIMEOUT)};if(Faye.Event)Faye.Event.on(Faye.ENV,'beforeunload',function(){if(Faye.indexOf(this._p,'autodisconnect')<0)this.disconnect()},this)},disable:function(a){this._p.push(a)},setHeader:function(a,b){this._y[a]=b},getClientId:function(){return this._0},getState:function(){switch(this._1){case this.UNCONNECTED:return'UNCONNECTED';case this.CONNECTING:return'CONNECTING';case this.CONNECTED:return'CONNECTED';case this.DISCONNECTED:return'DISCONNECTED'}},handshake:function(d,f){if(this._8.reconnect===this.NONE)return;if(this._1!==this.UNCONNECTED)return;this._1=this.CONNECTING;var g=this;this.info('Initiating handshake with ?',this.endpoint);this._9({channel:Faye.Channel.HANDSHAKE,version:Faye.BAYEUX_VERSION,supportedConnectionTypes:[this._a.connectionType]},function(b){if(b.successful){this._1=this.CONNECTED;this._0=b.clientId;var c=Faye.filter(b.supportedConnectionTypes,function(a){return Faye.indexOf(this._p,a)<0},this);this._z(c);this.info('Handshake successful: ?',this._0);this.subscribe(this._2.getKeys(),true);if(d)d.call(f)}else{this.info('Handshake unsuccessful');Faye.ENV.setTimeout(function(){g.handshake(d,f)},this._8.interval);this._1=this.UNCONNECTED}},this)},connect:function(a,b){if(this._8.reconnect===this.NONE)return;if(this._1===this.DISCONNECTED)return;if(this._1===this.UNCONNECTED)return this.handshake(function(){this.connect(a,b)},this);this.callback(a,b);if(this._1!==this.CONNECTED)return;this.info('Calling deferred actions for ?',this._0);this.setDeferredStatus('succeeded');this.setDeferredStatus('deferred');if(this._r)return;this._r=true;this.info('Initiating connection for ?',this._0);this._9({channel:Faye.Channel.CONNECT,clientId:this._0,connectionType:this._a.connectionType},this._A,this)},disconnect:function(){if(this._1!==this.CONNECTED)return;this._1=this.DISCONNECTED;this.info('Disconnecting ?',this._0);this._9({channel:Faye.Channel.DISCONNECT,clientId:this._0},function(a){if(a.successful)this._a.close()},this);this.info('Clearing channel listeners for ?',this._0);this._2=new Faye.Channel.Set()},subscribe:function(c,d,f){if(c instanceof Array){for(var g=0,j=c.length;g<j;g++){this.subscribe(c[g],d,f)}return}var i=new Faye.Subscription(this,c,d,f),h=(d===true),k=this._2.hasSubscription(c);if(k&&!h){this._2.subscribe([c],d,f);i.setDeferredStatus('succeeded');return i}this.connect(function(){this.info('Client ? attempting to subscribe to ?',this._0,c);if(!h)this._2.subscribe([c],d,f);this._9({channel:Faye.Channel.SUBSCRIBE,clientId:this._0,subscription:c},function(a){if(!a.successful){i.setDeferredStatus('failed',Faye.Error.parse(a.error));return this._2.unsubscribe(c,d,f)}var b=[].concat(a.subscription);this.info('Subscription acknowledged for ? to ?',this._0,b);i.setDeferredStatus('succeeded')},this)},this);return i},unsubscribe:function(c,d,f){if(c instanceof Array){for(var g=0,j=c.length;g<j;g++){this.unsubscribe(c[g],d,f)}return}var i=this._2.unsubscribe(c,d,f);if(!i)return;this.connect(function(){this.info('Client ? attempting to unsubscribe from ?',this._0,c);this._9({channel:Faye.Channel.UNSUBSCRIBE,clientId:this._0,subscription:c},function(a){if(!a.successful)return;var b=[].concat(a.subscription);this.info('Unsubscription acknowledged for ? from ?',this._0,b)},this)},this)},publish:function(b,c){var d=new Faye.Publication();this.connect(function(){this.info('Client ? queueing published message to ?: ?',this._0,b,c);this._9({channel:b,data:c,clientId:this._0},function(a){if(a.successful)d.setDeferredStatus('succeeded');else d.setDeferredStatus('failed',Faye.Error.parse(a.error))},this)},this);return d},receiveMessage:function(c){this.pipeThroughExtensions('incoming',c,function(a){if(!a)return;if(a.advice)this._F(a.advice);this._G(a);if(a.successful===undefined)return;var b=this._q[a.id];if(!b)return;delete this._q[a.id];b[0].call(b[1],a)},this)},_z:function(b){Faye.Transport.get(this,b,function(a){this._a=a;this._a.cookies=this._E;this._a.headers=this._y;a.bind('down',function(){if(this._c!==undefined&&!this._c)return;this._c=false;this.trigger('transport:down')},this);a.bind('up',function(){if(this._c!==undefined&&this._c)return;this._c=true;this.trigger('transport:up')},this)},this)},_9:function(b,c,d){b.id=this._H();if(c)this._q[b.id]=[c,d];this.pipeThroughExtensions('outgoing',b,function(a){if(!a)return;this._a.send(a,this._8.timeout/1000)},this)},_H:function(){this._e+=1;if(this._e>=Math.pow(2,32))this._e=0;return this._e.toString(36)},_F:function(a){Faye.extend(this._8,a);if(this._8.reconnect===this.HANDSHAKE&&this._1!==this.DISCONNECTED){this._1=this.UNCONNECTED;this._0=null;this._A()}},_G:function(a){if(!a.channel||a.data===undefined)return;this.info('Client ? calling listeners for ? with ?',this._0,a.channel,a.data);this._2.distributeMessage(a)},_I:function(){if(!this._r)return;this._r=null;this.info('Closed connection for ?',this._0)},_A:function(){this._I();var a=this;Faye.ENV.setTimeout(function(){a.connect()},this._8.interval)}});Faye.extend(Faye.Client.prototype,Faye.Deferrable);Faye.extend(Faye.Client.prototype,Faye.Publisher);Faye.extend(Faye.Client.prototype,Faye.Logging);Faye.extend(Faye.Client.prototype,Faye.Extensible);Faye.Transport=Faye.extend(Faye.Class({MAX_DELAY:0.0,batching:true,initialize:function(a,b){this.debug('Created new ? transport for ?',this.connectionType,b);this._7=a;this._b=b;this._f=[]},close:function(){},send:function(a,b){this.debug('Client ? sending message to ?: ?',this._7._0,this._b,a);if(!this.batching)return this.request([a],b);this._f.push(a);this._J=b;if(a.channel===Faye.Channel.HANDSHAKE)return this.flush();if(a.channel===Faye.Channel.CONNECT)this._s=a;this.addTimeout('publish',this.MAX_DELAY,this.flush,this)},flush:function(){this.removeTimeout('publish');if(this._f.length>1&&this._s)this._s.advice={timeout:0};this.request(this._f,this._J);this._s=null;this._f=[]},receive:function(a){this.debug('Client ? received from ?: ?',this._7._0,this._b,a);for(var b=0,c=a.length;b<c;b++){this._7.receiveMessage(a[b])}},retry:function(a,b){var c=false,d=this._7.retry*1000,f=this;return function(){if(c)return;c=true;Faye.ENV.setTimeout(function(){f.request(a,b)},d)}}}),{get:function(g,j,i,h){var k=g.endpoint;if(j===undefined)j=this.supportedConnectionTypes();Faye.asyncEach(this._t,function(b,c){var d=b[0],f=b[1];if(Faye.indexOf(j,d)<0)return c();f.isUsable(k,function(a){if(a)i.call(h,new f(g,k));else c()})},function(){throw new Error('Could not find a usable connection type for '+k);})},register:function(a,b){this._t.push([a,b]);b.prototype.connectionType=a},_t:[],supportedConnectionTypes:function(){return Faye.map(this._t,function(a){return a[0]})}});Faye.extend(Faye.Transport.prototype,Faye.Logging);Faye.extend(Faye.Transport.prototype,Faye.Publisher);Faye.extend(Faye.Transport.prototype,Faye.Timeouts);Faye.Event={_g:[],on:function(a,b,c,d){var f=function(){c.call(d)};if(a.addEventListener)a.addEventListener(b,f,false);else a.attachEvent('on'+b,f);this._g.push({_h:a,_u:b,_m:c,_n:d,_B:f})},detach:function(a,b,c,d){var f=this._g.length,g;while(f--){g=this._g[f];if((a&&a!==g._h)||(b&&b!==g._u)||(c&&c!==g._m)||(d&&d!==g._n))continue;if(g._h.removeEventListener)g._h.removeEventListener(g._u,g._B,false);else g._h.detachEvent('on'+g._u,g._B);this._g.splice(f,1);g=null}}};Faye.Event.on(Faye.ENV,'unload',Faye.Event.detach,Faye.Event);Faye.URI=Faye.extend(Faye.Class({queryString:function(){var a=[];for(var b in this.params){if(!this.params.hasOwnProperty(b))continue;a.push(encodeURIComponent(b)+'='+encodeURIComponent(this.params[b]))}return a.join('&')},isLocal:function(){var a=Faye.URI.parse(Faye.ENV.location.href);var b=(a.hostname!==this.hostname)||(a.port!==this.port)||(a.protocol!==this.protocol);return!b},toURL:function(){var a=this.queryString();return this.protocol+this.hostname+':'+this.port+this.pathname+(a?'?'+a:'')}}),{parse:function(d,f){if(typeof d!=='string')return d;var g=new this();var j=function(b,c){d=d.replace(c,function(a){if(a)g[b]=a;return''})};j('protocol',/^https?\:\/+/);j('hostname',/^[^\/\:]+/);j('port',/^:[0-9]+/);Faye.extend(g,{protocol:Faye.ENV.location.protocol+'//',hostname:Faye.ENV.location.hostname,port:Faye.ENV.location.port},false);if(!g.port)g.port=(g.protocol==='https://')?'443':'80';g.port=g.port.replace(/\D/g,'');var i=d.split('?'),h=i.shift(),k=i.join('?'),m=k?k.split('&'):[],n=m.length,l={};while(n--){i=m[n].split('=');l[decodeURIComponent(i[0]||'')]=decodeURIComponent(i[1]||'')}if(typeof f==='object')Faye.extend(l,f);g.pathname=h;g.params=l;return g}});if(!this.JSON){JSON={}}(function(){function k(a){return a<10?'0'+a:a}if(typeof Date.prototype.toJSON!=='function'){Date.prototype.toJSON=function(a){return this.getUTCFullYear()+'-'+k(this.getUTCMonth()+1)+'-'+k(this.getUTCDate())+'T'+k(this.getUTCHours())+':'+k(this.getUTCMinutes())+':'+k(this.getUTCSeconds())+'Z'};String.prototype.toJSON=Number.prototype.toJSON=Boolean.prototype.toJSON=function(a){return this.valueOf()}}var m=/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,n=/[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,l,p,s={'\b':'\\b','\t':'\\t','\n':'\\n','\f':'\\f','\r':'\\r','"':'\\"','\\':'\\\\'},o;function r(c){n.lastIndex=0;return n.test(c)?'"'+c.replace(n,function(a){var b=s[a];return typeof b==='string'?b:'\\u'+('0000'+a.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+c+'"'}function q(a,b){var c,d,f,g,j=l,i,h=b[a];if(h&&typeof h==='object'&&typeof h.toJSON==='function'){h=h.toJSON(a)}if(typeof o==='function'){h=o.call(b,a,h)}switch(typeof h){case'string':return r(h);case'number':return isFinite(h)?String(h):'null';case'boolean':case'null':return String(h);case'object':if(!h){return'null'}l+=p;i=[];if(Object.prototype.toString.apply(h)==='[object Array]'){g=h.length;for(c=0;c<g;c+=1){i[c]=q(c,h)||'null'}f=i.length===0?'[]':l?'[\n'+l+i.join(',\n'+l)+'\n'+j+']':'['+i.join(',')+']';l=j;return f}if(o&&typeof o==='object'){g=o.length;for(c=0;c<g;c+=1){d=o[c];if(typeof d==='string'){f=q(d,h);if(f){i.push(r(d)+(l?': ':':')+f)}}}}else{for(d in h){if(Object.hasOwnProperty.call(h,d)){f=q(d,h);if(f){i.push(r(d)+(l?': ':':')+f)}}}}f=i.length===0?'{}':l?'{\n'+l+i.join(',\n'+l)+'\n'+j+'}':'{'+i.join(',')+'}';l=j;return f}}Faye.stringify=function(a,b,c){var d;l='';p='';if(typeof c==='number'){for(d=0;d<c;d+=1){p+=' '}}else if(typeof c==='string'){p=c}o=b;if(b&&typeof b!=='function'&&(typeof b!=='object'||typeof b.length!=='number')){throw new Error('JSON.stringify');}return q('',{'':a})};if(typeof JSON.stringify!=='function'){JSON.stringify=Faye.stringify}if(typeof JSON.parse!=='function'){JSON.parse=function(g,j){var i;function h(a,b){var c,d,f=a[b];if(f&&typeof f==='object'){for(c in f){if(Object.hasOwnProperty.call(f,c)){d=h(f,c);if(d!==undefined){f[c]=d}else{delete f[c]}}}}return j.call(a,b,f)}m.lastIndex=0;if(m.test(g)){g=g.replace(m,function(a){return'\\u'+('0000'+a.charCodeAt(0).toString(16)).slice(-4)})}if(/^[\],:{}\s]*$/.test(g.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,'@').replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,']').replace(/(?:^|:|,)(?:\s*\[)+/g,''))){i=eval('('+g+')');return typeof j==='function'?h({'':i},''):i}throw new SyntaxError('JSON.parse');}}}());Faye.Transport.WebSocket=Faye.extend(Faye.Class(Faye.Transport,{UNCONNECTED:1,CONNECTING:2,CONNECTED:3,batching:false,request:function(b,c){if(b.length===0)return;this._i=this._i||{};for(var d=0,f=b.length;d<f;d++){this._i[b[d].id]=b[d]}this.withSocket(function(a){a.send(Faye.toJSON(b))})},withSocket:function(a,b){this.callback(a,b);this.connect()},close:function(){if(this._C)return;this._C=true;if(this._4)this._4.close()},connect:function(){if(this._C)return;this._1=this._1||this.UNCONNECTED;if(this._1!==this.UNCONNECTED)return;this._1=this.CONNECTING;var f=Faye.Transport.WebSocket.getClass();this._4=new f(Faye.Transport.WebSocket.getSocketUrl(this._b));var g=this;this._4.onopen=function(){g._1=g.CONNECTED;g.setDeferredStatus('succeeded',g._4);g.trigger('up')};this._4.onmessage=function(a){var b=[].concat(JSON.parse(a.data));for(var c=0,d=b.length;c<d;c++){delete g._i[b[c].id]}g.receive(b)};this._4.onclose=function(){var a=(g._1===g.CONNECTED);g.setDeferredStatus('deferred');g._1=g.UNCONNECTED;delete g._4;if(a)return g.resend();var b=g._7.retry*1000;Faye.ENV.setTimeout(function(){g.connect()},b);g.trigger('down')}},resend:function(){var c=Faye.map(this._i,function(a,b){return b});this.request(c)}}),{WEBSOCKET_TIMEOUT:1000,getSocketUrl:function(a){if(Faye.URI)a=Faye.URI.parse(a).toURL();return a.replace(/^http(s?):/ig,'ws$1:')},getClass:function(){return(Faye.WebSocket&&Faye.WebSocket.Client)||Faye.ENV.WebSocket||Faye.ENV.MozWebSocket},isUsable:function(a,b,c){var d=this.getClass();if(!d)return b.call(c,false);var f=false,g=false,j=this.getSocketUrl(a),i=new d(j);i.onopen=function(){f=true;i.close();b.call(c,true);g=true;i=null};var h=function(){if(!g&&!f)b.call(c,false);g=true};i.onclose=i.onerror=h;Faye.ENV.setTimeout(h,this.WEBSOCKET_TIMEOUT)}});Faye.extend(Faye.Transport.WebSocket.prototype,Faye.Deferrable);Faye.Transport.register('websocket',Faye.Transport.WebSocket);Faye.Transport.EventSource=Faye.extend(Faye.Class(Faye.Transport,{initialize:function(b,c){Faye.Transport.prototype.initialize.call(this,b,c);this._K=new Faye.Transport.XHR(b,c);var d=new EventSource(c+'/'+b.getClientId()),f=this;d.onmessage=function(a){f.receive(JSON.parse(a.data))};this._4=d},request:function(a,b){this._K.request(a,b)},close:function(){this._4.close()}}),{isUsable:function(b,c,d){Faye.Transport.XHR.isUsable(b,function(a){c.call(d,a&&Faye.ENV.EventSource)})}});Faye.Transport.register('eventsource',Faye.Transport.EventSource);Faye.Transport.XHR=Faye.extend(Faye.Class(Faye.Transport,{request:function(d,f){var g=this.retry(d,f),j=Faye.URI.parse(this._b).pathname,i=this,h=Faye.ENV.ActiveXObject?new ActiveXObject("Microsoft.XMLHTTP"):new XMLHttpRequest();h.open('POST',j,true);h.setRequestHeader('Content-Type','application/json');h.setRequestHeader('X-Requested-With','XMLHttpRequest');var k=this.headers;for(var m in k){if(!k.hasOwnProperty(m))continue;h.setRequestHeader(m,k[m])}var n=function(){h.abort()};Faye.Event.on(Faye.ENV,'beforeunload',n);var l=function(){Faye.Event.detach(Faye.ENV,'beforeunload',n);h.onreadystatechange=function(){};h=null};h.onreadystatechange=function(){if(h.readyState!==4)return;var a=null,b=h.status,c=((b>=200&&b<300)||b===304||b===1223);if(!c){l();g();return i.trigger('down')}try{a=JSON.parse(h.responseText)}catch(e){}l();if(a){i.receive(a);i.trigger('up')}else{g();i.trigger('down')}};h.send(Faye.toJSON(d))}}),{isUsable:function(a,b,c){b.call(c,Faye.URI.parse(a).isLocal())}});Faye.Transport.register('long-polling',Faye.Transport.XHR);Faye.Transport.CORS=Faye.extend(Faye.Class(Faye.Transport,{request:function(b,c){var d=Faye.ENV.XDomainRequest?XDomainRequest:XMLHttpRequest,f=new d(),g=this.retry(b,c),j=this;f.open('POST',this._b,true);var i=function(){if(!f)return false;f.onload=f.onerror=f.ontimeout=f.onprogress=null;f=null;Faye.ENV.clearTimeout(k);return true};f.onload=function(){var a=null;try{a=JSON.parse(f.responseText)}catch(e){}i();if(a){j.receive(a);j.trigger('up')}else{g();j.trigger('down')}};var h=function(){i();g();j.trigger('down')};var k=Faye.ENV.setTimeout(h,1.5*1000*c);f.onerror=h;f.ontimeout=h;f.onprogress=function(){};f.send('message='+encodeURIComponent(Faye.toJSON(b)))}}),{isUsable:function(a,b,c){if(Faye.URI.parse(a).isLocal())return b.call(c,false);if(Faye.ENV.XDomainRequest)return b.call(c,true);if(Faye.ENV.XMLHttpRequest){var d=new Faye.ENV.XMLHttpRequest();return b.call(c,d.withCredentials!==undefined)}return b.call(c,false)}});Faye.Transport.register('cross-origin-long-polling',Faye.Transport.CORS);Faye.Transport.JSONP=Faye.extend(Faye.Class(Faye.Transport,{request:function(b,c){var d={message:Faye.toJSON(b)},f=document.getElementsByTagName('head')[0],g=document.createElement('script'),j=Faye.Transport.JSONP.getCallbackName(),i=Faye.URI.parse(this._b,d),h=this.retry(b,c),k=this;Faye.ENV[j]=function(a){n();k.receive(a);k.trigger('up')};var m=Faye.ENV.setTimeout(function(){n();h();k.trigger('down')},1.5*1000*c);var n=function(){if(!Faye.ENV[j])return false;Faye.ENV[j]=undefined;try{delete Faye.ENV[j]}catch(e){}Faye.ENV.clearTimeout(m);g.parentNode.removeChild(g);return true};i.params.jsonp=j;g.type='text/javascript';g.src=i.toURL();f.appendChild(g)}}),{_D:0,getCallbackName:function(){this._D+=1;return'__jsonp'+this._D+'__'},isUsable:function(a,b,c){b.call(c,true)}});Faye.Transport.register('callback-polling',Faye.Transport.JSONP);