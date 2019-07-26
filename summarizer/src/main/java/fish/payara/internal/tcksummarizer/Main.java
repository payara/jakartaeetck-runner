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
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collections;
import java.util.List;


public class Main {
    private final String path;
    private final double threshold;
    private final String serverLogs;
    private TestReport report;
    private List<Cluster> clusters;

    public Main(String path, double threshold, String serverLogs) {
        this.path = path;
        this.threshold = threshold;
        this.serverLogs = serverLogs;
    }

    private void process() throws IOException, ParserConfigurationException, SAXException {
        System.out.println("Parsing jUnit report");
        report = JUnitReportParser.parse(new InputSource(new FileInputStream(path)));
        if (serverLogs != null) {
            System.out.println("Parsing server logs");
            LogCorrelator.correlate(report.cases, serverLogs);
        }
        System.out.println("Correlating failures");
        clusters = Cluster.makeClusters(report.cases, threshold);
    }

    public static void main(String... args) throws IOException, ParserConfigurationException, SAXException {
        if (args.length < 1 && args.length > 3) {
            System.out.println("Usage: -jar ... <tck junit report file> [<similarity threshold>] [<server log directory>]");
        }
        double threshold=0.96;
        String serverLogs = null;
        if (args.length == 2) {
            try {
                threshold = Double.parseDouble(args[1]);
            } catch (NumberFormatException nfe) {
                serverLogs = args[1];
            }
        }
        if (args.length == 3) {
            threshold = Double.parseDouble(args[1]);
            serverLogs = args[2];
        }
        String path = args[0];
        Main main = new Main(path, threshold, serverLogs);
        main.process();
        main.writeLogs();
        main.print();

    }

    private Path output() {
        return Paths.get("summary-"+report.name+"-"+report.timestamp.replaceAll(":","")+"/");
    }

    private void writeLogs() throws IOException {
        System.out.println("Writing out logs");
        Path outDir = output().resolve("logs/");
        Files.createDirectories(outDir);

        clusters.stream()
                .forEach(cluster -> writeClusterLogs(outDir, cluster));
    }

    private void writeClusterLogs(Path parentDir, Cluster cluster) {
        Path outDir = parentDir.resolve(cluster.lead.toString());
        try {
            Files.createDirectories(outDir);
            cluster.stream().parallel().forEach(testCase -> writeLog(outDir, testCase));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private static void writeLog(Path outDir, TestCase testCase) {
        try {
            if (testCase.hasServerLog()) {
                Files.write(outDir.resolve(testCase.toString() + ".serverlog"),
                        Collections.singleton(testCase.serverLog));
            }
            Files.write(outDir.resolve(testCase.toString()+".jtrlog"),
                    Collections.singleton(testCase.log));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void print() throws IOException {
        Path outPath = output().resolve("_summary.txt");
        try (PrintWriter out = new PrintWriter(Files.newBufferedWriter(outPath,StandardCharsets.UTF_8))) {
            out.println("TCK Failure summary\t" + path);
            out.println("Number of failures:\t" + report.cases.size());
            out.println("Number of clusters:\t" + clusters.size());
            out.println();
            out.println("Lead case\tNumber of similar");
            clusters.forEach(cluster -> out.println(cluster.lead + "\t" + cluster.similar.size()));
            out.println(" ---- End of summary. Now boring details ----");
            clusters.forEach(out::println);
        }
    }

}
