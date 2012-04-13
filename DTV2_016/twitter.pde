
//---------------------------------------------
//VARIABLES DE TWITTER:

import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.http.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;

// pegar informacion del dev.twitter.com
String consumer_key = "oKYNpI5s7WNRP1V85tkmw";
String consumer_secret = "LZJb0fQT0xBNGNCIEg5JFRfJORBzLywUgHYEYOZyErg";
String oauth_token = "83521479-KqVM9N83waKm60D0KTctMyd1sXhYDQgMJhPOHvbsI";
String oauth_token_secret = "mgERslIneJ9Y63frNWG6SQEsPm7uNCIN7NHT2nVZSA";

//string de terminos para busquedas

String[] positivo = {
  "optimismo","amor","claridad", "soñar","avanzar", "crecer", "evolucion", "suerte", "luchar", "compromiso"};
String[] negativo = {
  "soledad","confusion","vacio", "desesperacion", "cansancio", "tristeza", "cobardia", "cobardia", "egoismo", "vanalidad"};
String[] positivoN = {
  "cinismo","sarcasmo","indiferencia", "flojera", "absurdo"};
String[] negativoN = {
  "equilibrio","desapego","busqueda","despertar", "esperanza"};


ArrayList estadosDeAnimo;
HashMap phraseList;


//---------------------------------------------




void setupTwitter(){
  
  phraseList = new HashMap<String, ArrayList>();
  
  estadosDeAnimo = new ArrayList();
  
  estadosDeAnimo.add( positivo );
  estadosDeAnimo.add( negativo );
  estadosDeAnimo.add( positivoN );
  estadosDeAnimo.add( negativoN );
  
  message = "...";
  // parametros generales de la pantalla
  //serial.begin(9600);


  // configuración del twitter4j

    
  for(int i = 0; i < estadosDeAnimo.size(); i++ )
  {
      String[] palabras = (String[])estadosDeAnimo.get(i);
      
      for(int j = 0; j<palabras.length; j++)
        generarListaFrases(palabras[j]);
      
  }

  
}


void generarListaFrases(String palabra){
  
  Twitter twitter = new TwitterFactory().getOAuthAuthorizedInstance (
  consumer_key, consumer_secret, new AccessToken( oauth_token, oauth_token_secret) );

  try{

    Query query = new Query( palabra );//cargar el resultado de un string con random
    query.setGeoCode(new GeoLocation(50.0, 10.0), 1000.0, Query.KILOMETERS);
    query.setRpp(100);
    query.setLang("es"); // busqueda español
    QueryResult result = twitter.search(query);
          
    ArrayList tweets = (ArrayList) result.getTweets();      
    
    phraseList.put(palabra,tweets);
              
  }
  catch(TwitterException te){
    
      println("couldn't connect: " +te);   
  
  }

}



String getTweet ( int index ){

  String msg;
  
  String[] palabras = (String[])estadosDeAnimo.get(index);


  //RANDOM


  int wordIndex = int( random( palabras.length ) ) ;

          
  ArrayList tweetz = (ArrayList) phraseList.get(palabras[wordIndex]);
      
  //RANDOM

  int twitIndex = int( random( tweetz.size() ) );
      
  Tweet t = (Tweet) tweetz.get(twitIndex);
      
  String user = t.getFromUser();
  msg = t.getText();

  Date d = t.getCreatedAt();

//  println("Tweet by" + user + "at" + d + ": " + msg);
  
  
  

  msg = msg.replaceAll("[^A-Za-záéíóúñ.,?@# ]", "");
  //msg = msg.replaceAll("ce", "se");
  //msg = msg.replaceAll("ci", "si");
  //msg = msg.replaceAll("z", "s");


  String tmpString="";
  String convertedString;

  msg = cleanString(msg,"http");
  
  msg = cleanString(msg,"www");
  
  msg = cleanString(msg,"#");
  msg = cleanString(msg,"@");
  
  msg = msg.replace("RT","");

  return msg;



}


String cleanString(String msg, String str){

  String tmpString="";

  while(msg.contains(str))  {
    int indexArroba = msg.indexOf(str);
    
    if(indexArroba>=0) {
    
      tmpString = msg.substring(indexArroba) ;
      if(tmpString.indexOf(" ")>=0)
        tmpString = tmpString.substring(0,tmpString.indexOf(" ") );
        String msg2 =
        msg = msg.replace( tmpString, "" );
        println("borré: "+tmpString );
    
    }    
    

  }  
  return msg;
}


