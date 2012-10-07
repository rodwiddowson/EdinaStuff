package uk.ac.edina;

import java.io.IOException;
import java.security.Principal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

import javax.security.auth.Subject;
import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.NameCallback;
import javax.security.auth.callback.PasswordCallback;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.auth.login.LoginException;
import javax.security.auth.spi.LoginModule;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.sun.security.auth.module.Krb5LoginModule;

public class JaasLoginViaDb implements LoginModule {

	    private Subject subject;
	    private Krb5LoginModule kerberos;
	    private CallbackHandler callback;
	    private boolean calledKerberos = false;

	    //
	    // Configuration
	    //
	    private String jdbcDriver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
	    private String jdbcUrl = "";
	    private String userColumn = "username";
	    private String passwordColumn = "password";
	    private String useDBColumn = "usedb";
	    private String tableName = "table";
	    private String userName= "";
	    private final static Logger LOG = LoggerFactory.getLogger(JaasLoginViaDb.class);
	    
	    public JaasLoginViaDb()
	    {
	        kerberos = new Krb5LoginModule();
	    }
	    
	    public void initialize( Subject subject, 
	                            CallbackHandler callbackHandler, 
	                            Map<String, ?> sharedState, 
	                            Map<String, ?> options ) {

	        String s;
	        
	        s = (String) options.get("jdbcDriver");
	        if (s != null) {
	            jdbcDriver = s;
	        }
	        
	        s = (String) options.get("jdbcUrl");
	        if (s != null) {
	            jdbcUrl = s;
	        }
	        
	        s = (String) options.get("usernameColumnName");
	        if (s != null) {
	            userColumn = s;
	        }
	        
	        s = (String) options.get("useDBColumnName");
	        if (s != null) {
	            useDBColumn = s;
	        }
	        
	        s = (String) options.get("passwordColumnName");
	        if (s != null) {
	            passwordColumn = s;
	        }
	        
	        s = (String) options.get("tableName");
	        if (s != null) {
	            tableName = s;
	        }       
	        
            kerberos.initialize(subject, callbackHandler, sharedState, options);
	        this.subject = subject;
	        this.callback = callbackHandler;

	    }
	    
	    public boolean commit() throws LoginException {

	        boolean answer = true;
	        
	        LOG.debug("Commit...");
	        
	        if (calledKerberos) {
	            try {
	                answer = kerberos.commit();
	            } 
	            catch (LoginException e) {
	                LOG.debug("Kerberos threw ", e);
	                throw e;
	            }
	        }

	        if (subject !=null) {
	            subject.getPrincipals().clear();
	            subject.getPrincipals().add( new MyPrincipal(userName) );
	        }
	        return answer;
	    }
	    
	    public boolean abort() throws LoginException {
	        return kerberos.abort();            
	    }

	    public boolean login() throws LoginException {

	        String  password; // We shouldn't keep the password as a string but this is low security;
	        
	        //
	        // Collect the data
	        //
	        
	        if (callback == null) {
	            LOG.error("no CallbackHandler.  login failed");
	            throw new LoginException("Error: no CallbackHandler login failed");
	        }

	        Callback[] callbacks = new Callback[2];
	        NameCallback nameCallback = new NameCallback("Username: "); 
	        PasswordCallback passwordCallback = new PasswordCallback("Password: ", false);
	        callbacks[0] = nameCallback;
	        callbacks[1] = passwordCallback;
	        

	        try {
	            callback.handle(callbacks);
	        } catch (IOException e1) {
	            LOG.error("Callback threw an IO exception", e1);
	            throw new LoginException("Callback threw an IO exception");
	        } catch (UnsupportedCallbackException e1) {
	            LOG.error("Callback threw an exception", e1);
	            throw new LoginException("Callback threw an Unsupported call exception");
	        }
	        //
	        // Get username..
	        //
	        userName = nameCallback.getName();

	        //
	        // Set up password
	        //
	        password = new String(passwordCallback.getPassword());
	        passwordCallback.clearPassword();

	        LOG.debug("Got username/password username = " + userName);
	        //
	        // Now, get the JDBC handler loaded
	        //        
	        try {
	            Class.forName(jdbcDriver);
	            
	        } catch (ClassNotFoundException e) {
				LOG.error("Couldn't get JDBC driver");
	            throw new LoginException("Couldn't get JDBC driver");
	        }
	        
	        Connection connection = null;
	        PreparedStatement statement = null;
	        ResultSet results = null;
	        boolean usePass = false;
	        String dbPass = null;;
	        boolean dbEmpty = true;

	        try {
	            connection = DriverManager.getConnection(jdbcUrl);

	            StringBuffer sb = new StringBuffer("SELECT ");
	            sb.append(useDBColumn).append(',').append(passwordColumn).append(" FROM ");
				sb.append(tableName).append(" WHERE ").append(userColumn).append(" = '");
    	        sb.append(userName).append("';");

	            statement = connection.prepareStatement(sb.toString());
	            //statement.setString(1, userName);

	            System.out.println("Wheee -- " + statement.toString());

	            results = statement.executeQuery();
	            dbEmpty = !results.next();
	            
	            if (!dbEmpty) {
	                usePass = (results.getInt(useDBColumn) != 0);
	                dbPass = results.getString(passwordColumn);
	            } 
	        } 
	        catch (SQLException s) {
				LOG.error("DB lookup failed  - ", s);
	            throw new LoginException("DB lookup failed  - " + s.toString());
	        }
	        finally {
	            try {
	                if (connection != null) {
	                    connection.close();
	                }
	                if (statement != null) {
	                    statement.close();
	                }
	                if (results != null) {
	                    results.close();
	                }
	            } 
	            catch (Exception e) {
                    LOG.error("DB tidy failed  - ", e);
	                ; // Nothing to be done!
	            }
	        }
	        
	        if (dbEmpty) {
	            //
	            // Only allow users in if they have a column in the db
	            //
	            LOG.debug("Authorization failed " + userName + " not in table");
	            throw new LoginException("Authorization failed - not in table");
	        }
	        
	        if (usePass) {
	            //
	            // password check
	            //
	            if (!password.equals(dbPass)) {
                    LOG.debug("Authorization failed " + userName + " bad password");
	                throw new LoginException("Authorization failed - bad password");                
	            }
	            //
	            // All OK
	            //
	            LOG.debug("DB Password check succeeded");
	            return true;
	        } 
	        //
	        // Otherwise use kerberos for login
	        //
	        LOG.debug("Passing user to kerberos ");
	        calledKerberos = true;
	        try {
		        return kerberos.login(); 			
			} catch (LoginException e) {
            	LOG.debug("kerberos failed", e);
            	throw e;
			}
	    }

	    public boolean logout() throws LoginException {
	        return kerberos.logout();
	    }
	    
	    private static class MyPrincipal implements Principal {

	    	private String name;
	    	protected MyPrincipal(String princ) {
	    		name = princ;
	    	}

			public String getName() {
				return name;
			}
	    }
	}
