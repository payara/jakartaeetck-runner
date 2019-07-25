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
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.List;


public class Main {
    private final String path;
    private final double threshold;
    private TestReport report;
    private List<Cluster> clusters;

    public Main(String path, double threshold) {
        this.path = path;
        this.threshold = threshold;
    }

    private void process() throws IOException, ParserConfigurationException, SAXException {
        report = JUnitReportParser.parse(new InputSource(new FileInputStream(path)));
        clusters = Cluster.makeClusters(report.cases, threshold);
    }

    public static void main(String... args) throws IOException, ParserConfigurationException, SAXException {
        if (args.length < 1 && args.length > 2) {
            System.out.println("Usage: -jar ... <tck junit report file> <similarity threshold>");
        }
        double threshold=0.96;
        if (args.length == 2) {
            threshold = Double.parseDouble(args[1]);
        }
        String path = args[0];
        Main main = new Main(path, threshold);
        main.process();
        main.print();
    }

    private void print() {
        System.out.println("TCK Failure summary\t"+path);
        System.out.println("Number of failures:\t"+report.cases.size());
        System.out.println("Number of clusters:\t"+clusters.size());
        System.out.println();
        System.out.println("Lead case\tNumber of similar");
        clusters.forEach(cluster -> System.out.println(cluster.lead+"\t"+cluster.similar.size()));
        System.out.println(" ---- End of summary. Now boring details ----");
        clusters.forEach(System.out::println);
    }

    private static void printSummary(List<TestCase> cases, List<Cluster> clusters) {
    }
}
