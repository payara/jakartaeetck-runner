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

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.Comparator;
import java.util.Map;
import java.util.TreeMap;
import java.util.function.Consumer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class LogCorrelator {
    final TreeMap<ZonedDateTime, TestCase> byStartTime = new TreeMap<>();
    private TestCase target;

    LogCorrelator(Iterable<TestCase> testCases) {
        for (TestCase testCase : testCases) {
            Map.Entry<ZonedDateTime, TestCase> previous = byStartTime.floorEntry(testCase.start);
            if (previous != null && previous.getValue().end.isAfter(testCase.start)) {
                throw new IllegalArgumentException(testCase + " overlaps with "+previous.getValue());
            }
            byStartTime.put(testCase.start, testCase);
        }
    }

    private Consumer<String> handler = this::expectStart;

    void handleLine(String line) {
        handler.accept(line);
    }

    static Pattern ENTRY_START = Pattern.compile("^\\[([\\d:T+-.]+)].+\\[\\[$");

    static DateTimeFormatter LOG_TIMESTAMP = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSX");

    private void expectStart(String line) {
        Matcher m = ENTRY_START.matcher(line);
        if (m.matches()) {
            ZonedDateTime timestamp = ZonedDateTime.parse(m.group(1), LOG_TIMESTAMP);
            if (target == null) {
                Map.Entry<ZonedDateTime, TestCase> candidate = byStartTime.floorEntry(timestamp);
                if (candidate != null) {
                    target = candidate.getValue();
                }
            }
            if (target != null && timestamp.isAfter(target.end)) {
                target = null;
            }
            handler = this::body;
            body(line);
        }
    }

    private void body(String line) {
        if (target != null) {
            target.appendServerLog(line);
        }
        if (line.endsWith("]]")) {
            handler = this::expectStart;
        }
    }

    private void readFile(Path path) {
        try {
            handler = this::expectStart;
            Files.lines(path)
                    .forEach(this::handleLine);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    static void correlate(Collection<TestCase> testCases, String logPath) throws IOException {
        LogCorrelator correlator = new LogCorrelator(testCases);
        sortedLogs(logPath)
                .forEach(correlator::readFile);
    }

    protected static Stream<Path> sortedLogs(String logPath) throws IOException {
        return Files.list(Paths.get(logPath)).filter(p -> p.getFileName().toString().startsWith("server.log"))
                .sorted(SERVER_LOG_LAST.thenComparing(Comparator.naturalOrder()));
    }

    static Comparator<Path> SERVER_LOG_LAST = (p1, p2) -> {
        if (p1.getFileName().startsWith("server.log")) {
            return 1;
        } else if (p2.getFileName().startsWith("server.log")) {
            return -1;
        } else {
            return 0;
        }
    };

}
