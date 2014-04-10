﻿package  {		import flash.display.MovieClip;		import flash.net.URLLoader;	import flash.net.URLRequest;	import flash.net.URLLoaderDataFormat;	import flash.net.URLRequestMethod;	import flash.net.URLVariables;	import flash.events.Event;	import flash.utils.ByteArray;		import com.jonas.net.Multipart;		public class testPost extends MovieClip {						public function testPost() {			// constructor code			this.addEventListener(Event.ADDED, init);		}				private function init(event : Event) : void		{			this.removeEventListener(Event.ADDED, init);						testSetTarget();		}				private function testSetTarget() : void		{			var variables : URLVariables = new URLVariables();				variables.id = escape("test1234");				variables.target = "基隆市家庭教育中心";						var request : URLRequest = new URLRequest("http://tapmovie.com/familyedu/setTarget.php");				request.data = variables;				request.method = URLRequestMethod.POST;						var loader : URLLoader = new URLLoader();				loader.dataFormat = URLLoaderDataFormat.TEXT;				loader.addEventListener(Event.COMPLETE, function(e : Event) : void				{					trace(e.target.data);				});			loader.load(request);		}				private function testIsDrawn() : void		{			var variables : URLVariables = new URLVariables();				variables.id = escape("test1234");						var request : URLRequest = new URLRequest("http://tapmovie.com/familyedu/isDrawn.php");				request.data = variables;				request.method = URLRequestMethod.POST;						var loader : URLLoader = new URLLoader();				loader.dataFormat = URLLoaderDataFormat.TEXT;				loader.addEventListener(Event.COMPLETE, function(e : Event) : void				{					trace(e.target.data);				});			loader.load(request);		}				private function testPostFile() : void		{			var request : URLRequest = new URLRequest("https://github.com/fluidicon.png");			var loader : URLLoader = new URLLoader();				loader.dataFormat = URLLoaderDataFormat.BINARY;				loader.addEventListener(Event.COMPLETE, function(event : Event) : void				{					var byteArray : ByteArray = ByteArray(event.target.data);					var multipart : Multipart = new Multipart("http://tapmovie.com/familyedu/uploadFile.php");						multipart.addField("id", "hfowe321312321fhweoifhoewif");						multipart.addFile("file", byteArray, "application/octet-stream", "test.png");					 					var loaderPost : URLLoader = new URLLoader();						loaderPost.addEventListener(Event.COMPLETE, function(e : Event) : void						{							trace(e.target.data);						});						loaderPost.load(multipart.request);				});				loader.load(request);		}				private function testPostUserInfo() : void		{			var variables : URLVariables = new URLVariables();				variables.id = escape("hfowe321312321fhweoifhoewif");				variables.email = escape("noin@cameo.tw");				variables.phone = escape("0987654321");						trace(variables.toString());						var request : URLRequest = new URLRequest("http://tapmovie.com/familyedu/userInfo.php");				request.data = variables;				request.method = URLRequestMethod.POST;						var loader : URLLoader = new URLLoader();				loader.dataFormat = URLLoaderDataFormat.TEXT;				loader.addEventListener(Event.COMPLETE, function(e : Event) : void				{					trace(e.target.data);				});			loader.load(request);		}	}	}