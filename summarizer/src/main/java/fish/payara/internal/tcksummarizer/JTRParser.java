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

import java.util.Scanner;

public class JTRParser {
    private final Handler handler;

    interface Handler {
        void start();
        void startSection(String sectionLine);
        void startSubsection(String subsectionLine);
        void line(String line);
        void finish();
    }

    JTRParser(Handler h) {
        this.handler = h;
    }

    void parse(String jtrOutput) {
        Scanner scanner = new Scanner(jtrOutput);
        handler.start();
        while (scanner.hasNextLine()) {
            String line = scanner.nextLine();
            if (line.startsWith("#")) {
                handler.startSection(line.replaceFirst("^#-*(.+?)-*$", "$1"));
            } else if (line.startsWith("-")) {
                handler.startSubsection(line.replaceFirst("^-+(.+?)-*$", "$1"));
            } else {
                handler.line(line);
            }
        }
        handler.finish();
    }

    static abstract class StatelessHandler implements Handler {

        private String section;
        private String subSection;

        @Override
        public void start() {
            this.section = null;
            this.subSection = null;
        }

        @Override
        public void startSection(String sectionLine) {
            this.section = sectionLine;
        }

        @Override
        public void startSubsection(String subsectionLine) {
            this.subSection = subsectionLine;
        }

        @Override
        public void line(String line) {
            line(section, subSection, line);
        }

        protected abstract void line(String section, String subSection, String line);

        @Override
        public void finish() {

        }
    }
}
