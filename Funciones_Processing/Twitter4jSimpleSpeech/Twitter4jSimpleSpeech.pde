/* code for query on twitter and speak the result Leslie Garcia 2011 */

import processing.serial.*;
import simpleSpeech.*;
import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.http.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;

// iniciar simple speach Speak yourVoice;

// pegar informacion del dev.twitter.com String consumer_key = "oKYNpI5s7WNRP1V85tkmw";
String consumer_secret = "tu numero consumer key";
String oauth_token = " tu numero oauth token";
String oauth_token_secret = "tu oauth token screat";

//string de terminos para busquedas String[] positivo = {
  "light","love","dreams", "hopes"};
String[] negativo = {
  "lonlyness","fear"};
String[] positivoN = {
  "cynicism","sarcasm"};
String[] negativoN = {
  "watever"};

// Valores aleatorios para la busqueda 
int index1 = int(random(positivo.length));
int index2 = int(random(negativo.length));
int index3 = int(random(positivoN.length));
int index4 = int(random(negativoN.length));

// seleccion de array a partir de valores analogos 

void setup(){

  // parametros generales de la pantalla   //serial.begin(9600);   size(800,100);

  //configuración del simple speech   yourVoice = new Speak(this);
  frameRate(12);

  // configuración del twitter4j 
  Twitter twitter = new TwitterFactory().getOAuthAuthorizedInstance (
  consumer_key, consumer_secret, new AccessToken( oauth_token, oauth_token_secret) );
  try{

    Query query = new Query(negativo[index2]); //cargar el resultado de un string con random 
    query.setGeoCode(new GeoLocation(50.0, 10.0), 1000.0, Query.KILOMETERS);
    query.setRpp(100);
   // query.setLang("es"); // busqueda español 
    QueryResult result = twitter.search(query);

    ArrayList tweets = (ArrayList) result.getTweets();

    for(int i = 0;i<tweets.size();i++){
      Tweet t = (Tweet) tweets.get(i);
      String user = t.getFromUser();
      String msg = t.getText();
      Date d = t.getCreatedAt();
      println("Tweet by" + user + "at" + d + ": " + msg);
      background(0);

      //configuracion de voz       yourVoice.speak(msg);

    }
  }
  catch(TwitterException te){
    println("couldn't connect: " +te);

  }

}

void draw(){

}
