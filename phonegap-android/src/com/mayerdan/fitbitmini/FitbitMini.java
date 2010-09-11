package com.mayerdan.fitbitmini;

import android.app.Activity;
import android.content.Context;
import android.net.http.SslError;
import android.os.Bundle;
import android.util.Log;
import android.webkit.SslErrorHandler;
import android.webkit.WebView;

import com.phonegap.*;
import com.phonegap.DroidGap.GapClient;


public class FitbitMini extends DroidGap
{
@Override
public void onCreate(Bundle savedInstanceState) {
super.onCreate(savedInstanceState);
appView = super.getView();
appView.setWebChromeClient(new SecureGapViewClient(this));
super.loadUrl("file:///android_asset/www/index.html");
}

public class SecureGapViewClient extends GapClient {		
	
	public SecureGapViewClient(Context ctx)
	{
		super(ctx);
	}
	
	// OK so android 1.5, 1.6, and 2.1 have really broken https support it raised errors on gmails cert
	// ours as well, this overrides the ssl handler and accepts the cert if it is ours
	//@Override
	public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) { 
		Log.d("WebAuth","SSL error check/override continue: "+error);	
		if((""+error).indexOf("heroku")!=-1)
		{
			Log.d("WebAuth","SSL from our domain check/override continue: ALLOWED");	
			handler.proceed();
		} else {
			Log.d("WebAuth","SSL not from our domain check/override fail: NOT ALLOWED");	
			handler.cancel();
		}
	}
  
}

}
