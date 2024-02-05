package edu.ucdenver.ccp.PhenoGen.web;


import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.ServletConfig;



/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling global beans for syncronizing memory/cpu intensive processes.
 *
 * @author Spencer Mahaffey
 */

public class PhenoGenServletContextListener implements ServletContextListener {

    @Override
    public void contextDestroyed(ServletContextEvent arg0) {
        System.out.println("ServletContextListener destroyed");
    }

    //Run this before web application is started
    @Override
    public void contextInitialized(ServletContextEvent arg0) {
        List threadList = Collections.synchronizedList(new ArrayList<Thread>());
        arg0.getServletContext().setAttribute("threadList", threadList);
        System.out.println("ServletContextListener started");
    }
}



