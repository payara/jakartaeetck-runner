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

import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class TermVector {
    private final double norm;
    private final double size;
    private TreeMap<String,Integer> terms = new TreeMap<>();

    public TermVector(String... terms) {
        this(Arrays.asList(terms));
    }

    public TermVector(Collection<String> terms) {
        add(terms);
        size = terms.size();
        norm = Math.sqrt(this.terms.values().stream().mapToDouble(this::weight).map(i -> i*i).sum());
    }

    private void add(Collection<String> terms) {
        int size = terms.size();
        for (String term : terms) {
            this.terms.compute(term, (t, old) -> old == null ? 1 : old+1);
        }
    }

    private double weight(Integer occurences) {
        return occurences/size;
    }

    double dotProduct(TermVector other) {
        double product = 0;
        Iterator<Map.Entry<String, Integer>> otherEntries = other.terms.entrySet().iterator();
        Map.Entry<String, Integer> otherEntry=null;
        for (Map.Entry<String, Integer> thisEntry : terms.entrySet()) {
            while ((otherEntry == null || otherEntry.getKey().compareTo(thisEntry.getKey()) < 0) && otherEntries.hasNext()) {
                otherEntry = otherEntries.next();
            }
            if (otherEntry == null || otherEntry.getKey().compareTo(thisEntry.getKey()) < 0) {
                // out of otherEntries
                return product;
            } else if (otherEntry.getKey().equals(thisEntry.getKey())) {
                product += other.weight(otherEntry.getValue())*this.weight(thisEntry.getValue());
            } else {
                // other entry is greater, keep on iterating thisEntries;
            }
        }
        return product;
    }

    double cosineSimilarity(TermVector other) {
        return dotProduct(other)/(this.norm*other.norm);
    }
}
