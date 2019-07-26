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

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import java.io.IOException;

import static fish.payara.internal.tcksummarizer.XmlHandler.Element;
import static fish.payara.internal.tcksummarizer.XmlHandler.ElementHandler;
import static fish.payara.internal.tcksummarizer.XmlHandler.process;
import static fish.payara.internal.tcksummarizer.XmlHandler.when;

public class JUnitReportParser  {
    final TestReport report = new TestReport();
    private final XmlHandler handler;


    JUnitReportParser() {
        this.handler = new XmlHandler(when("testsuite", this::initSuite));
    }

    private ElementHandler initSuite(Element testsuite) {
        report.name = testsuite.attributes.getValue("name");
        report.timestamp = testsuite.attributes.getValue("timestamp");
        return when("testcase", this::startTestCase);
    }

    private ElementHandler startTestCase(Element testCase) {
        if (!"Passed".equals(testCase.attributes.getValue("status"))) {
            TestCase currentTestcase = new TestCase(testCase.attributes);

            return new ElementHandler() {
                @Override
                protected ElementHandler started(Element element) {
                    switch (element.qName) {
                        case "failure":
                            return process((el) -> currentTestcase.failure = el.getText());
                        case "system-out":
                            return process((el) -> currentTestcase.parseOutput(el.getText()));
                        default:
                            return null;
                    }
                }

                @Override
                protected void finished(Element element) {
                    report.cases.add(currentTestcase);
                }
            };
        } else {
            return null;
        }
    }

    static TestReport parse(InputSource source) throws SAXException, IOException, ParserConfigurationException {
        SAXParserFactory factory = SAXParserFactory.newInstance();
        SAXParser parser = factory.newSAXParser();
        JUnitReportParser handler = new JUnitReportParser();
        parser.parse(source, handler.handler);
        return handler.report;
    }
}
