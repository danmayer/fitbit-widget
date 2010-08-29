// Some methods are slightly different for apps vs the website.
// This file has the website version of the methods

var getURL = function(path) { 
  path
};

var logoutGet = function(callback) {
  $.get(url_base+"/logout", function(content, status) {
      $("#content").empty().append(content);
      hideLoading();
    });
  return false;
};

var loginFormSubmit = function() {
  var email = $("input#email").val();
  var pass = $("input#password").val();
  var dataString = 'password='+ pass + '&email=' + email;
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
    sparklines();
});
