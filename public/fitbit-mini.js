    var url_base = ""

    function init(){
      //add this in your javascript code to 'hide' the address bar  
      window.scrollTo(0, 1);
    }

    var sparklines = function() {
        /** This code runs when everything has been loaded on the page */
        /* Inline sparklines take their values from the contents of the tag */
        $('.inlinesparkline').sparkline(); 

        /* Use 'html' instead of an array of values to pass options 
        to a sparkline with data in the tag */
        $('.inlinebar').sparkline('html', {type: 'bar', barColor: '#81F7F3'} );
    }

    var hideLoading = function() {
      $("#loading").hide();
    }

    var accountGet = function(callback) {
    $.retrieveGet(url_base+"/account", function(content, status) {
      $("#content").empty().append(content);
      hideLoading();
    });
    return false;
    };

    var widgetGet = function(callback) {
    $.retrieveGet(url_base+"/get_widget", function(content, status) {
      $("#content").empty().append(content);
      hideLoading();
    });
    return false;
    };

    var logoutGet = function(callback) {
    $.get(url_base+"/logout", function(content, status) {
      $("#content").empty().append(content);
      reloadFooter();
      hideLoading();
    });
    return false;
    };

   var reloadFooter = function(callback) {
    $.retrieveGet(url_base+"/footer", function(content, status) {
      $("#footer").empty().append(content);
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
         reloadFooter();
         hideLoading();
       }  
      });  
    return false;
    };

    var getHome = function(url) {
    $.retrieveGet(url, function(content, status) {
      $("#loading").show();
      $("#content").empty().hide();
      $("#content").append(content);
      hideLoading();
      $("#content").show();
      sparklines();
    });
    return false;
    };

    jQuery(document).ready(function($) {
	// Since jQuery.retrieveJSON delegates to jQuery's Ajax
	// to make requests, we can just set up normal jQuery
	// Ajax listeners.
	//$("#loading").ajaxStart(function() { $(this).show(); });
	//$("#loading").ajaxStop(function() {  $(this).hide(); });
	
	//immediately check to see if they should have thier account page or home page
	//setFrontPageContent();
      });
