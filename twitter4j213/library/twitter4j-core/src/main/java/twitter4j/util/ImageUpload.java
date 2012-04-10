package twitter4j.util;

import java.io.File;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.http.Authorization;
import twitter4j.http.BasicAuthorization;
import twitter4j.http.OAuthAuthorization;
import twitter4j.internal.http.HttpClientWrapper;
import twitter4j.internal.http.HttpParameter;
import twitter4j.internal.http.HttpResponse;
import twitter4j.internal.org.json.JSONException;
import twitter4j.internal.org.json.JSONObject;

public abstract class ImageUpload
{
    public static String DEFAULT_TWITPIC_API_KEY = null;
    
    public abstract String upload (File image) throws TwitterException;
    public abstract String upload (String imageFileName, InputStream imageBody) throws TwitterException;
    
    
    /** Returns an image uploader to Twitpic. Handles both BasicAuth and OAuth.
     *  Note: When using OAuth, the Twitpic API Key needs to be specified, either with the field ImageUpload.DEFAULT_TWITPIC_API_KEY,
     *   or using the getTwitpicUploader (String twitpicAPIKey, OAuthAuthorization auth) method
     */
    public static ImageUpload getTwitpicUploader (Twitter twitter) throws TwitterException
    {
        Authorization auth = twitter.getAuthorization ();
        if (auth instanceof OAuthAuthorization)
            return getTwitpicUploader (DEFAULT_TWITPIC_API_KEY, (OAuthAuthorization) auth);
        
        ensureBasicEnabled (auth);
        return getTwitpicUploader ((BasicAuthorization) auth);
    }

    /**
     * Returns a BasicAuth image uploader to Twitpic
     */
    public static ImageUpload getTwitpicUploader(BasicAuthorization auth) {
        return new TwitpicBasicAuthUploader(auth);
    }

    /** Returns an OAuth image uploader to Twitpic */
    public static ImageUpload getTwitpicUploader (String twitpicAPIKey, OAuthAuthorization auth)
    {
        return new TwitpicOAuthUploader (twitpicAPIKey, auth);
    }
    
    
    /** Returns an image uploader to YFrog. Handles both BasicAuth and OAuth */
    public static ImageUpload getYFrogUploader (Twitter twitter) throws TwitterException
    {
        Authorization auth = twitter.getAuthorization ();
        if (auth instanceof OAuthAuthorization)
            return getYFrogUploader (twitter.getScreenName (), (OAuthAuthorization) auth);
        
        ensureBasicEnabled (auth);
        return getYFrogUploader ((BasicAuthorization) auth);
    }
    
    /** Returns a BasicAuth image uploader to YFrog */
    public static ImageUpload getYFrogUploader (BasicAuthorization auth)
    {
        return new YFrogBasicAuthUploader (auth);
    }

    /**
     * Returns an OAuth image uploader to YFrog
     */
    public static ImageUpload getYFrogUploader(String userId, OAuthAuthorization auth) {
        return new YFrogOAuthUploader(userId, auth);
    }

    private static void ensureBasicEnabled(Authorization auth) {
        if (!(auth instanceof BasicAuthorization)) {
            throw new IllegalStateException(
                    "user ID/password combination not supplied");
        }
    }

    private static class YFrogOAuthUploader extends ImageUpload {
        private String user;
        private OAuthAuthorization auth;

        // uses the secure upload URL, not the one specified in the YFrog FAQ
        private static final String YFROG_UPLOAD_URL = "https://yfrog.com/api/upload";
        private static final String TWITTER_VERIFY_CREDENTIALS = "https://api.twitter.com/1/account/verify_credentials.xml";

        public YFrogOAuthUploader(String user, OAuthAuthorization auth) {
            this.user = user;
            this.auth = auth;
        }

        @Override
        public String upload(File image) throws TwitterException {
            // step 1 - generate verification URL
            String signedVerifyCredentialsURL = generateSignedVerifyCredentialsURL();

            // step 2 - generate HTTP parameters
            HttpParameter[] params = {
                    new HttpParameter("auth", "oauth"),
                    new HttpParameter("username", user),
                    new HttpParameter("verify_url", signedVerifyCredentialsURL),
                    new HttpParameter("media", image)                
                    };
            return upload(params);
        }

        public String upload(String imageFileName, InputStream imageBody) throws TwitterException {
            // step 1 - generate verification URL
            String signedVerifyCredentialsURL = generateSignedVerifyCredentialsURL();

            // step 2 - generate HTTP parameters
            HttpParameter[] params = {
                    new HttpParameter("auth", "oauth"),
                    new HttpParameter("username", user),
                    new HttpParameter("verify_url", signedVerifyCredentialsURL),
                    new HttpParameter("media", imageFileName, imageBody)
                    };
            return upload(params);
        }

        private String upload(HttpParameter[] params) throws TwitterException {
            // step 3 - upload the file
            HttpClientWrapper client = new HttpClientWrapper();
            HttpResponse httpResponse = client.post(YFROG_UPLOAD_URL, params);

            // step 4 - check the response
            int statusCode = httpResponse.getStatusCode();
            if (statusCode != 200) {
                throw new TwitterException("YFrog image upload returned invalid status code", httpResponse);
            }

            String response = httpResponse.asString();
            if (response.contains("<rsp stat=\"fail\">")) {
                String error = response.substring(response.indexOf("msg") + 5, response.lastIndexOf("\""));
                throw new TwitterException("YFrog image upload failed with this error message: " + error, httpResponse);
            }
            if (response.contains("<rsp stat=\"ok\">")) {
                String media = response.substring(response.indexOf("<mediaurl>") + "<mediaurl>".length(), response.indexOf("</mediaurl>"));
                return media;
            }

            throw new TwitterException("Unknown YFrog response", httpResponse);
        }

        private String generateSignedVerifyCredentialsURL() {
            List<HttpParameter> oauthSignatureParams = auth.generateOAuthSignatureHttpParams("GET", TWITTER_VERIFY_CREDENTIALS);
            return TWITTER_VERIFY_CREDENTIALS + "?" + OAuthAuthorization.encodeParameters(oauthSignatureParams);
        }
    }

    private static class YFrogBasicAuthUploader extends ImageUpload {
        private BasicAuthorization auth;

        // uses the secure upload URL, not the one specified in the YFrog FAQ
        private static final String YFROG_UPLOAD_URL = "https://yfrog.com/api/upload";

        public YFrogBasicAuthUploader(BasicAuthorization auth) {
            this.auth = auth;
        }

        @Override
        public String upload(File image) throws TwitterException {
            // step 1 - generate HTTP parameters
            HttpParameter[] params =
                    {
                            new HttpParameter("username", auth.getUserId()),
                            new HttpParameter("password", auth.getPassword()),
                            new HttpParameter("media", image)
                    };
            return upload(params);
        }

        @Override
        public String upload(String imageFileName, InputStream imageBody) throws TwitterException {
            // step 1 - generate HTTP parameters
            HttpParameter[] params =
                    {
                            new HttpParameter("username", auth.getUserId()),
                            new HttpParameter("password", auth.getPassword()),
                            new HttpParameter("media", imageFileName, imageBody)
                    };
            return upload(params);
        }

        private String upload(HttpParameter[] params) throws TwitterException {
            // step 2 - upload the file
            HttpClientWrapper client = new HttpClientWrapper();
            HttpResponse httpResponse = client.post(YFROG_UPLOAD_URL, params);

            // step 3 - check the response
            int statusCode = httpResponse.getStatusCode();
            if (statusCode != 200)
                throw new TwitterException("YFrog image upload returned invalid status code", httpResponse);

            String response = httpResponse.asString();
            if (response.contains("<rsp stat=\"fail\">")) {
                String error = response.substring(response.indexOf("msg") + 5, response.lastIndexOf("\""));
                throw new TwitterException("YFrog image upload failed with this error message: " + error, httpResponse);
            }

            if (response.contains("<rsp stat=\"ok\">")) {
                String media = response.substring(response.indexOf("<mediaurl>") + "<mediaurl>".length(), response.indexOf("</mediaurl>"));
                return media;
            }

            throw new TwitterException("Unknown YFrog response", httpResponse);
        }
    }

    // Described at http://dev.twitpic.com/docs/2/upload/
    private static class TwitpicOAuthUploader extends ImageUpload
    {
        private String twitpicAPIKey;
        private OAuthAuthorization auth;
        
        // uses the secure upload URL, not the one specified in the Twitpic FAQ
        private static final String TWITPIC_UPLOAD_URL = "https://twitpic.com/api/2/upload.json";
        private static final String TWITTER_VERIFY_CREDENTIALS = "https://api.twitter.com/1/account/verify_credentials.json";
        
        public TwitpicOAuthUploader (String twitpicAPIKey, OAuthAuthorization auth)
        {
            if (twitpicAPIKey == null || "".equals (twitpicAPIKey))
                throw new IllegalArgumentException ("The Twitpic API Key supplied to the OAuth image uploader can't be null or empty");
            
            this.twitpicAPIKey = twitpicAPIKey;
            this.auth = auth;
        }

        @Override
        public String upload (File image) throws TwitterException
        {
            // step 2 - generate HTTP parameters
            HttpParameter[] params =
            {
                new HttpParameter ("key", twitpicAPIKey),
                new HttpParameter ("media", image)
            };

            return upload(params);
        }

        @Override
        public String upload (String imageFileName, InputStream imageBody) throws TwitterException
        {
            // step 2 - generate HTTP parameters
            HttpParameter[] params =
            {
                new HttpParameter ("key", twitpicAPIKey),
                new HttpParameter ("media", imageFileName, imageBody)
            };

            return upload(params);
        }

        private String upload (HttpParameter[] params) throws TwitterException
        {
            // step 1 - generate HTTP request headers
            String verifyCredentialsAuthorizationHeader = generateVerifyCredentialsAuthorizationHeader ();
            
            Map<String, String> headers = new HashMap<String, String> ();
            headers.put ("X-Auth-Service-Provider", TWITTER_VERIFY_CREDENTIALS);
            headers.put ("X-Verify-Credentials-Authorization", verifyCredentialsAuthorizationHeader);
            
            
            // step 3 - upload the file
            HttpClientWrapper client = new HttpClientWrapper ();
            HttpResponse httpResponse = client.post (TWITPIC_UPLOAD_URL, params, headers);
            
            // step 4 - check the response
            int statusCode = httpResponse.getStatusCode ();
            if (statusCode != 200)
                throw new TwitterException ("Twitpic image upload returned invalid status code", httpResponse);
            
            String response = httpResponse.asString ();
            
            try
            {
                JSONObject json = new JSONObject (response);
                if (! json.isNull ("url"))
                    return json.getString ("url");
            }
            catch (JSONException e)
            {
                throw new TwitterException ("Invalid Twitpic response: " + response, e);
            }
            
            throw new TwitterException ("Unknown Twitpic response", httpResponse);
        }
        
        private String generateVerifyCredentialsAuthorizationHeader ()
        {
            List<HttpParameter> oauthSignatureParams = auth.generateOAuthSignatureHttpParams ("GET", TWITTER_VERIFY_CREDENTIALS);
            return "OAuth realm=\"http://api.twitter.com/\"," + OAuthAuthorization.encodeParameters (oauthSignatureParams, ",", true);
        }
    }
    
    private static class TwitpicBasicAuthUploader extends ImageUpload
    {
        private BasicAuthorization auth;

        // uses the secure upload URL, not the one specified in the Twitpic FAQ
        private static final String TWITPIC_UPLOAD_URL = "https://twitpic.com/api/upload";

        public TwitpicBasicAuthUploader(BasicAuthorization auth) {
            this.auth = auth;
        }

        @Override
        public String upload(File image) throws TwitterException {
            // step 1 - generate HTTP parameters
            HttpParameter[] params =
                    {
                            new HttpParameter("username", auth.getUserId()),
                            new HttpParameter("password", auth.getPassword()),
                            new HttpParameter("media", image)
                    };
            
            return upload(params);
        }

        @Override
        public String upload(String imageFileName, InputStream imageBody) throws TwitterException {
            // step 1 - generate HTTP parameters
            HttpParameter[] params =
                    {
                            new HttpParameter("username", auth.getUserId()),
                            new HttpParameter("password", auth.getPassword()),
                            new HttpParameter("media", imageFileName, imageBody)
                    };
            
            return upload(params);
        }

        private String upload(HttpParameter[] params) throws TwitterException {
            // step 2 - upload the file
            HttpClientWrapper client = new HttpClientWrapper();
            HttpResponse httpResponse = client.post(TWITPIC_UPLOAD_URL, params);

            // step 3 - check the response
            int statusCode = httpResponse.getStatusCode();
            if (statusCode != 200)
                throw new TwitterException("Twitpic image upload returned invalid status code", httpResponse);

            String response = httpResponse.asString();
            if (response.contains("<rsp stat=\"fail\">")) {
                String error = response.substring(response.indexOf("msg") + 5, response.lastIndexOf("\""));
                throw new TwitterException("Twitpic image upload failed with this error message: " + error, httpResponse);
            }

            if (response.contains("<rsp stat=\"ok\">")) {
                String media = response.substring(response.indexOf("<mediaurl>") + "<mediaurl>".length(), response.indexOf("</mediaurl>"));
                return media;
            }

            throw new TwitterException("Unknown Twitpic response", httpResponse);
        }
    }
}
