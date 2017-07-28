<%--
    Document   : index
    Created on : Dec 21, 2015, 4:33:25 PM
    Author     : bruno
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Set"%>
<%@page import="weblogic.management.runtime.ServerRuntimeMBean"%>
<%@page import="java.net.UnknownHostException"%>
<%@page import="java.net.InetAddress"%>
<%@page import="weblogic.management.*"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.File"%>
<%@page import="java.io.FileNotFoundException"%>
<%@page import="java.util.Scanner"%>
<%@page import="java.util.List"%>

<%@ page language="java" import="java.sql.*" %>

<%!public static String getIpAddOfCurrSrv() {
        ServerRuntimeMBean serverRuntime = null;
        Set mbeanSet = null;
        Iterator mbeanIterator = null;
        String ipAddress = "";
        String adminServerUrl = "t3://localhost:7001";
        try {
            MBeanHome mBeanHome = null;
            mBeanHome = Helper.getAdminMBeanHome("weblogic", "welcome1", adminServerUrl);
            mbeanSet = mBeanHome.getMBeansByType("ServerRuntime");
            if (mbeanSet != null) {
                mbeanIterator = mbeanSet.iterator();
                while (mbeanIterator.hasNext()) {
                    serverRuntime = (ServerRuntimeMBean) mbeanIterator.next();
                    if (serverRuntime != null) {
                        ipAddress = serverRuntime.getURL("HTTP");
                        return ipAddress;
                    }
                }
            }
        } catch (Exception e) {
        }
        return ipAddress;
    }
%>

<%
    String hostname, serverAddress;
    hostname = "error";
    serverAddress = "error";
    try {
        InetAddress inetAddress;
        inetAddress = InetAddress.getLocalHost();
        hostname = inetAddress.getHostName();
        serverAddress = inetAddress.toString();
    } catch (UnknownHostException e) {
        e.printStackTrace();
    }
%>

<%!public static String dbpasswd; {
    try {
        dbpasswd = new Scanner(new File("/run/secrets/oracledb_passwd")).useDelimiter("\\Z").next();
     } catch (FileNotFoundException e) {
        e.printStackTrace();
     }
 }
%>

<%! private String runQuery(String dbpasswd) throws SQLException {
     Connection conn = null;
     Statement stmt = null;
     ResultSet rset = null;
     try {
        DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
        conn = DriverManager.getConnection("jdbc:oracle:thin:@oracledb:1521:ORCL",
                                           "system", dbpasswd);
        stmt = conn.createStatement();
        // dynamic query
        rset = stmt.executeQuery ("SELECT * FROM v$version");
       return (formatResult(rset));
     } catch (SQLException e) {
         return ("<P> SQL error: <PRE> " + e + " </PRE> </P>\n");
     } finally {
         if (rset!= null) rset.close();
         if (stmt!= null) stmt.close();
         if (conn!= null) conn.close();
     }
  }
  private String formatResult(ResultSet rset) throws SQLException {
    StringBuffer sb = new StringBuffer();
    if (!rset.next())
      sb.append("<P> No matching rows.<P>\n");
    else {  sb.append("<UL>");
            do {  sb.append("<LI>" + rset.getString(1));
            } while (rset.next());
           sb.append("</UL>");
    }
    return sb.toString();
  }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Docker JSP Page</title>
	<style>
	body
	{
	color:lightgrey;
	font-family: courier;
	text-align: center;
	}
	ul{
    	list-style:none;
    	position:relative;
	font-size:12px;
	}
	</style>
    </head>
    <body bgcolor="#2F4F4F">
        <center> <img src="whale.png" height="50" width="71"> </center>
	<hr>
        <h1>WebLogic on Docker - Request Information</h1>
	<h2> Request served by container: <%=hostname%></h2>
	<center>
	<table border="1">
	<td>
	<ul>
            <br>getVirtualServerName(): <%= request.getServletContext().getVirtualServerName() %>
            <br>InetAddress.hostname: <%=hostname%>
            <br>InetAddress.serverAddress: <%=serverAddress%>
            <br>getLocalAddr(): <%=request.getLocalAddr()%>
            <br>getLocalName(): <%=request.getLocalName()%>
            <br>getLocalPort(): <%=request.getLocalPort()%>
            <br>getServerName(): <%=request.getServerName()%>
            <br>WLS Server Name: <%=System.getProperty("weblogic.Name")%>
            <br>getIpAddOfCurrSrv(): <%=getIpAddOfCurrSrv()%>
	    <br>
	    <br>
	</ul>
	</td>
	</table>
               <H2> Database query result:  </H2>
        <table border="1">
        <td>
        <br>
       <% String searchCondition = request.getParameter("cond");
               if (searchCondition == null) { %>
                <%= runQuery(dbpasswd) %>  <BR>
        <% }  %>
        </td>
        </table>
	</center>
    </body>
</html>
