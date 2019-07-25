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

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.ext.DefaultHandler2;

import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;
import java.util.function.Function;

public class XmlHandler extends DefaultHandler2 {
    Element currentElement = null;
    ElementHandler currentHandler = null;
    Map<Element,ElementHandler> parentHandlers = new HashMap<>();

    protected XmlHandler(ElementHandler rootHandler) {
        this.currentHandler = rootHandler;
    }

    @Override
    public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
        if (currentElement == null) {
            currentElement = new Element(null, uri, localName, qName, attributes);
        } else {
            currentElement = currentElement.startElement(uri, localName, qName, attributes);
        }
        started(currentElement);
    }

    private void started(Element currentElement) {
        ElementHandler newHandler = currentHandler.started(currentElement);
        if (newHandler != null) {
            parentHandlers.put(currentElement, currentHandler);
            currentHandler = newHandler;
            currentHandler.started(currentElement);
        }
    }

    @Override
    public void endElement(String uri, String localName, String qName) throws SAXException {
        finished(currentElement);
        currentElement = currentElement.endElement(uri, localName, qName);
    }

    private void finished(Element currentElement) {
        currentHandler.finished(currentElement);
        ElementHandler oldHandler = parentHandlers.remove(currentElement);
        if (oldHandler != null) {
            currentHandler = oldHandler;
        }
    }

    @Override
    public void characters(char[] ch, int start, int length) throws SAXException {
        currentElement.characters(ch, start, length);
    }

    public static abstract class ElementHandler {
        /**
         *
         * @param element element that starts
         * @return handler which will handle this element, or null, if this handler will continue handling the elements
         */
        protected abstract ElementHandler started(Element element);

        protected abstract void finished(Element element);

    }

    public static class Element {
        private final Element parent;
        public final String uri;
        public final String localName;
        public final String qName;
        public Attributes attributes;
        private final StringBuffer text = new StringBuffer();

        Element(Element parent, String uri, String localName, String qName, Attributes attributes) {
            this.parent = parent;
            this.uri = uri;
            this.localName = localName;
            this.qName = qName;
            this.attributes = attributes;
        }

        Element startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
           return new Element(this, uri, localName, qName, attributes);
        }

        Element endElement(String uri, String localName, String qName) {
            return parent;
        }

        public String getText() {
            return text.toString();
        }

        void characters(char[] ch, int start, int length) {
            this.text.append(ch, start, length);
        }
    }


    public static ElementHandler when(String qName, Function<Element, ElementHandler> initHandler) {
        return new ElementHandler() {
            @Override
            protected ElementHandler started(Element element) {
                if (qName.equals(element.qName)) {
                    return initHandler.apply(element);
                } else {
                    return null;
                }
            }

            @Override
            protected void finished(Element element) {

            }
        };
    }

    public static ElementHandler process(Consumer<Element> processor) {
        return new ElementHandler() {
            @Override
            protected ElementHandler started(Element element) {
                return null;
            }

            @Override
            protected void finished(Element element) {
                processor.accept(element);
            }
        };
    }

}
