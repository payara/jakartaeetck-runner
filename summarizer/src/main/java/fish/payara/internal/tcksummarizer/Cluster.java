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

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

public class Cluster {
    final TestCase lead;
    final List<TestCase> similar;

    Cluster(TestCase lead, List<TestCase> similar) {
        this.lead = lead;
        this.similar = similar;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(">> Cluster of ").append(similar.size()+1).append(" cases.")
         .append("Leading test case: ").append(lead)
                .append("\nLog:\n").append(lead.log)
                .append("\nSimilar testcases:");

        similar.forEach(testCase -> sb.append("\n  ").append(testCase));

        return sb.toString();
    }

    public Stream<TestCase> stream() {
        return Stream.concat(Stream.of(lead),similar.stream());
    }

    static List<Cluster> makeClusters(List<TestCase> cases, double threshold) {
        List<TestCase> candidates = new ArrayList<>(cases);
        List<Cluster> clusters = new ArrayList<>();
        while (!candidates.isEmpty()) {
            TestCase lead = candidates.remove(0);
            double[] similarities = candidates.stream().parallel()
                    .mapToDouble(testCase -> lead.getVector().cosineSimilarity(testCase.getVector()))
                    .toArray();
            List<TestCase> similar = new ArrayList<>();
            int offset = 0;
            for(int i=0; i<similarities.length; i++) {
                if (similarities[i] >= threshold) {
                    similar.add(candidates.remove(i-offset));
                    offset++;
                }
            }
            clusters.add(new Cluster(lead, similar));
        }
        return clusters;
    }


}
