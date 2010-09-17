// Some methods are slightly different for apps vs the website.
// This file has the app version of the methods

//var url_base = "http://danmayer.dnsalias.com:4567";
//var url_base = "https://fitbit-widget-staging.heroku.com";
var url_base = "https://fitbit-widget.heroku.com";
var user = "";
var pass = "";

var getURL = function(path) { 
  result = false
  if(user!="" && user!=null) {
    if (path.indexOf('?')>0) {
      result = url_base+path+"&email="+user+"&password="+pass+"&app=true";
    } else {
      result = url_base+path+"?email="+user+"&password="+pass+"&app=true";
    }
  } else {
    result = url_base+path;
  }
  return result;
};

var logoutGet = function() {
  actions = [];
  $.cookie("user", '');
  $.cookie("pass", '');
  user = "";
  pass = "";
  $.get(getURL("/logout"), function(content, status) {
      $("#content").empty().append(content);
      hideLoading();
    });
  return false;
};

var loginFormSubmit = function() {
  actions.push([getHome, null]);
  user = $("input#email").val();
  pass = $("input#password").val();
  var dataString = 'password='+ pass + '&email=' + user;
  //save these variables to cookies, files, etc
  $.cookie("user", user);
  $.cookie("pass", pass);
  $.ajax({  
    type: "POST",  
	url: url_base+"/account/login",  
	data: dataString,  
	success: function(content) {  
	$("#content").empty().append(content);
	sparklines();
	hideLoading();
      }  
    });  
  return false;
};

jQuery(document).ready(function($) {

    user = $.cookie("user");
    pass = $.cookie("pass");

    //a hack to force xhr request header, 
    //with out this it works in site, but fails on local files (ie phonegap)
    jQuery.ajaxSetup({
      beforeSend: function(xhr) {
	  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
	}
      });
    
    if(user!=null && user!='' && pass!=null && pass!='') {
      getHome('/home');
    }
    sparklines();
    
  });

//Phonegap specific init
document.addEventListener("deviceready", function(){ 
    device.overrideBackButton(); 
    document.addEventListener("backKeyDown", function(){ 
	if (actions.length>1) {
	  current = actions.pop();
	  recent = actions.pop();
	  method = recent[0];
	  args = recent[1];
	  method(args);
	} else {
	  BackButton.reset();
	  BackButton.exitApp();
	}
      }, false); 

    document.addEventListener("menuKeyDown", function(){ 
	alert("There really is no need for a menu in this app.\n So Fitbit mini was created by Dan Mayer cause he loves his fitbit.");
      }, false); 

  }, false); 
