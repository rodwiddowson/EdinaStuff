<%@ page import="edu.internet2.middleware.shibboleth.common.relyingparty.RelyingPartyConfigurationManager" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.authn.LoginContext" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.session.*" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.util.HttpServletHelper" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="javax.xml.namespace.QName" %>

<%@ page import="org.opensaml.saml2.metadata.*" %>
<%@ page import="org.opensaml.saml2.common.Extensions" %>
<%@ page import="org.opensaml.saml2.core.*" %>
<%@ page import="org.opensaml.xml.XMLObject" %>
<%@ page import="org.opensaml.xml.schema.XSAny" %>
<%@ page import="org.opensaml.xml.util.AttributeMap" %>

<%
    LoginContext loginContext = HttpServletHelper.getLoginContext(HttpServletHelper.getStorageService(application),
                                                                  application, request);
    Session userSession = HttpServletHelper.getUserSession(request);
    RelyingPartyConfigurationManager rpConfigMngr = HttpServletHelper.getRelyingPartyConfirmationManager(application);
    EntityDescriptor entity = HttpServletHelper.getRelyingPartyMetadata(loginContext.getRelyingPartyId(), rpConfigMngr);
    Extensions exts = entity.getExtensions();
    List<Attribute> attributes = null;
    QName entityAttributes = new QName("urn:oasis:names:tc:SAML:metadata:attribute", "EntityAttributes");
    String descriptionName = "urn:oasis:names:tc:SAML:metadata:attribute:ui:description";
    String logoName = "urn:oasis:names:tc:SAML:metadata:attribute:ui:logo";
    
    String description = "A service that you tried to access requires authentication and you have been directed to" +
                         " this site which should be your home site.  The service you are trying to use has not set " +
                         "a description";
                         
    String imageUrl = request.getContextPath() + "/images/internet2.gif"; 
    
    String css = request.getContextPath() + "/fedui.css";
    
    
    if (null != exts) {
	    List<XMLObject> children = exts.getOrderedChildren();
	    for (XMLObject o : children) {
	        if (entityAttributes.equals(o.getElementQName())) {
	        	List<XMLObject> potentialAttrs = o.getOrderedChildren();
	        	attributes = new ArrayList<Attribute>(potentialAttrs.size());
	        	for (XMLObject pa : potentialAttrs ) {
		        	if (pa instanceof Attribute) {
		        		Attribute a = (Attribute) pa;
		        		attributes.add(a);
		        		
		        		if (descriptionName.equals(a.getName())) {
		        			List<XMLObject> attrValues = a.getAttributeValues();
		        			for (XMLObject attrValue: attrValues) {
		        				if (attrValue instanceof XSAny) {
									description = ((XSAny)attrValue).getTextContent();
									break;
								}
							}
						} else if (logoName.equals(a.getName())){
							List<XMLObject> attrValues = a.getAttributeValues();
							for (XMLObject attrValue: attrValues) {
								if (attrValue instanceof XSAny) {
									imageUrl = ((XSAny)attrValue).getTextContent();
								}
							}
						}
	        		}
	        	}
        	}	
	    }
	}
%>

<html>

    <head>
        <link rel="stylesheet" type="text/css" href="<%= css %>">
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>EDINA IdP</title>
        <link rel="stylesheet" href="http://edina.ac.uk/styles/main.css" type="text/css" />
  <!--
        IMPORTANT: RETAIN THE FOLLOWING CONDITIONAL COMMENTED STYLES 
    -->
  <!--[if IE]>
    <link rel="stylesheet" href="http://edina.ac.uk/styles/iestyles/ieall.css" />
    <![endif]-->
  <!--[if lt IE 7]>
    <link rel="stylesheet" href="http://edina.ac.uk/styles/iestyles/ieolder.css" />
    <![endif]-->
  <!--[if IE 7]>
    <link rel="stylesheet" href="http://edina.ac.uk/styles/iestyles/ie7.css" />
    <![endif]-->


    </head>

	<body id="homepage">

<div id="extra1">
    <div id="extra2">
      <div id="extra3">

        <div id="container" class="clearfix">
          <div id="banner">
            <h1><img src="http://edina.ac.uk/images/homepagebannerlogo.png" alt="EDINA" /></h1>
            <p class="readeronly">Providing resources for staff and students in higher<br />
            and further education in the UK and beyond.</p>
          </div><!--/banner-->
          <div id="pagetop">
            <div id="mainmenu">

              <h2 class="readeronly">Main menu</h2>
              <ul>
                <li><a href="http://edina.ac.uk/support/">Help &amp; Support</a></li>
                <li><a href="http://edina.ac.uk/about/">About</a></li>
                <li><a href="http://edina.ac.uk/feedback.html">Feedback</a></li>
                <li><a href="http://edina.ac.uk/about/contact.html">Contact</a></li>
              </ul>

            </div><!--/mainmenu"-->
          </div><!--/pagetop-->

		<div class="fedui">
			<div class="fcontainer">
				<div class="leftpane">
					<div class="content">
<p>The web site described to the right has asked you to log in and you have chosen EDINA as your home institution</p>
						<% if ("true".equals(request.getAttribute("loginFailed"))) { %>
						    <p><font color="red"> Credentials not recognized. </font> </p>
						<% } %>
						<% if(request.getAttribute("actionUrl") != null){ %>
						    <form action="<%=request.getAttribute("actionUrl")%>" method="post">
					        <% }else{ %>
						    <form action="j_security_check" method="post">
						<% } %>

                                                   <table>
				    		   <tr><td width="40%"><label for="username">Username:</label></td><td><input name="j_username" type="text" /></td></tr>								
						   <tr><td><label for="password">Password:</label></td><td><input name="j_password" type="password" /></td></tr>
						   <tr><td></td><td><button type="submit" value="Login" >Continue</button></td></tr>
</table>
					        </form>
					</div>
				</div>
				<div class="rightpane">
					<div class="content">
						<img src="<%=imageUrl%>" class="splogo" /><br/>
							<p><%=description%></p>
					</div>
				</div>
			</div>
		</div>
		          <div id="footer">
            <div id="footerparas">
              <p><a href="http://edina.ac.uk/about/where.html">EDINA is a JISC National Data Centre based at the University of Edinburgh</a><img src="http://edina.ac.uk/images/pipe.gif" alt="" /></p>
              <p><a href="http://edina.ac.uk/accessibility.html">Accessibility</a><img src="http://edina.ac.uk/images/pipe.gif" alt="" /></p>
              <p><a href="http://edina.ac.uk/acknowledgements.html">Acknowledgements</a></p>
              <p id="jisclogo"><a title="This link opens a new browser window." target="_blank" href="http://www.jisc.ac.uk/"><img src="http://edina.ac.uk/images/jisc_logo.gif" alt="JISC" /></a></p>

            </div><!--/footerparas-->
          </div><!--/footer-->
        </div><!--/container-->
      </div><!--/extra3-->
    </div><!--/extra2-->
  </div><!--/extra1-->

	</body>
	
</html>