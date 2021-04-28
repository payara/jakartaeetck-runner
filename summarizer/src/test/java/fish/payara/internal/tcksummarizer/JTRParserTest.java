/*
 *    DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
 *
 *    Copyright (c) [2019] Payara Foundation and/or its affiliates. All rights reserved.
 *
 *    The contents of this file are subject to the terms of either the GNU
 *    General Public License Version 2 only ("GPL") or the Common Development
 *    and Distribution License("CDDL") (collectively, the "License").  You
 *    may not use this file except in compliance with the License.  You can
 *    obtain a copy of the License at
 *    https://github.com/payara/Payara/blob/master/LICENSE.txt
 *    See the License for the specific
 *    language governing permissions and limitations under the License.
 *
 *    When distributing the software, include this License Header Notice in each
 *    file and include the License file at glassfish/legal/LICENSE.txt.
 *
 *    GPL Classpath Exception:
 *    The Payara Foundation designates this particular file as subject to the "Classpath"
 *    exception as provided by the Payara Foundation in the GPL Version 2 section of the License
 *    file that accompanied this code.
 *
 *    Modifications:
 *    If applicable, add the following below the License Header, with the fields
 *    enclosed by brackets [] replaced by your own identifying information:
 *    "Portions Copyright [year] [name of copyright owner]"
 *
 *    Contributor(s):
 *    If you wish your version of this file to be governed by only the CDDL or
 *    only the GPL Version 2, indicate your decision by adding "[Contributor]
 *    elects to include this software in this distribution under the [CDDL or GPL
 *    Version 2] license."  If you don't indicate a single choice of license, a
 *    recipient has the option to distribute your version of this file under
 *    either the CDDL, the GPL Version 2 or to extend the choice of license to
 *    its licensees as provided above.  However, if you add GPL Version 2 code
 *    and therefore, elected the GPL Version 2 license, then the option applies
 *    only if the new code is made subject to such option by the copyright
 *    holder.
 */

package fish.payara.internal.tcksummarizer;

import org.junit.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import static org.assertj.core.api.Assertions.assertThat;


public class JTRParserTest {
    static final String INPUT1="#-----testresult-----\n" +
            "description=file\\:/home/ubuntu/tck/cts_home/jakartaeetck/src/com/sun/ts/tests/ejb/ee/bb/localaccess/mdbqaccesstest/MDBClient.java\\#test2\n" +
            "end=Mon Jul 22 15\\:01\\:50 UTC 2019\n" +
            "environment=ts_unix\n" +
            "execStatus=Failed. Test case throws exception\\: com.sun.ts.lib.harness.EETest$Fault\\: Setup failed\\:\n" +
            "sections=script_messages Deployment TestRun\n" +
            "start=Mon Jul 22 15\\:01\\:42 UTC 2019\n" +
            "test=com/sun/ts/tests/ejb/ee/bb/localaccess/mdbqaccesstest/MDBClient.java\\#test2\n" +
            "timeoutSeconds=1200\n" +
            "totalTime=7997\n" +
            "work=/home/ubuntu/tck/cts_home/jakartaeetck-work/ejb/com/sun/ts/tests/ejb/ee/bb/localaccess/mdbqaccesstest\n" +
            "\n" +
            "#section:script_messages\n" +
            "----------messages:(0/0)----------\n" +
            "\n" +
            "#section:Deployment\n" +
            "----------messages:(0/0)----------\n" +
            "----------log:(23/1515)----------\n" +
            "Undeploying apps...\n" +
            "AutoDeployment.isDeployed()\n" +
            "result: Passed. Deployment phase completed. However, check the output above to see if actual deployment passed or failed.\n" +
            "\n" +
            "#section:TestRun\n" +
            "----------messages:(1/5091)----------\n" +
            "command: com.sun.ts.lib.harness.ExecTSTestCmd DISPLAY=:0.0 HOME=/home/ubuntu LD_LIBRARY_PATH=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/lib TMP= windir= SYSTEMROOT= PATH=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/nativelib APPCPATH=/home/ubuntu/tck/cts_home/jakartaeetck/bin/xml/../../lib/tsharness.jar:/home/ubuntu/tck/cts_home/jakartaeetck/bin/xml/../../lib/cts.jar:/home/ubuntu/tck/cts_home/vi/payara6/glassfish/lib/jpa_alternate_provider.jar:/home/ubuntu/tck/cts_home/jakartaeetck/bin/xml/../../lib/tssv.jar:/home/ubuntu/tck/cts_home/vi/payara6/glassfish/modules/weld-osgi-bundle.jar:/home/ubuntu/tck/cts_home/vi/payara6/glassfish/modules/cdi-api.jar TZ=US/Eastern /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java -Djava.system.class.loader=org.glassfish.appclient.client.acc.agent.ACCAgentClassLoader -Djava.security.policy=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/lib/appclient/client.policy -Dcts.tmp=/home/ubuntu/tck/cts_home/jakartaeetck/bin/xml/../../tmp -Djava.security.auth.login.config=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/lib/appclient/appclientlogin.conf -Djava.protocol.handler.pkgs=javax.net.ssl -Dcom.sun.enterprise.home=/home/ubuntu/tck/cts_home/vi/payara6/glassfish -Djavax.net.ssl.keyStore=/home/ubuntu/tck/cts_home/jakartaeetck/bin/xml/../../bin/certificates/clientcert.jks -Djavax.net.ssl.keyStorePassword=changeit -Dcom.sun.aas.installRoot=/home/ubuntu/tck/cts_home/vi/payara6/glassfish -Dcom.sun.aas.imqLib=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/../mq/lib -Djavax.net.ssl.trustStore=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/domains/domain1/config/cacerts.jks -Djava.endorsed.dirs=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/modules/endorsed -Djavax.xml.parsers.SAXParserFactory=com.sun.org.apache.xerces.internal.jaxp.SAXParserFactoryImpl -Djavax.xml.parsers.DocumentBuilderFactory=com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderFactoryImpl -Djavax.xml.transform.TransformerFactory=com.sun.org.apache.xalan.internal.xsltc.trax.TransformerFactoryImpl -Dorg.xml.sax.driver=com.sun.org.apache.xerces.internal.parsers.SAXParser -Dorg.xml.sax.parser=org.xml.sax.helpers.XMLReaderAdapter -Doracle.jdbc.J2EE13Compliant=true -Doracle.jdbc.mapDateToTimestamp -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Djava.security.manager -Dstartup.login=false -Dauth.gui=false -Dlog.file.location=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/domains/domain1/logs -Dri.log.file.location=/home/ubuntu/tck/cts_home/ri/glassfish5/glassfish/domains/domain1/logs -DwebServerHost.2=localhost -DwebServerPort.2=8002 -Dprovider.configuration.file=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/domains/domain1/config/ProviderConfiguration.xml -Djava.security.properties=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/domains/domain1/config/ts.java.security -Djava.ext.dirs=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/lib/jdbcdrivers:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext:/usr/lib/jvm/java-8-openjdk-amd64/jre/jre/lib/ext:/home/ubuntu/tck/cts_home/vi/payara6/glassfish/lib/jdbcdrivers:/home/ubuntu/tck/cts_home/vi/payara6/glassfish/javadb/lib -Dcom.sun.aas.configRoot=/home/ubuntu/tck/cts_home/vi/payara6/glassfish/config -Ddeliverable.class=com.sun.ts.lib.deliverable.cts.CTSDeliverable -javaagent:/home/ubuntu/tck/cts_home/vi/payara6/glassfish/lib/gf-client.jar=arg=-configxml,arg=/home/ubuntu/tck/cts_home/jakartaeetck/bin/xml/../../tmp/appclient/s1as.sun-acc.xml,client=jar=/home/ubuntu/tck/cts_home/jakartaeetck/bin/xml/../../dist/com/sun/ts/tests/ejb/ee/bb/localaccess/mdbqaccesstest/ts_dep/bb_localaccess_mdbqaccesstestClient.jar,arg=-name,arg=bb_localaccess_mdbqaccesstest_client -jar /home/ubuntu/tck/cts_home/jakartaeetck/bin/xml/../../dist/com/sun/ts/tests/ejb/ee/bb/localaccess/mdbqaccesstest/ts_dep/bb_localaccess_mdbqaccesstestClient.jar -ap /home/ubuntu/tck/cts_home/jakartaeetck/bin/xml/../../bin/tssql.stmt -p /home/ubuntu/tck/cts_home/jakartaeetck/bin/xml/../../tmp/tstest.jte -t test2\n" +
            "----------log:(321/28138)----------\n" +
            "Jul 22, 2019 11:01:44 AM org.glassfish.enterprise.iiop.api.GlassFishORBHelper postConstruct\n" +
            "INFO: GlassFishORBFactory service initialized.";

    enum Level {
        SECTION,
        SUBSECTION,
        LINE
    }

    static class Line {
        Level level;
        String line;

        Line(Level level, String line) {
            this.level = level;
            this.line = line;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            Line line1 = (Line) o;
            return level == line1.level &&
                    Objects.equals(line, line1.line);
        }

        @Override
        public int hashCode() {
            return Objects.hash(level, line);
        }
    }

    static class CollectingHandler implements JTRParser.Handler {


        List<Line> lines = new ArrayList<>();

        @Override
        public void start() {

        }

        @Override
        public void startSection(String sectionLine) {
            lines.add(new Line(Level.SECTION, sectionLine));
        }

        @Override
        public void startSubsection(String subsectionLine) {
            lines.add(new Line(Level.SUBSECTION, subsectionLine));
        }

        @Override
        public void line(String line) {
            lines.add(new Line(Level.LINE, line));
        }

        @Override
        public void finish() {

        }
    }

    @Test
    public void smokeTest() {
        CollectingHandler handler = new CollectingHandler();
        JTRParser parser = new JTRParser(handler);
        parser.parse(INPUT1);

        int deploymentIndex = handler.lines.indexOf(new Line(Level.SECTION, "section:Deployment"));
        assertThat(deploymentIndex).isGreaterThan(0);
        assertThat(handler.lines.get(deploymentIndex+1)).isEqualTo(new Line(Level.SUBSECTION, "messages:(0/0)"));
    }
}
