/* Posts a message to a Twitter account when you press the mouse button.
Uses Twitter4j, http://twitter4j.org.
For more info: http://tinkerlondon.com/now/2010/09/13/oauth-twitter-and-processing/
Daniel Soltis, September 2010
---------------------------------------------------------
Code actualization to work with twitter4j 2.1.3
Leslie Garcia 2011
More info http://dalab.ws/dtv2 */

import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.http.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;

String msg = "twitter4j desde processing";

//copy and paste these from your application in dev.twitter.com String consumer_key = "oKYNpI5s7WNRP1V85tkmw";
String consumer_secret = "tu numero de consumer_secret";
String oauth_token = "tu numero oauth_token";
String oauth_token_secret = "tu numero oauth_token_secret";

color bgcolor = color(255);
long timer;

void setup() {
size(640,480);
}

void draw() {
background(bgcolor);
if (millis()-timer > 2000) bgcolor = color(255);
}

void mousePressed() {
Twitter twitter = new TwitterFactory().getOAuthAuthorizedInstance (
consumer_key, consumer_secret,
new AccessToken( oauth_token, oauth_token_secret) );
try {
Status st = twitter.updateStatus(msg + " " + second());
println("Successfully updated the status to [" + st.getText() + "].");
bgcolor = color(0,0,255);
timer = millis();
}
catch (TwitterException e) {
println(e.getStatusCode());
}
}
