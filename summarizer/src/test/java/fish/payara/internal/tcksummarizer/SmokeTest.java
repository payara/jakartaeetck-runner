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

import org.junit.BeforeClass;
import org.junit.Test;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class SmokeTest {
    static TestReport report;

    @BeforeClass
    public static final void parse() throws IOException, ParserConfigurationException, SAXException {
        report = JUnitReportParser.parse(new InputSource(new FileInputStream("src/test/sample/ejb-junit-report.xml")));

    }

    @Test
    public void parserSmokeTest() throws IOException, ParserConfigurationException, SAXException {
        assertEquals(185, report.cases.size());

        TestCase first = report.cases.get(0);
        assertEquals(10, first.time.intValue());
        assertEquals("com.sun.ts.tests.ejb.ee.bb.localaccess.mdbqaccesstest.MDBClient", first.className);
        assertEquals("test1", first.name);
        assertThat(first.failure).contains("com.sun.ts.lib.harness.EETest$Fault: Setup failed");
        assertThat(first.output).contains("----------log:");

        Optional<TestCase> notBroker = report.cases.stream().filter(testCase -> !testCase.output.contains("com.sun.messaging.jms.JMSSecurityException")).findAny();
        assertFalse(notBroker.isPresent());
    }

    @Test
    public void prefixTreeSmokeTest() throws IOException, ParserConfigurationException, SAXException {

        PrefixTree packages = new PrefixTree();
        report.cases.stream().map(testCase -> testCase.className.split("\\.")).forEach(packages::add);

        System.out.println(packages.repr(false));
    }



    @Test
    public void cosineSmokeTest() throws IOException, ParserConfigurationException, SAXException {

        TermVector firstTermVector = report.cases.get(0).getVector();

        double[] similarities = report.cases.stream().skip(1).mapToDouble(testCase -> firstTermVector.cosineSimilarity(testCase.getVector())).toArray();
        System.out.println(Arrays.toString(similarities));
    }

    @Test
    public void clusteringSmokeTest() {
        List<Cluster> clusters = Cluster.makeClusters(report.cases, 0.96);
        clusters.forEach(System.out::println);
    }

    @Test
    public void correlationSmokeTest() throws IOException, ParserConfigurationException, SAXException {
        TestReport report2 = JUnitReportParser.parse(new InputSource(new FileInputStream("src/test/sample/ejb-junit-report-2.xml")));
        LogCorrelator.correlate(report2.cases, "src/test/sample/logs");

        TestCase matchedCase = report2.cases.stream().filter(c -> c.name.equals("cancelAndRollbackSingleEventTest")
                && c.className.equals("com.sun.ts.tests.ejb.ee.timer.mdb.Client")).findAny().get();
        StringBuilder serverLog = matchedCase.serverLog;
        assertThat(serverLog.length() > 0);
        System.out.println(matchedCase.start);
        System.out.println(matchedCase.end);

        System.out.println(serverLog.subSequence(0,serverLog.indexOf("]]")+2));
        System.out.println("---");
        System.out.println(serverLog.subSequence(serverLog.lastIndexOf("[2019"), serverLog.length()));
    }
}
