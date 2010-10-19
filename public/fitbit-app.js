// Some methods are slightly different for apps vs the website.
// This file has the app version of the methods

//var url_base = "http://danmayer.dnsalias.com:4567";
var url_base = "https://fitbit-widget-staging.heroku.com";
//var url_base = "https://fitbit-widget.heroku.com";
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
    result = url_base+path+"?app=true";
  }
  return result;
};

var menu = function() {
  $("#menu").toggle();
  window.scrollTo(0, 1);
  return false;
};

var logoutGet = function() {
  window.scrollTo(0, 1);
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
  window.scrollTo(0, 1);
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

var setupAutoComplete = function() {
  $("#food").autocomplete(getURL("/food_complete"),{delay:15, minChars:3});
};

var foodSubmitForm = function() {
 window.scrollTo(0, 1);
 actions.push([getHome, null]);
 food_date = $("input#food_date").val();
 food = $("input#food").val();
 quantity = $("select#quantity").val();
 quantity_type = $("select#quantity_type").val();
 meal_type = $("select#meal_type").val();
 //for some reasons this fails on my android
 //var dataString = $("foodLogForm").serialize();
 var dataString = 'food='+ food + '&quantity=' + quantity + '&quantity_type=' + quantity_type + '&food_date=' + food_date + '&meal_type=' + meal_type + "&email="+user+"&password="+pass+"&app=true";
  $.ajax({  
    type: "POST",  
	url: url_base+"/log_food",  
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

function roundNumber(num) {
  var dec = 3;
  var result = Math.round(num*Math.pow(10,dec))/Math.pow(10,dec);
  return result;
}

var step = 0;
var last_x = 0;
var last_y = 0;
var last_z = 0;
var watchAccel = function() {
  var suc = function(a){
    document.getElementById('x').innerHTML = roundNumber(a.x);
    document.getElementById('y').innerHTML = roundNumber(a.y);
    document.getElementById('z').innerHTML = roundNumber(a.z);
    if( Math.abs(Math.pow((last_x+last_y+last_z),2)-Math.pow((a.x+a.y+a.z),2)) > 25 ) {
      step = step + 1;
    }
    last_x = a.x;
    last_y = a.y;
    last_z = a.z;
    document.getElementById('step').innerHTML = step;
    
  };
  var fail = function(){};
  var opt = {};
  opt.frequency = 100;
  timer = navigator.accelerometer.watchAcceleration(suc,fail,opt);
}

//Phonegap specific init
document.addEventListener("deviceready", function(){ 
    //todo block if not on device
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
	menu();
      }, false); 

//     watchAccel();
  }, false); 
