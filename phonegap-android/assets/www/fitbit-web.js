// Some methods are slightly different for apps vs the website.
// This file has the website version of the methods

var getURL = function(path) { 
  return path;
};

var logoutGet = function(callback) {
  window.scrollTo(0, 1);
  $.get("/logout", function(content, status) {
      $("#content").empty().append(content);
      hideLoading();
    });
  return false;
};

var loginFormSubmit = function() {
  window.scrollTo(0, 1);
  var email = $("input#email").val();
  var pass = $("input#password").val();
  var dataString = 'password='+ pass + '&email=' + email;
  $.ajax({  
    type: "POST",  
	url: "/account/login",  
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
  $("#food").autocomplete('/food_complete',{delay:15, minChars:3});
};

var foodSubmitForm = function() {
  $("#log_food_submit").disable();
  window.scrollTo(0, 1);
  food_date = $("input#food_date").val();
  food = $("input#food").val();
  quantity = $("select#quantity").val();
  quantity_type = $("select#quantity_type").val();
  meal_type = $("select#meal_type").val();
  //for some reasons this doesn't work after ajax calls? Perhaps finds old form still in the dom?
  //var dataString = $("foodLogForm").serialize();
  var dataString = 'food='+ food + '&quantity=' + quantity + '&quantity_type=' + quantity_type + '&food_date=' + food_date + '&meal_type=' + meal_type;
  $.ajax({  
    type: "POST",  
	url: "/log_food",  
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
    sparklines();
});
