package com.mayerdan.fitbitmini;

import android.content.Context;
import android.net.http.SslError;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.webkit.SslErrorHandler;
import android.webkit.WebView;
import android.widget.ImageView;
import com.phonegap.*;

public class FitbitMini extends DroidGap {
	
	private static final int STOPSPLASH = 0;
    //time in milliseconds
    private static final long SPLASHTIME = 4300;
    private ImageView splash;

	//from post about splashscreens
	//http://www.anddev.org/simple_splash_screen-t811.html
	private Handler splashHandler = new Handler() {
		// @Override
		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case STOPSPLASH:
				// remove SplashScreen from view
				setContentView(root);
				appView.requestFocus();
				break;
			}
			super.handleMessage(msg);
		}
	};

	// override the droidgap oncreate
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		try {
			setContentView(R.layout.splash);
		} catch(RuntimeException exception) {
			//Some old 1.5s don't like this rescue if the splash fails and ignore it
		}
		appView = super.getView();
		appView.setWebChromeClient(new SecureGapViewClient(this));
		super.loadUrl("file:///android_asset/www/index.html");
		
		Message msg = new Message();
		msg.what = STOPSPLASH;
		splashHandler.sendMessageDelayed(msg, SPLASHTIME);
	}

	public class SecureGapViewClient extends GapClient {

		public SecureGapViewClient(Context ctx) {
			super(ctx);
		}

		// OK so android 1.5, 1.6, and 2.1 have really broken https support it
		// raised errors on gmails cert
		// ours as well, this overrides the ssl handler and accepts the cert if
		// it is ours
		//@Override
		public void onReceivedSslError(WebView view, SslErrorHandler handler,
				SslError error) {
			Log.d("WebAuth", "SSL error check/override continue: " + error);
			if (("" + error).indexOf("heroku") != -1) {
				Log.d("WebAuth",
						"SSL from our domain check/override continue: ALLOWED");
				handler.proceed();
			} else {
				Log
						.d("WebAuth",
								"SSL not from our domain check/override fail: NOT ALLOWED");
				handler.cancel();
			}
		}

	}

}
