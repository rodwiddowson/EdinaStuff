<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
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
  <div class="readeronly">
    <p><a href="#maincontent">Skip to content</a></p>
  </div><!--/readeronly-->
  <!--THESE 3 DIVS PROVIDE THE DROP SHADOW-->
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

	<div id="idp">
	    <table border="0" cellpadding="2" cellspacing="5">
		<tr><td colspan="2">
			<h1>EDINA Identity Provider Login</h1>
		</td></tr>

		<tr><td colspan="2">
		<p>(The EDINA Identity Provider is for use by EDINA staff, for use on EDINA training courses 
			and to access EDINA services by others allocated EDINA trial logins)</p>
		</td></tr>

            <% if ("true".equals(request.getAttribute("loginFailed"))) { %>
		<tr><td colspan="2">
     			<h2><font color="red"> Credentials not recognized. </font> </h2>
		</td></tr>

		<% } %>
		
             <tr><td colspan="2">
	 	 <h2>EDINA staff, please use your EASE Credentials; 
       	         Others, please use the credentials provided by EDINA</h2>	
		</td></tr>
	    </table>

		<% if(request.getAttribute("actionUrl") != null){ %>
	 	   <form action="<%=request.getAttribute("actionUrl")%>" method="post">
		<% }else{ %>
		    <form action="j_security_check" method="post">
		<% } %>

 	    <table border="0" cellpadding="2" cellspacing="5">
		<tr>
			<td>Username:</td>
			<td><input name="j_username" type="text" tabindex="1" /></td>
		</tr>
		<tr>
			<td>Password:</td>
			<td><input name="j_password" type="password" tabindex="2" /></td>
		</tr>
		<tr>
			<td rowspan="2"><input type="submit" value="Login" tabindex="3" /></td>
		</tr>
            <tr>
               <td colspan="2">
                 <input type="checkbox" name="resetuserconsent" value="true" />
                 Reset my attribute release approvals
               </td>
            </tr>
	</table>
	</form>
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


